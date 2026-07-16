import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';

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
  /// The filesystem walk runs on a background isolate; audio metadata is
  /// enriched afterwards on the caller isolate.
  static Future<List<MediaItem>> scan(List<String> folders) async {
    if (folders.isEmpty) return const [];
    final items = await compute(_scanIsolate, folders);
    return _enrichAudioMetadata(items);
  }

  /// Read audio tags (title / artist / album / duration / embedded artwork)
  /// for every audio item and cache the cover art to disk. Non-audio items
  /// pass through unchanged. Failures on a single file are swallowed so one
  /// corrupt track never aborts the whole scan.
  static Future<List<MediaItem>> _enrichAudioMetadata(List<MediaItem> items) async {
    final hasAudio = items.any((i) => i.type == MediaType.audio);
    if (!hasAudio) return items;

    final cacheDir = await getTemporaryDirectory();
    final artDir = Directory('${cacheDir.path}/lumiluna_artwork');
    await artDir.create(recursive: true);

    final out = <MediaItem>[];
    for (final item in items) {
      if (item.type != MediaType.audio) {
        out.add(item);
        continue;
      }
      try {
        final meta = await MetadataGod.readMetadata(item.path);
        String? artPath;
        final pic = meta.picture;
        if (pic?.data != null) {
          final key = item.path.hashCode.abs().toString();
          final dest = '${artDir.path}/$key${_extForMime(pic!.mimeType)}';
          final file = File(dest);
          if (!await file.exists()) {
            await file.writeAsBytes(pic.data!);
          }
          artPath = dest;
        }
        out.add(item.copyWith(
          title: meta.title,
          artist: meta.artist,
          album: meta.album,
          durationMs: meta.durationMs,
          artworkPath: artPath,
        ));
      } catch (_) {
        out.add(item);
      }
    }
    return out;
  }

  /// Map an artwork MIME type to a file extension for the cached cover image.
  static String _extForMime(String? mime) {
    if (mime == null) return '.jpg';
    if (mime.contains('png')) return '.png';
    if (mime.contains('webp')) return '.webp';
    if (mime.contains('bmp')) return '.bmp';
    return '.jpg';
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
