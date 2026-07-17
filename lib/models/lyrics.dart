/// A single timed line in a lyrics file.
class LyricsLine {
  /// The timestamp at which this line should appear.
  final Duration timestamp;

  /// The lyric text (may be empty for instrumental lines).
  final String text;

  const LyricsLine({required this.timestamp, required this.text});

  @override
  String toString() => '[${timestamp.inMinutes}:'
      '${(timestamp.inSeconds % 60).toString().padLeft(2, '0')}.'
      '${(timestamp.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}] $text';
}

/// Immutable parsed lyrics (LRC format or plain text).
///
/// After construction the [lines] list is sorted by [LyricsLine.timestamp]
/// and never mutated.  Use [lineIndexAt] to look up the active line by
/// playback position.
class Lyrics {
  final List<LyricsLine> lines;

  /// Whether the source file contained valid time-tags (synced lyrics).
  final bool isSynced;

  const Lyrics({required this.lines, this.isSynced = false});

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  /// Parse standard LRC (and the common variant where one text line is
  /// preceded by *multiple* timestamp tags, e.g.
  /// `[01:23.45][02:34.56]some text`).
  factory Lyrics.fromLrc(String lrc) {
    final result = <LyricsLine>[];

    // Match: leading timestamp(s) followed by the rest of the line.
    // Captures repeated `[mm:ss.xx]` groups.
    final tagRe = RegExp(r'\[(\d{1,3}):(\d{2})(?:\.(\d{1,3}))?\]');
    final multiRe = RegExp(
      r'^((?:\[\d{1,3}:\d{2}(?:\.\d{1,3})?\])+)\s*(.*)$',
      multiLine: true,
    );

    for (final m in multiRe.allMatches(lrc)) {
      final tagsPart = m.group(1)!;
      final text = m.group(2)?.trim() ?? '';
      if (text.isEmpty) continue; // skip pure-tag / empty lines

      for (final tm in tagRe.allMatches(tagsPart)) {
        final minutes = int.parse(tm.group(1)!);
        final seconds = int.parse(tm.group(2)!);
        final msStr = tm.group(3);
        final ms = msStr != null
            ? int.parse(msStr) * (msStr.length == 2 ? 10 : 1)
            : 0;
        result.add(LyricsLine(
          timestamp: Duration(minutes: minutes, seconds: seconds, milliseconds: ms),
          text: text,
        ));
      }
    }

    // Sort by timestamp (required for binary search in lineIndexAt).
    result.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Lyrics(lines: result, isSynced: result.isNotEmpty);
  }

  /// Treat every non-empty line as a plain-text lyric with timestamp zero.
  factory Lyrics.fromPlainText(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => LyricsLine(timestamp: Duration.zero, text: l))
        .toList();
    return Lyrics(lines: lines, isSynced: false);
  }

  // ---------------------------------------------------------------------------
  // Lookup
  // ---------------------------------------------------------------------------

  /// Returns the index of the last line whose [LyricsLine.timestamp] is
  /// <= [position].  Returns -1 when no line has started yet.
  int lineIndexAt(Duration position) {
    if (lines.isEmpty) return -1;
    // Binary search — O(log n).
    int lo = 0;
    int hi = lines.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (lines[mid].timestamp <= position) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lines[lo].timestamp <= position ? lo : -1;
  }
}

// ---------------------------------------------------------------------------
// Top-level helper — auto-detects LRC vs plain text
// ---------------------------------------------------------------------------

final _lrcTagRe = RegExp(r'^\[\d{1,3}:\d{2}(?:\.\d{1,3})?\]', multiLine: true);

/// Parse [text] as LRC if it contains timestamp tags, otherwise as plain text.
Lyrics parseLyrics(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return const Lyrics(lines: []);
  return _lrcTagRe.hasMatch(trimmed)
      ? Lyrics.fromLrc(trimmed)
      : Lyrics.fromPlainText(trimmed);
}
