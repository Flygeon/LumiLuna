import '../models/epub_html_model.dart';

class EpubHtmlParser {
  static const _blockTags = {
    'address',
    'article',
    'aside',
    'blockquote',
    'div',
    'figure',
    'footer',
    'header',
    'main',
    'p',
    'pre',
    'section',
  };

  static EpubHtmlDocument parse(String html) {
    final blocks = <EpubHtmlBlock>[];
    final output = StringBuffer();
    final listStack = <bool>[];
    final listIndexes = <int>[];
    final tagPattern = RegExp(r'<[^>]*>|[^<]+', multiLine: true);
    var pending = StringBuffer();
    var pendingType = EpubHtmlBlockType.text;

    void flush([EpubHtmlBlockType? type]) {
      final value = _clean(pending.toString());
      pending = StringBuffer();
      final blockType = type ?? pendingType;
      pendingType = EpubHtmlBlockType.text;
      if (value.isEmpty) return;
      final block = EpubHtmlBlock(
        type: blockType,
        text: value,
        level: blockType == EpubHtmlBlockType.heading ? 1 : null,
        ordered: listStack.isNotEmpty && listStack.last,
        index: listIndexes.isNotEmpty ? listIndexes.last : null,
      );
      blocks.add(block);
      if (output.isNotEmpty) output.write('\n');
      if (blockType == EpubHtmlBlockType.listItem) {
        output.write(block.ordered ? '${block.index}. ' : '• ');
      }
      output.write(value);
    }

    for (final match in tagPattern.allMatches(html)) {
      final token = match.group(0)!;
      if (!token.startsWith('<')) {
        pending.write(_decodeEntities(token));
        continue;
      }
      final tagMatch = RegExp(r'^<\s*(/?)\s*([a-z0-9]+)', caseSensitive: false)
          .firstMatch(token);
      if (tagMatch == null) continue;
      final closing = tagMatch.group(1) == '/';
      final tag = tagMatch.group(2)!.toLowerCase();
      if (tag == 'br' && !closing) {
        flush();
        blocks.add(
            const EpubHtmlBlock(type: EpubHtmlBlockType.lineBreak, text: '\n'));
        if (!output.toString().endsWith('\n')) output.write('\n');
      } else if (tag.startsWith('h') && tag.length == 2 && !closing) {
        flush();
        pending = StringBuffer();
      } else if (tag.startsWith('h') && tag.length == 2 && closing) {
        final level = int.tryParse(tag.substring(1)) ?? 1;
        final value = _clean(pending.toString());
        pending = StringBuffer();
        if (value.isNotEmpty) {
          blocks.add(EpubHtmlBlock(
              type: EpubHtmlBlockType.heading, text: value, level: level));
          if (output.isNotEmpty) output.write('\n');
          output.write(value);
        }
      } else if (tag == 'li' && !closing) {
        flush();
        if (listIndexes.isNotEmpty) listIndexes[listIndexes.length - 1]++;
        pending = StringBuffer();
        pendingType = EpubHtmlBlockType.listItem;
      } else if (tag == 'li' && closing) {
        flush(EpubHtmlBlockType.listItem);
      } else if ((tag == 'ol' || tag == 'ul') && !closing) {
        flush();
        listStack.add(tag == 'ol');
        listIndexes.add(0);
      } else if ((tag == 'ol' || tag == 'ul') && closing) {
        flush();
        if (listStack.isNotEmpty) listStack.removeLast();
        if (listIndexes.isNotEmpty) listIndexes.removeLast();
      } else if (_blockTags.contains(tag) && closing) {
        flush(EpubHtmlBlockType.paragraph);
      } else if (_blockTags.contains(tag) && !closing) {
        flush();
        pendingType = EpubHtmlBlockType.paragraph;
      }
    }
    flush();
    final text = output.toString().replaceAll(RegExp(r'\n+'), '\n').trim();
    return EpubHtmlDocument(blocks: blocks, text: text);
  }

  static String _clean(String value) =>
      value.replaceAll(RegExp(r'\s+'), ' ').replaceAll(' \n', '\n').trim();

  static String _decodeEntities(String value) => value
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
}
