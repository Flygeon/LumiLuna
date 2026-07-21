enum EpubHtmlBlockType { paragraph, heading, listItem, lineBreak, text }

class EpubHtmlBlock {
  final EpubHtmlBlockType type;
  final String text;
  final int? level;
  final bool ordered;
  final int? index;

  const EpubHtmlBlock({
    required this.type,
    required this.text,
    this.level,
    this.ordered = false,
    this.index,
  });

  bool get isBreak => type == EpubHtmlBlockType.lineBreak;
}

class EpubHtmlDocument {
  final List<EpubHtmlBlock> blocks;
  final String text;

  const EpubHtmlDocument({required this.blocks, required this.text});

  List<EpubSearchMatch> search(String query) {
    final value = query.trim();
    if (value.isEmpty) return const [];
    final lowerText = text.toLowerCase();
    final lowerQuery = value.toLowerCase();
    final matches = <EpubSearchMatch>[];
    var offset = 0;
    while (true) {
      final start = lowerText.indexOf(lowerQuery, offset);
      if (start < 0) break;
      matches.add(EpubSearchMatch(
        query: value,
        start: start,
        end: start + value.length,
        preview: _preview(start, start + value.length),
      ));
      offset = start + lowerQuery.length;
    }
    return matches;
  }

  String _preview(int start, int end) {
    final previewStart = (start - 32).clamp(0, text.length);
    final previewEnd = (end + 32).clamp(0, text.length);
    return text.substring(previewStart, previewEnd).replaceAll('\n', ' ');
  }
}

class EpubSearchMatch {
  final String query;
  final int start;
  final int end;
  final String preview;

  const EpubSearchMatch({
    required this.query,
    required this.start,
    required this.end,
    required this.preview,
  });
}
