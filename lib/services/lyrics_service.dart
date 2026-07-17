import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import '../models/lyrics.dart';

/// Loads lyrics for a given audio file at play time.
class LyricsService {
  /// Returns parsed [Lyrics] by checking (in order):
  /// 1. Embedded lyrics in the audio file's metadata
  /// 2. A sidecar `.lrc` file in the same directory
  /// Returns `null` when no lyrics are found.
  static Future<Lyrics?> load(String audioPath) async {
    // 1. Try embedded lyrics.
    try {
      final meta = readMetadata(File(audioPath), getImage: false);
      if (meta.lyrics != null && meta.lyrics!.trim().isNotEmpty) {
        return parseLyrics(meta.lyrics!);
      }
    } catch (_) {
      // ignore read errors
    }

    // 2. Try sidecar .lrc file.
    final lrcPath = '${audioPath.substring(0, audioPath.lastIndexOf('.'))}.lrc';
    final lrcFile = File(lrcPath);
    try {
      if (await lrcFile.exists()) {
        final content = await lrcFile.readAsString();
        if (content.trim().isNotEmpty) {
          return parseLyrics(content);
        }
      }
    } catch (_) {
      // ignore read errors
    }

    // 3. Try sidecar .txt file with same base name.
    final txtPath =
        '${audioPath.substring(0, audioPath.lastIndexOf('.'))}.txt';
    final txtFile = File(txtPath);
    try {
      if (await txtFile.exists()) {
        final content = await txtFile.readAsString();
        if (content.trim().isNotEmpty) {
          return parseLyrics(content);
        }
      }
    } catch (_) {
      // ignore read errors
    }

    return null;
  }
}
