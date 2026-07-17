/// A single timed line in a lyrics file.
class LyricsLine {
  final Duration timestamp;
  final String text;

  const LyricsLine({required this.timestamp, required this.text});

  @override
  String toString() => '[${timestamp.inMinutes}:${(timestamp.inSeconds % 60).toString().padLeft(2, '0')}.${(timestamp.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}] $text';
}

/// Parsed lyrics (LRC format or plain text).
class Lyrics {
  final List<LyricsLine> lines;
  final bool isSynced;

  const Lyrics({required this.lines, this.isSynced = false});

  factory Lyrics.fromLrc(String lrc) {
    final lines = <LyricsLine>[];
    final lineRegex = RegExp(
      r'^\[(\d{1,3}):(\d{2})(?:\.(\d{2,3}))?\](.*)$',
      multiLine: true,
    );
    for (final match in lineRegex.allMatches(lrc)) {
      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final msStr = match.group(3);
      final milliseconds = msStr != null
          ? int.parse(msStr) * (msStr.length == 2 ? 10 : 1)
          : 0;
      final text = match.group(4)!.trim();
      if (text.isNotEmpty) {
        lines.add(LyricsLine(
          timestamp: Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: milliseconds,
          ),
          text: text,
        ));
      }
    }
    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return Lyrics(lines: lines, isSynced: lines.isNotEmpty);
  }

  factory Lyrics.fromPlainText(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .map((l) => LyricsLine(timestamp: Duration.zero, text: l))
        .toList();
    return Lyrics(lines: lines, isSynced: false);
  }

  /// Get the active line index for a given [position].
  int lineIndexAt(Duration position) {
    if (lines.isEmpty) return -1;
    // Binary search for the last line whose timestamp <= position.
    int lo = 0, hi = lines.length - 1;
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

  /// Progress of the current line (0.0–1.0) for scroll animation.
  double lineProgress(Duration position, {Duration ahead = const Duration(seconds: 3)}) {
    final idx = lineIndexAt(position);
    if (idx < 0) return 0.0;
    final start = lines[idx].timestamp;
    final end = idx + 1 < lines.length
        ? lines[idx + 1].timestamp
        : start + ahead;
    final total = end - start;
    if (total <= Duration.zero) return 0.0;
    final elapsed = position - start;
    return (elapsed.inMicroseconds / total.inMicroseconds).clamp(0.0, 1.0);
  }
}

/// Parses both LRC text and plain text (auto-detects LRC format).
Lyrics parseLyrics(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return Lyrics(lines: []);
  // If it contains LRC-style timestamps, parse as LRC.
  if (RegExp(r'^\[\d{1,3}:\d{2}[.\d]*\]', multiLine: true).hasMatch(trimmed)) {
    return Lyrics.fromLrc(trimmed);
  }
  return Lyrics.fromPlainText(trimmed);
}
