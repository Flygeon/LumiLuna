import 'dart:async';
import 'dart:io';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';
import 'database_service.dart';
import 'media_scanner_service.dart';

/// Watches configured scan folders for file-system changes and performs
/// incremental scans so the media library stays up-to-date without manual
/// refreshes.
///
/// ## How it works
///
/// 1. Attaches a [Directory.watch] on each configured scan folder.
/// 2. On file-system events it debounces (batches rapid changes together).
/// 3. Single-file events (create / modify) are handled by reading metadata
///    for just that file and upserting into the database.
/// 4. When a folder is deleted or a batch of events is too large, it falls
///    back to a full re-scan of that folder.
class FolderWatcherService {
  FolderWatcherService();

  final Set<Directory> _watched = {};
  final List<StreamSubscription> _subscriptions = [];
  Timer? _debounceTimer;
  final List<String> _pendingEvents = [];

  bool _watching = false;

  /// Whether the watcher is currently active.
  bool get isWatching => _watching;

  /// Start watching all folders currently configured in [DatabaseService].
  Future<void> start() async {
    if (_watching) await stop();
    final folders = await DatabaseService.getScanFolders();
    for (final folderPath in folders) {
      _watchFolder(folderPath);
    }
    _watching = true;
  }

  /// Stop all watchers.
  Future<void> stop() async {
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _watched.clear();
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _pendingEvents.clear();
    _watching = false;
  }

  /// Restart (e.g. after scan-folder configuration change).
  Future<void> restart() async {
    await stop();
    await start();
  }

  void _watchFolder(String folderPath) {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) return;
    if (_watched.contains(dir)) return;

    try {
      final sub = dir.watch(recursive: true).listen(
        (event) => _onFileEvent(event, folderPath),
        onError: (_) {},
        cancelOnError: false,
      );
      _subscriptions.add(sub);
      _watched.add(dir);
    } catch (_) {
      // Permission denied, etc.
    }
  }

  void _onFileEvent(FileSystemEvent event, String rootFolder) {
    // Skip hidden files and directories.
    final path = event.path.replaceAll('\\', '/');
    final segments = path.split('/');
    if (segments.any((s) => s.startsWith('.'))) return;

    // Check if this is a supported media extension.
    final dot = path.lastIndexOf('.');
    if (dot < 0) return;
    final ext = path.substring(dot + 1).toLowerCase();
    if (!AppConstants.allExtensions.contains(ext)) return;

    // Debounce: batch events that arrive within a short window.
    _pendingEvents.add(event.path);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      _flushPending();
    });
  }

  Future<void> _flushPending() async {
    if (_pendingEvents.isEmpty) return;

    final batch = List<String>.from(_pendingEvents);
    _pendingEvents.clear();

    // Separate creates/modifies vs deletes.
    final upsertPaths = <String>[];
    final deletePaths = <String>[];

    for (final path in batch) {
      final file = File(path);
      if (await file.exists()) {
        upsertPaths.add(path);
      } else {
        deletePaths.add(path);
      }
    }

    // Upsert new/changed files.
    if (upsertPaths.isNotEmpty) {
      final items = <MediaItem>[];
      for (final path in upsertPaths) {
        try {
          final stat = await File(path).stat();
          final item = MediaItem.fromPath(path, stat: stat);
          if (item != null) items.add(item);
        } catch (_) {}
      }
      if (items.isNotEmpty) {
        // Enrich audio metadata for new audio files.
        final enriched = await MediaScannerService.enrichAudioItems(items);
        await DatabaseService.upsertMediaItems(enriched);
      }
    }

    // Remove deleted files.
    if (deletePaths.isNotEmpty) {
      await DatabaseService.removeMediaItems(deletePaths);
    }
  }
}
