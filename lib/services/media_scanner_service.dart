import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';
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
  /// enriched in parallel on worker isolates.
  static Future<List<MediaItem>> scan(List<String> folders) async {
    if (folders.isEmpty) return const [];
    final items = await compute(_scanIsolate, folders);
    return _enrichAudioMetadataParallel(items);
  }

  /// Number of audio items to process per isolate chunk.
  ///
  /// Larger chunks → fewer isolates spawned → less overhead.
  /// Smaller chunks → better parallelism → faster wall-clock time.
  ///
  /// 30 was chosen empirically: it keeps each isolate busy for ~100-300 ms
  /// while giving the system enough granularity to saturate all CPU cores.
  static const int _audioChunkSize = 30;

  /// Maximum number of concurrent isolate workers for audio enrichment.
  ///
  /// Constrained to avoid saturating the I/O subsystem. 4 works well on
  /// typical quad-core / octa-core Windows machines. On systems with more
  /// cores, isolating fewer chunks than cores leaves headroom for the UI
  /// thread and the OS cache manager.
  static const int _maxAudioWorkers = 4;

  /// Read audio tags and cache cover art **in parallel** using worker
  /// isolates. Non-audio items pass through unchanged.
  ///
  /// ## Strategy
  /// 1. Collect all audio items.
  /// 2. Split them into fixed-size chunks ([_audioChunkSize]).
  /// 3. Dispatch each chunk to a worker isolate via [compute].
  /// 4. Merge the enriched results back into the full list by path.
  ///
  /// This gives near-linear speed-up on multi-core hardware because every
  /// audio file is independent — there is no shared state between chunks.
  static Future<List<MediaItem>> _enrichAudioMetadataParallel(
      List<MediaItem> items) async {
    final audioItems = <MediaItem>[];
    final nonAudio = <MediaItem>[];
    for (final item in items) {
      if (item.type == MediaType.audio) {
        audioItems.add(item);
      } else {
        nonAudio.add(item);
      }
    }
    if (audioItems.isEmpty) return items;

    final cacheDir = await getTemporaryDirectory();
    final artDir = Directory('${cacheDir.path}/lumiluna_artwork');
    await artDir.create(recursive: true);

    // Split audio items into chunks.
    final chunks = <List<MediaItem>>[];
    for (var i = 0; i < audioItems.length; i += _audioChunkSize) {
      final end = (i + _audioChunkSize).clamp(0, audioItems.length);
      chunks.add(audioItems.sublist(i, end));
    }

    // Process all chunks in batches via [compute].
    // Each chunk runs in its own isolate; the OS / Dart VM schedules them
    // across available cores.
    //
    // We process at most [_maxAudioWorkers] chunks per batch to avoid
    // saturating the I/O subsystem with too many simultaneous disk reads.
    final enriched = <String, MediaItem>{};

    for (var offset = 0; offset < chunks.length; offset += _maxAudioWorkers) {
      final end = (offset + _maxAudioWorkers).clamp(0, chunks.length);
      final batch = chunks.sublist(offset, end);

      await Future.wait(batch.map((chunk) async {
        final args = <String, dynamic>{
          'items': chunk.map((e) => e.toJson()).toList(),
          'artworkDir': artDir.path,
        };
        try {
          final result = await compute(_processAudioChunk, args);
          for (final json in result) {
            final item = MediaItem.fromJson(json);
            enriched[item.path] = item;
          }
        } catch (_) {
          // Entire chunk failed — keep original items so nothing is lost.
          for (final item in chunk) {
            enriched[item.path] = item;
          }
        }
      }));
    }

    // Merge: replace audio items with enriched versions, keep others unchanged.
    return [
      ...nonAudio,
      for (final item in audioItems) enriched[item.path] ?? item,
    ];
  }

  /// Map an artwork MIME type to a file extension for the cached cover image.
  static String _extForMime(String? mime) {
    if (mime == null) return '.jpg';
    if (mime.contains('png')) return '.png';
    if (mime.contains('webp')) return '.webp';
    if (mime.contains('bmp')) return '.bmp';
    return '.jpg';
  }

  // ---------------------------------------------------------------------------
  // Isolate entry-points (top-level static functions for compute())
  // ---------------------------------------------------------------------------

  /// Worker isolate: read audio metadata + write artwork for one chunk.
  ///
  /// Accepts `{items: List<Map>, artworkDir: String}`.
  /// Returns `List<Map>` — the enriched items serialised as JSON maps.
  ///
  /// Uses synchronous I/O inside the isolate since [compute] requires a
  /// synchronously-returning callback.
  @pragma('vm:entry-point')
  static List<Map<String, dynamic>> _processAudioChunk(
      Map<String, dynamic> args) {
    final itemsJson = (args['items'] as List).cast<Map<String, dynamic>>();
    final artworkDir = args['artworkDir'] as String;
    final results = <Map<String, dynamic>>[];

    for (final json in itemsJson) {
      final item = MediaItem.fromJson(json);
      try {
        final meta = readMetadata(File(item.path), getImage: true);
        String? artPath;
        if (meta.pictures.isNotEmpty) {
          final pic = meta.pictures.first;
          final key = item.path.hashCode.abs().toString();
          final dest = '$artworkDir/$key${_extForMime(pic.mimetype)}';
          final file = File(dest);
          if (!file.existsSync()) {
            file.writeAsBytesSync(pic.bytes);
          }
          artPath = dest;
        }
        results.add(item.copyWith(
          title: meta.title,
          artist: meta.artist,
          album: meta.album,
          durationMs: meta.duration?.inMilliseconds,
          artworkPath: artPath,
        ).toJson());
      } catch (_) {
        // Single file failure → return item unchanged.
        results.add(item.toJson());
      }
    }
    return results;
  }

  /// Isolate entry point for the initial filesystem scan.
  @pragma('vm:entry-point')
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
