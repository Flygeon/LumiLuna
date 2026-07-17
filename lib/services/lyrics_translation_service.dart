import 'dart:io';

/// Loads a translation lyrics file for a given audio file.
///
/// Looks for sidecar translation files in priority order:
///   1. `<basename>.zh.lrc`     (most common Chinese convention)
///   2. `<basename>.translation.lrc`
///   3. `<basename>.zh-CN.lrc`
///   4. `<basename>.zh-Hans.lrc`
///   5. `<basename>.translate.lrc`
///
/// Returns the raw LRC text so that flutter_lyric's [LyricController.loadLyric]
/// can parse it via its internal [LyricParse.parse] alongside the main lyric.
/// Returns `null` when no translation file is found.
class LyricsTranslationService {
  static const _candidates = <String>[
    '.zh.lrc',
    '.translation.lrc',
    '.zh-CN.lrc',
    '.zh-Hans.lrc',
    '.translate.lrc',
    '.zh.lrc.txt',
  ];

  /// Returns translation LRC text for [audioPath], or `null` if none.
  static Future<String?> load(String audioPath) async {
    final dot = audioPath.lastIndexOf('.');
    if (dot < 0) return null;
    final base = audioPath.substring(0, dot);

    for (final suffix in _candidates) {
      final file = File('$base$suffix');
      try {
        if (await file.exists()) {
          final content = await file.readAsString();
          if (content.trim().isNotEmpty) return content;
        }
      } catch (_) {
        // ignore — try next candidate
      }
    }
    return null;
  }
}
