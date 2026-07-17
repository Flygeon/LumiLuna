import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import '../models/lyrics.dart';

/// Loads lyrics for a given audio file at play time.
class LyricsService {
  /// Returns parsed [Lyrics] by checking (in order):
  /// 1. Embedded lyrics in the audio file's metadata
  /// 2. A sidecar `.lrc` file in the same directory
  /// 3. A sidecar `.txt` file with the same base name
  /// Returns `null` when no lyrics are found.
  static Future<Lyrics?> load(String audioPath) async {
    final raw = await loadRawLyrics(audioPath);
    if (raw == null) return null;
    return parseLyrics(raw);
  }

  /// Returns the **raw lyric text** (LRC or plain) without parsing, so that
  /// downstream consumers (e.g. flutter_lyric's LyricController) can parse it
  /// themselves and support features like translation merging / QRC conversion.
  ///
  /// Lookup order:
  /// 1. Embedded lyrics in the audio file's metadata
  /// 2. A sidecar `.lrc` file in the same directory
  /// 3. A sidecar `.txt` file with the same base name
  static Future<String?> loadRawLyrics(String audioPath) async {
    // 1. Try embedded lyrics.
    try {
      final meta = readMetadata(File(audioPath), getImage: false);
      if (meta.lyrics != null && meta.lyrics!.trim().isNotEmpty) {
        return meta.lyrics;
      }
    } catch (_) {
      // ignore read errors
    }

    final dot = audioPath.lastIndexOf('.');
    if (dot < 0) return null;
    final base = audioPath.substring(0, dot);

    // 2. Try sidecar .lrc file.
    try {
      final lrcFile = File('$base.lrc');
      if (await lrcFile.exists()) {
        final content = await lrcFile.readAsString();
        if (content.trim().isNotEmpty) return content;
      }
    } catch (_) {
      // ignore
    }

    // 3. Try sidecar .txt file.
    try {
      final txtFile = File('$base.txt');
      if (await txtFile.exists()) {
        final content = await txtFile.readAsString();
        if (content.trim().isNotEmpty) return content;
      }
    } catch (_) {
      // ignore
    }

    return null;
  }
}
