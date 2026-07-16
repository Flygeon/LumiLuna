import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';

/// Serialises and restores scan results to/from a JSON cache file.
///
/// The cache stores the full list of [MediaItem]s together with the folder
/// configuration they were scanned from, so we can detect staleness when the
/// user changes their scan folders.
///
/// A stale or corrupted cache is silently discarded and the caller falls back
/// to a full filesystem scan.
class ScanCacheManager {
  ScanCacheManager._();

  /// The cache file path in the application support directory.
  static Future<File> _cacheFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}${Platform.pathSeparator}${AppConstants.cacheFileName}');
  }

  /// Persist [items] together with the [folders] that produced them.
  static Future<void> save(List<MediaItem> items, List<String> folders) async {
    final data = {
      'version': 1,
      'scannedAt': DateTime.now().toIso8601String(),
      'folders': folders,
      'items': items.map((e) => e.toJson()).toList(),
    };
    final file = await _cacheFile();
    await file.writeAsString(jsonEncode(data));
  }

  /// Load cached scan results if still valid for [currentFolders].
  ///
  /// Returns `null` when no cache exists, the folder configuration changed,
  /// the cache is too old, or the file is corrupted. Callers should then
  /// perform a full scan.
  static Future<List<MediaItem>?> load(List<String> currentFolders) async {
    final file = await _cacheFile();
    if (!await file.exists()) return null;

    try {
      final raw = await file.readAsString();
      final data = jsonDecode(raw) as Map<String, dynamic>;

      // Version must match exactly.
      if (data['version'] != 1) return null;

      // Folder configuration must match the current one.
      final cachedFolders = (data['folders'] as List).cast<String>();
      if (!listEquals(cachedFolders, currentFolders)) return null;

      // Age check — don't serve a cache older than the threshold.
      final scannedAt = DateTime.parse(data['scannedAt'] as String);
      if (DateTime.now().difference(scannedAt).inHours >
          AppConstants.cacheMaxAgeHours) {
        return null;
      }

      final items = (data['items'] as List)
          .cast<Map<String, dynamic>>()
          .map((e) => MediaItem.fromJson(e))
          .toList();
      return items;
    } catch (_) {
      // Corrupted file — delete and fall back to a full scan.
      return null;
    }
  }

  /// Delete the cache file so the next load forces a full scan.
  static Future<void> clear() async {
    final file = await _cacheFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
