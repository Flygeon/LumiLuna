import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_item.dart';
import '../models/media_type.dart';
import '../main.dart';

import '../services/media_scanner_service.dart';
import '../services/database/app_database.dart';
import '../services/media_permission_service.dart';
import 'settings_provider.dart';
import 'folder_watcher_provider.dart';

/// Holds all scanned media items. Rescans when the folder list changes.
///
/// Persists items in SQLite ([DatabaseService]) instead of a JSON cache file.
class MediaNotifier extends AsyncNotifier<List<MediaItem>> {
  Future<void>? _refreshTask;
  @override
  Future<List<MediaItem>> build() async {
    // Rebuild whenever the configured folders change.
    final folders = ref.watch(
      settingsProvider.select((s) => s.scanFolders),
    );

    final target = folders.isNotEmpty
        ? folders
        : await MediaScannerService.defaultFolders();

    await MediaPermissionService.requestForScanning();

    if (target.isEmpty) return const [];

    // Try loading from the database first.
    final db = ref.read(appDatabaseProvider);
    final dbItems = await db.getAllMediaItems();
    final watcher = ref.read(folderWatcherProvider);
    if (dbItems.isNotEmpty) {
      unawaited(watcher.start(target));
      unawaited(_refreshIndex(db, target));
      return dbItems;
    }

    // Database empty — perform a full scan and persist.
    final items = await MediaScannerService.scan(target);
    await db.syncMediaItems(items, target);
    await watcher.start(target);
    return items;
  }

  Future<void> _refreshIndex(AppDatabase db, List<String> folders) {
    final runningTask = _refreshTask;
    if (runningTask != null) return runningTask;

    late final Future<void> trackedTask;
    trackedTask = _performRefresh(db, folders).whenComplete(() {
      if (identical(_refreshTask, trackedTask)) {
        _refreshTask = null;
      }
    });
    _refreshTask = trackedTask;
    return trackedTask;
  }

  Future<void> _performRefresh(AppDatabase db, List<String> folders) async {
    try {
      final items = await MediaScannerService.scan(folders);
      await db.syncMediaItems(items, folders);
      state = AsyncValue.data(await db.getAllMediaItems());
    } catch (_) {}
  }

  Future<void> reloadFromDatabase() async {
    final items = await ref.read(appDatabaseProvider).getAllMediaItems();
    state = AsyncValue.data(items);
  }

  /// Force a rescan of the current folders.
  Future<void> rescan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final folders = ref.read(settingsProvider).scanFolders;
      final target = folders.isNotEmpty
          ? folders
          : await MediaScannerService.defaultFolders();
      if (target.isEmpty) return const <MediaItem>[];
      final items = await MediaScannerService.scan(target);
      final db = ref.read(appDatabaseProvider);
      await db.syncMediaItems(items, target);
      await ref.read(folderWatcherProvider).start(target);
      return items;
    });
  }

  /// Toggle the [isFavorite] flag for the item at [index].
  Future<void> toggleFavorite(int index) async {
    final items = state.value?.toList() ?? <MediaItem>[];
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    final newValue = !item.isFavorite;
    items[index] = item.copyWith(isFavorite: newValue);
    state = AsyncValue.data(items);
    final db = ref.read(appDatabaseProvider);
    await db.setFavorite(item.path, newValue);
  }

  /// Rename the item at [index] to [newName] (on disk and in the list).
  Future<void> renameItem(int index, String newName) async {
    final items = state.value?.toList() ?? <MediaItem>[];
    if (index < 0 || index >= items.length) return;
    final item = items[index];

    // Determine the new full path.
    final dot = item.name.lastIndexOf('.');
    final ext = dot >= 0 ? item.name.substring(dot) : '';
    final finalName = newName.endsWith(ext) ? newName : '$newName$ext';
    final parent =
        item.path.substring(0, item.path.lastIndexOf(Platform.pathSeparator));
    final newPath = '$parent${Platform.pathSeparator}$finalName';

    // Rename on disk.
    await File(item.path).rename(newPath);

    items[index] = item.copyWith(path: newPath, name: finalName);
    state = AsyncValue.data(items);
    final db = ref.read(appDatabaseProvider);
    await db.updateMediaItemPath(item.path, newPath, finalName);
  }

  /// Remove the item at [index] from the list.
  Future<void> removeItem(int index) async {
    final items = state.value?.toList() ?? <MediaItem>[];
    if (index < 0 || index >= items.length) return;
    final path = items[index].path;
    items.removeAt(index);
    state = AsyncValue.data(items);
    final db = ref.read(appDatabaseProvider);
    await db.removeMediaItems([path]);
  }
}

final mediaProvider =
    AsyncNotifierProvider<MediaNotifier, List<MediaItem>>(MediaNotifier.new);

/// Items filtered by a specific media type.
final mediaByTypeProvider =
    Provider.family<AsyncValue<List<MediaItem>>, MediaType>((ref, type) {
  final async = ref.watch(mediaProvider);
  return async.whenData(
    (items) => items.where((i) => i.type == type).toList(),
  );
});

/// Count per media type for badges / summaries.
final mediaCountsProvider = Provider<Map<MediaType, int>>((ref) {
  final async = ref.watch(mediaProvider);
  final counts = {for (final t in MediaType.values) t: 0};
  async.whenData((items) {
    for (final item in items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }
  });
  return counts;
});
