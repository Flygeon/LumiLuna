import 'package:flutter_test/flutter_test.dart';
import 'package:lumiluna/services/lyrics_parser.dart';

void main() {
  group('parseLrcWithTranslation - basic parsing', () {
    test('single timestamp + text', () {
      final m = parseLrcWithTranslation('[00:10.50]hello');
      expect(m.lines.length, 1);
      expect(m.lines.first.start.inMilliseconds, 10500);
      expect(m.lines.first.text, 'hello');
      expect(m.lines.first.translation, isNull);
    });

    test('multi-timestamp line expands to multiple entries', () {
      final m = parseLrcWithTranslation('[01:23.45][02:34.56]refrain');
      expect(m.lines.length, 2);
      expect(m.lines[0].text, 'refrain');
      expect(m.lines[0].start.inMilliseconds, 83450);
      expect(m.lines[1].text, 'refrain');
      expect(m.lines[1].start.inMilliseconds, 154560);
    });

    test('ID tags extracted', () {
      final m = parseLrcWithTranslation(
        '[ti:Song Title]\n[ar:Artist]\n[00:01.00]lyric\n',
      );
      expect(m.idTags['ti'], 'Song Title');
      expect(m.idTags['ar'], 'Artist');
      expect(m.lines.length, 1);
    });

    test('colon-separated fraction (NetEase format)', () {
      // [01:23:45] — 网易云格式用冒号分隔毫秒部分
      final m = parseLrcWithTranslation('[01:23:45]hello');
      expect(m.lines.first.start.inMilliseconds, 83450);
    });
  });

  group('millisecond precision (the padRight bug)', () {
    test('1-digit fraction = deciseconds', () {
      // [00:01.4] → 1.4 秒 = 1400ms（不是 400ms，也不是 4ms）
      final m = parseLrcWithTranslation('[00:01.4]x');
      expect(m.lines.first.start.inMilliseconds, 1400);
    });

    test('2-digit fraction = centiseconds (LRC standard)', () {
      // [00:01.45] → 1.45 秒 = 1450ms
      // flutter_lyric 3.0.7 的 padRight 会把它解析成 14500ms（10× 偏移）！
      final m = parseLrcWithTranslation('[00:01.45]x');
      expect(m.lines.first.start.inMilliseconds, 1450);
    });

    test('3-digit fraction = milliseconds', () {
      final m = parseLrcWithTranslation('[00:01.456]x');
      expect(m.lines.first.start.inMilliseconds, 1456);
    });

    test('no fraction = 0ms', () {
      final m = parseLrcWithTranslation('[00:01]x');
      expect(m.lines.first.start.inMilliseconds, 1000);
    });

    test('fraction with more than 3 digits is truncated safely', () {
      // 极罕见但不应抛异常
      final m = parseLrcWithTranslation('[00:01.4567]x');
      expect(m.lines.first.start.inMilliseconds, 1456);
    });
  });

  group('translation fuzzy matching (the strict-match bug)', () {
    test('exact match', () {
      final m = parseLrcWithTranslation(
        '[00:10.50]original',
        translationLyric: '[00:10.50]translation',
      );
      expect(m.lines.first.translation, 'translation');
    });

    test('drift within tolerance (+5ms)', () {
      final m = parseLrcWithTranslation(
        '[00:10.500]original',
        translationLyric: '[00:10.505]translation',
      );
      expect(m.lines.first.translation, 'translation');
    });

    test('drift within tolerance (-5ms)', () {
      final m = parseLrcWithTranslation(
        '[00:10.505]original',
        translationLyric: '[00:10.500]translation',
      );
      expect(m.lines.first.translation, 'translation');
    });

    test('drift at tolerance boundary (+20ms) is accepted', () {
      final m = parseLrcWithTranslation(
        '[00:10.500]original',
        translationLyric: '[00:10.520]translation',
      );
      expect(m.lines.first.translation, 'translation');
    });

    test('drift at tolerance boundary (-20ms) is accepted', () {
      final m = parseLrcWithTranslation(
        '[00:10.520]original',
        translationLyric: '[00:10.500]translation',
      );
      expect(m.lines.first.translation, 'translation');
    });

    test('drift beyond tolerance (+25ms) is dropped', () {
      final m = parseLrcWithTranslation(
        '[00:10.500]original',
        translationLyric: '[00:10.525]translation',
      );
      expect(m.lines.first.translation, isNull);
    });

    test('drift beyond tolerance (-25ms) is dropped', () {
      final m = parseLrcWithTranslation(
        '[00:10.525]original',
        translationLyric: '[00:10.500]translation',
      );
      expect(m.lines.first.translation, isNull);
    });

    test('prefers the earlier translation when equidistant', () {
      // main = 10500, candidates at 10490 (距离 10) 和 10510 (距离 10)
      // 等距时应优先前一个，匹配"翻译紧跟原文之后"的视觉直觉。
      final m = parseLrcWithTranslation(
        '[00:10.500]original',
        translationLyric:
            '[00:10.490]before\n[00:10.510]after',
      );
      expect(m.lines.first.translation, 'before');
    });

    test('mixed precision between main and translation', () {
      // 主 LRC 用 2 位小数（1450ms），翻译用 3 位小数（1450ms）— 应匹配
      final m = parseLrcWithTranslation(
        '[00:01.45]original',
        translationLyric: '[00:01.450]translation',
      );
      expect(m.lines.first.translation, 'translation');
    });

    test('empty translation file', () {
      final m = parseLrcWithTranslation('[00:01.00]x', translationLyric: '');
      expect(m.lines.first.translation, isNull);
    });

    test('null translation file', () {
      final m = parseLrcWithTranslation('[00:01.00]x');
      expect(m.lines.first.translation, isNull);
    });

    test('whitespace-only translation file', () {
      final m = parseLrcWithTranslation(
        '[00:01.00]x',
        translationLyric: '   \n\n  \t  ',
      );
      expect(m.lines.first.translation, isNull);
    });

    test('translation with extra unmatched entries', () {
      final m = parseLrcWithTranslation(
        '[00:10.50]original',
        translationLyric: '[00:10.50]match\n[00:99.99]orphan',
      );
      expect(m.lines.first.translation, 'match');
      expect(m.lines.length, 1); // orphan 不应进入 main
    });

    test('translation "//" lines are ignored', () {
      final m = parseLrcWithTranslation(
        '[00:10.50]original',
        translationLyric: '[00:10.50]//\n[00:10.50]real',
      );
      // "//" 行被跳过；第二条 10500 的翻译被采纳
      expect(m.lines.first.translation, 'real');
    });
  });

  group('edge cases', () {
    test('lines without timestamps are skipped', () {
      final m = parseLrcWithTranslation('just plain text\n[00:01.00]ok');
      expect(m.lines.length, 1);
      expect(m.lines.first.text, 'ok');
    });

    test('empty lines ignored', () {
      final m = parseLrcWithTranslation('\n\n[00:01.00]x\n\n');
      expect(m.lines.length, 1);
    });

    test('timestamp-only lines (instrumental markers) skipped', () {
      final m = parseLrcWithTranslation('[00:01.00]\n[00:02.00]lyric');
      expect(m.lines.length, 1);
      expect(m.lines.first.text, 'lyric');
    });

    test('lines sorted by start time', () {
      final m = parseLrcWithTranslation(
        '[00:20.00]c\n[00:10.00]a\n[00:15.00]b',
      );
      expect(m.lines.map((l) => l.text).toList(), ['a', 'b', 'c']);
    });

    test('empty input', () {
      final m = parseLrcWithTranslation('');
      expect(m.lines, isEmpty);
      expect(m.idTags, isEmpty);
    });

    test('only ID tags, no lyrics', () {
      final m = parseLrcWithTranslation('[ti:Title]\n[ar:Artist]');
      expect(m.lines, isEmpty);
      expect(m.idTags['ti'], 'Title');
      expect(m.idTags['ar'], 'Artist');
    });

    test('multi-timestamp line with translation applies to all expansions', () {
      final m = parseLrcWithTranslation(
        '[01:23.45][02:34.56]refrain',
        translationLyric:
            '[01:23.45]trans1\n[02:34.56]trans2',
      );
      expect(m.lines.length, 2);
      expect(m.lines[0].translation, 'trans1');
      expect(m.lines[1].translation, 'trans2');
    });
  });

  group('inline bilingual pairing', () {
    test('Japanese and Chinese rows with same timestamp become one line', () {
      final model = parseLrcWithTranslation(
        '[00:10.50]浅く夕立を 絶った跡\n'
        '[00:10.50]浅浅地穿过 骤雨的痕迹\n'
        '[00:15.00]透いた瞳で 浮いている',
      );

      expect(model.lines.length, 2);
      expect(model.lines[0].text, '浅く夕立を 絶った跡');
      expect(model.lines[0].translation, '浅浅地穿过 骤雨的痕迹');
      expect(model.lines[0].words, isNotNull);
      expect(model.lines[0].words!.length, greaterThan(2));
      expect(model.lines[1].text, '透いた瞳で 浮いている');
      expect(model.lines[1].translation, isNull);
    });

    test('nearby inline translation within tolerance is paired', () {
      final model = parseLrcWithTranslation(
        '[00:10.500]浅く夕立を 絶った跡\n'
        '[00:10.580]浅浅地穿过 骤雨的痕迹',
      );
      expect(model.lines.length, 1);
      expect(model.lines.first.translation, '浅浅地穿过 骤雨的痕迹');
    });

    test('other languages remain independent rows', () {
      final model = parseLrcWithTranslation(
        '[00:10.50]Hello world\n'
        '[00:10.50]你好世界',
      );
      expect(model.lines.length, 2);
      expect(model.lines[0].translation, isNull);
      expect(model.lines[1].translation, isNull);
    });
  });

  group('user-reported bug scenario (Japanese + Chinese)', () {
    test('each Japanese line paired with its Chinese translation', () {
      const main = '[00:10.50]さんざめく様な 残響が\n'
          '[00:15.00]繋ごうなんて しないまま\n'
          '[00:20.00]網膜の奥で 夏を呼ぶ\n';
      const trans = '[00:10.50]还回荡着轰鸣的 喧闹余音\n'
          '[00:15.00]就那样不曾想要相系\n'
          '[00:20.00]在视网膜深处呼唤着夏日\n';
      final m = parseLrcWithTranslation(main, translationLyric: trans);
      expect(m.lines.length, 3);
      expect(m.lines[0].text, 'さんざめく様な 残響が');
      expect(m.lines[0].translation, '还回荡着轰鸣的 喧闹余音');
      expect(m.lines[1].text, '繋ごうなんて しないまま');
      expect(m.lines[1].translation, '就那样不曾想要相系');
      expect(m.lines[2].text, '網膜の奥で 夏を呼ぶ');
      expect(m.lines[2].translation, '在视网膜深处呼唤着夏日');
    });

    test('drift between JP main and CN translation is absorbed by tolerance', () {
      // 模拟真实场景：主 LRC 用 2 位小数（[00:10.50] = 10500ms），
      // 翻译 LRC 用 3 位小数（[00:10.500] = 10500ms）— 一致，但若翻译
      // 是 [00:10.510] = 10510ms（漂移 10ms）也应匹配。
      const main = '[00:10.50]さんざめく様な 残響が';
      const trans = '[00:10.510]还回荡着轰鸣的 喧闹余音';
      final m = parseLrcWithTranslation(main, translationLyric: trans);
      expect(m.lines.first.translation, '还回荡着轰鸣的 喧闹余音');
    });

    test(
        'regression: no text merging across lines '
        '(the "繋ごうなんて し ないまま" bug)', () {
      // 原生 LrcParser 会因毫秒偏移把翻译错位塞到下一行，导致同一行
      // 同时出现日文和中文片段。验证：每行的 text 严格等于主 LRC 对应行的
      // 原文，translation 严格等于翻译 LRC 对应行的译文 — 二者不混合。
      const main = '[00:10.50]さんざめく様な 残響が\n'
          '[00:15.00]繋ごうなんて しないまま\n';
      const trans = '[00:10.50]还回荡着轰鸣的 喧闹余音\n'
          '[00:15.00]就那样不曾想要相系\n';
      final m = parseLrcWithTranslation(main, translationLyric: trans);

      // 主 LRC 两行 → 解析出两条 LyricLine，每条 text 与原文逐字相等。
      expect(m.lines.length, 2);
      expect(m.lines[0].text, 'さんざめく様な 残響が');
      expect(m.lines[0].translation, '还回荡着轰鸣的 喧闹余音');
      expect(m.lines[1].text, '繋ごうなんて しないまま');
      expect(m.lines[1].translation, '就那样不曾想要相系');

      // 关键回归断言：text 与 translation 不应包含对方的内容。
      // 原先的 bug 会让"繋ごうなんて し ないまま"这种被劈开、译文塞进 text。
      for (final line in m.lines) {
        expect(line.translation, isNotNull);
        expect(line.text.contains(line.translation!), isFalse,
            reason: '原文不应包含译文片段: ${line.text}');
        expect(line.translation!.contains(line.text), isFalse,
            reason: '译文不应包含原文片段: ${line.translation}');
      }
    });
  });
}
