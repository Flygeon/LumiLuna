import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';

/// Scans local folders for media files on a background isolate.
class MediaScannerService {
  /// Resolve the default media directories to scan (Pictures / Videos / Music).
  ///
  /// [path_provider] does not expose these on Windows directly, so we derive
  /// them from the user profile directory and fall back gracefully.
  static Future<List<String>> defaultFolders() async {
    final result = <String>[];

    // Try USERPROFILE / HOME based well-known folders (Windows/macOS/Linux).
    final home = _homeDir();
    if (home != null) {
      for (final sub in const ['Pictures', 'Videos', 'Music']) {
        final dir = Directory('$home${Platform.pathSeparator}$sub');
        if (await dir.exists()) result.add(dir.path);
      }
    }

    // Fall back to platform documents directory if nothing found.
    if (result.isEmpty) {
      try {
        final docs = await getApplicationDocumentsDirectory();
        if (await docs.exists()) result.add(docs.path);
      } catch (_) {
        // ignore
      }
    }

    return result;
  }

  static String? _homeDir() {
    final env = Platform.environment;
    if (Platform.isWindows) {
      return env['USERPROFILE'] ?? env['HOMEPATH'];
    }
    return env['HOME'];
  }

  /// Scan the given [folders] recursively and return all media items.
  /// Runs the heavy work on a background isolate via [compute].
  static Future<List<MediaItem>> scan(List<String> folders) async {
    if (folders.isEmpty) return const [];
    return compute(_scanIsolate, folders);
  }

  /// Isolate entry point. Must be a top-level / static function.
  static List<MediaItem> _scanIsolate(List<String> folders) {
    final seen = <String>{};
    final items = <MediaItem>[];

    for (final folder in folders) {
      final dir = Directory(folder);
      if (!dir.existsSync()) continue;
      _walk(dir, 0, seen, items);
    }

    items.sort((a, b) => b.modified.compareTo(a.modified));
    return items;
  }

  static void _walk(
    Directory dir,
    int depth,
    Set<String> seen,
    List<MediaItem> out,
  ) {
    if (depth > AppConstants.maxScanDepth) return;
    List<FileSystemEntity> entries;
    try {
      entries = dir.listSync(followLinks: false);
    } catch (_) {
      return; // permission denied or transient error
    }

    for (final entity in entries) {
      try {
        if (entity is Directory) {
          final name = entity.path.split(Platform.pathSeparator).last;
          if (name.startsWith('.')) continue; // skip hidden dirs
          _walk(entity, depth + 1, seen, out);
        } else if (entity is File) {
          if (seen.contains(entity.path)) continue;
          final item = MediaItem.fromPath(entity.path, stat: entity.statSync());
          if (item != null) {
            seen.add(entity.path);
            out.add(item);
          }
        }
      } catch (_) {
        // skip unreadable entity
      }
    }
  }
}
