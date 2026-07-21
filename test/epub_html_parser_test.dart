import 'package:flutter_test/flutter_test.dart';
import 'package:lumiluna/services/epub_html_parser.dart';
import 'package:lumiluna/models/epub_html_model.dart';

void main() {
  test('保留段落、br、标题和列表的结构化换行', () {
    final document = EpubHtmlParser.parse(
      '<h2>标题</h2><p>第一行<br>第二行</p>'
      '<ul><li>项目一</li><li>项目二</li></ul>'
      '<ol><li>步骤一</li><li>步骤二</li></ol>',
    );

    expect(
      document.blocks.map((block) => block.type).toList(),
      [
        EpubHtmlBlockType.heading,
        EpubHtmlBlockType.paragraph,
        EpubHtmlBlockType.lineBreak,
        EpubHtmlBlockType.paragraph,
        EpubHtmlBlockType.listItem,
        EpubHtmlBlockType.listItem,
        EpubHtmlBlockType.listItem,
        EpubHtmlBlockType.listItem,
      ],
    );
    expect(document.text, '标题\n第一行\n第二行\n• 项目一\n• 项目二\n1. 步骤一\n2. 步骤二');
  });

  test('搜索模型按大小写不敏感匹配并提供上下文', () {
    final document = EpubHtmlParser.parse('<p>Hello EPUB reader</p>');

    final matches = document.search('epub');

    expect(matches.length, 1);
    expect(matches.single.start, 6);
    expect(matches.single.end, 10);
    expect(matches.single.preview, contains('Hello EPUB reader'));
  });
}
