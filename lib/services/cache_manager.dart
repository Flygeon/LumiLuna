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
  ///
  /// The CPU-intensive `jsonEncode` call is offloaded to a worker isolate
  /// so the UI thread is not blocked by serialising thousands of items.
  static Future<void> save(List<MediaItem> items, List<String> folders) async {
    final data = {
      'version': 1,
      'scannedAt': DateTime.now().toIso8601String(),
      'folders': folders,
      'items': items.map((e) => e.toJson()).toList(),
    };
    // jsonEncode is CPU-bound — run it on a worker isolate.
    final json = await compute(_jsonEncodeIsolate, data);
    final file = await _cacheFile();
    await file.writeAsString(json);
  }

  /// Load cached scan results if still valid for [currentFolders].
  ///
  /// Returns `null` when no cache exists, the folder configuration changed,
  /// the cache is too old, or the file is corrupted. Callers should then
  /// perform a full scan.
  ///
  /// The CPU-intensive `jsonDecode` call is offloaded to a worker isolate.
  static Future<List<MediaItem>?> load(List<String> currentFolders) async {
    final file = await _cacheFile();
    if (!await file.exists()) return null;

    try {
      final raw = await file.readAsString();
      // jsonDecode is CPU-bound — run it on a worker isolate.
      final data = await compute(_jsonDecodeIsolate, raw);

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

  // ---------------------------------------------------------------------------
  // Isolate entry-points
  // ---------------------------------------------------------------------------

  /// Worker isolate: serialise [data] to a JSON string.
  ///
  /// [data] must be a map whose values are JSON-compatible (Strings, Lists,
  /// Maps, ints, bools, null) so it can be transferred through SendPort.
  @pragma('vm:entry-point')
  static String _jsonEncodeIsolate(Map<String, dynamic> data) =>
      jsonEncode(data);

  /// Worker isolate: parse [raw] JSON string into a map.
  @pragma('vm:entry-point')
  static Map<String, dynamic> _jsonDecodeIsolate(String raw) =>
      jsonDecode(raw) as Map<String, dynamic>;
}
