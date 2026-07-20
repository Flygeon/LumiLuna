import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';

class CacheManager {
  CacheManager._();
  static final CacheManager _instance = CacheManager._();
  factory CacheManager() => _instance;

  static Future<String> get _cacheRoot async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}${Platform.pathSeparator}${AppConstants.cacheRootName}';
  }

  /// Get path for a cache subdirectory, creating it if needed.
  static Future<String> _ensureDir(String sub) async {
    final root = await _cacheRoot;
    final dir = Directory('$root${Platform.pathSeparator}$sub');
    await dir.create(recursive: true);
    return dir.path;
  }

  /// Path to the thumbnails cache directory.
  static Future<String> get thumbnailsDir =>
      _ensureDir(AppConstants.cacheThumbnailsDir);

  /// Path to the video thumbnails cache directory.
  static Future<String> get videoThumbsDir =>
      _ensureDir(AppConstants.cacheVideoThumbsDir);

  /// Path to the artwork cache directory.
  static Future<String> get artworkDir =>
      _ensureDir(AppConstants.cacheArtworkDir);

  /// Return a stable cache filename for a media item.
  /// Uses the same XXH3 hash pattern as Rust.
  static String cacheFilename(MediaItem item) {
    final input =
        '${item.path.replaceAll('\\', '/').toLowerCase()}|${item.size}|${item.modified.millisecondsSinceEpoch}';
    var hash = 0xcbf29ce484222325;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return hash.toRadixString(16);
  }

  /// Migrate old cache files from [oldDir] to [newDir], removing [oldDir] afterwards.
  static Future<void> migrateFrom(String oldDir, String newDir) async {
    final old = Directory(oldDir);
    if (!await old.exists()) return;
    final newD = Directory(newDir);
    await newD.create(recursive: true);
    await for (final entry in old.list()) {
      if (entry is File) {
        final name = entry.uri.pathSegments.last;
        try {
          await entry.rename('${newDir}${Platform.pathSeparator}$name');
        } catch (_) {
          // If rename fails (cross-device), copy+delete
          await entry.copy('${newDir}${Platform.pathSeparator}$name');
          await entry.delete();
        }
      }
    }
    await old.delete(recursive: true);
  }

  /// Delete all cached files, return total bytes freed.
  static Future<int> clearAll() async {
    final root = await _cacheRoot;
    final dir = Directory(root);
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    await dir.delete(recursive: true);
    return total;
  }

  /// Calculate total size of all cached files in bytes.
  static Future<int> getCacheSize() async {
    final root = await _cacheRoot;
    final dir = Directory(root);
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  /// Delete stale cache entries that don't match any known media item.
  /// Takes a list of expected cache filenames (from the database).
  static Future<void> purgeStale(List<String> activeCacheKeys) async {
    final root = await _cacheRoot;
    final dir = Directory(root);
    if (!await dir.exists()) return;
    final active = activeCacheKeys.toSet();
    await for (final sub in dir.list()) {
      if (sub is Directory) {
        await for (final entry in sub.list(recursive: true)) {
          if (entry is File) {
            final name = entry.uri.pathSegments.last;
            final withoutExt = name.contains('.')
                ? name.substring(0, name.lastIndexOf('.'))
                : name;
            if (!active.contains(withoutExt)) {
              await entry.delete();
            }
          }
        }
      }
    }
  }
}
