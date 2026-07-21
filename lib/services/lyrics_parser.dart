import 'package:flutter_lyric/core/lyric_model.dart';

/// 自定义 LRC 解析器 — 绕开 `flutter_lyric: 3.0.7` 中 `LrcParser` 的两个缺陷。
///
/// 已修复的上游缺陷（参见 `flutter_lyric-3.0.7/lib/core/lyric_parse.dart`）：
/// 1. **第 83 行严格毫秒匹配**：`translation: translationMap[duration.inMilliseconds]`
///    主 LRC 与翻译 LRC 任何毫秒级漂移都会丢翻译。本解析器用 ±20ms 容差二分查找。
/// 2. **第 145 行毫秒解析错误**：`int.parse(milliseconds.padRight(3, '0'))`
///    对 2 位小数会膨胀（`"50"` → `"500"` = 500ms 而非 50ms）。
///    本解析器按位数显式换算。
///
/// 输出 [LyricModel]，通过 `LyricController.loadLyricModel()` 注入，
/// 复用 `flutter_lyric` 的滚动 / 高亮 / 翻译样式等渲染能力。

/// 翻译匹配容差（毫秒）。
///
/// 同一首歌的主 LRC 与翻译 LRC 经常因编码器或人工编辑存在毫秒级漂移。
/// ±20ms 足以吸收常见漂移，又不会把相邻行错配（典型歌词行间隔 ≥ 1s）。
const int kTranslationToleranceMs = 20;

/// ID 标签正则：匹配 `[ti:...]`、`[ar:...]` 等。
/// `\D` 确保 `[01:23.45]` 这类时间戳不会被误识别为 ID 标签。
final RegExp _idTagRe = RegExp(r'^\[(\D+?):(.*?)\]');

/// 行内时间戳正则：匹配 `[01:23.45]` / `[01:23.456]` / `[01:23]`，
/// 同时接受点分（`.45`）与冒号分（`:45`，网易格式）两种小数分隔。
/// 小数部分允许 1+ 位（实际常见 2/3 位；超出 3 位时由 [_parseMilliseconds]
/// 截断到 3 位），保证 `[01:23.4567]` 这类罕见格式仍能匹配。
final RegExp _timestampRe = RegExp(r'\[(\d{1,}):(\d{2})(?:[.:](\d+))?\]');

/// 解析主歌词 + 翻译歌词，返回 [LyricModel]。
///
/// 主歌词中的每一行：
/// - 形如 `[ti:...]` / `[ar:...]` 的写入 [LyricModel.idTags]
/// - `[01:23.45]text` 解析为一条 [LyricLine]
/// - `[01:23.45][02:34.56]text` 展开为两条 [LyricLine]（同 text、不同 start）
/// - 无时间戳的行跳过
///
/// 翻译歌词通过 [_findTranslation] 进行 ±[kTranslationToleranceMs]ms 容差匹配，
/// 匹配失败的翻译行被忽略（符合"翻译是主 LRC 的附属"语义）。
LyricModel parseLrcWithTranslation(
  String mainLyric, {
  String? translationLyric,
}) {
  final idTags = <String, String>{};
  final parsedLines = <_ParsedLine>[];
  final translations = _parseTranslationEntries(translationLyric);

  for (final rawLine in mainLyric.split('\n')) {
    // 1. ID 标签行（[ti:...] / [ar:...] 等）
    final tagMatch = _idTagRe.firstMatch(rawLine);
    if (tagMatch != null) {
      final key = tagMatch.group(1)!.trim();
      final value = tagMatch.group(2)!.trim();
      if (key.isNotEmpty) idTags[key] = value;
      continue;
    }

    // 2. 提取行内所有时间戳（支持一行多时间戳）
    final timestamps = _extractTimestamps(rawLine);
    if (timestamps.isEmpty) continue;

    // 3. 剥除时间戳后取剩余文本
    final text = rawLine.replaceAll(_timestampRe, '').trim();
    if (text.isEmpty) continue; // 纯时间戳行（如间奏标记）跳过

    // 4. 暂存主歌词行；翻译在后续统一匹配，便于同时兼容：
    //    a) 独立 translationLyric 文件；
    //    b) 主 LRC 内原文/译文相邻成对的写法。
    for (final duration in timestamps) {
      parsedLines.add(_ParsedLine(start: duration, text: text));
    }
  }

  parsedLines.sort((a, b) => a.start.compareTo(b.start));

  // 先合并独立翻译文件；如果没有命中，再尝试识别主 LRC 中相邻的
  // "原文行 + 中文翻译行"。这样不会改变单语歌词或已有翻译的行为。
  final lines = <LyricLine>[];
  for (var i = 0; i < parsedLines.length; i++) {
    final current = parsedLines[i];
    final translation = _findTranslation(translations, current.start) ??
        _findInlineTranslation(parsedLines, i);
    final words = _buildApproximateWords(
      current.text,
      current.start,
      _nextStart(parsedLines, i),
    );
    lines.add(LyricLine(
      start: current.start,
      text: current.text,
      translation: translation,
      words: words,
    ));
  }

  // 内嵌双语歌词的译文行不再作为独立主歌词显示。
  final filteredLines = _removeInlineTranslationRows(lines, parsedLines);
  return LyricModel(lines: filteredLines, tags: idTags);
}

/// 解析翻译歌词为按时间排序的翻译条目列表。
///
/// 跳过 ID 标签行与空文本行（`//`、空字符串）。
List<_TranslationEntry> _parseTranslationEntries(String? translationLyric) {
  if (translationLyric == null || translationLyric.trim().isEmpty) {
    return const [];
  }
  final result = <_TranslationEntry>[];
  for (final rawLine in translationLyric.split('\n')) {
    if (_idTagRe.firstMatch(rawLine) != null) continue;
    final timestamps = _extractTimestamps(rawLine);
    if (timestamps.isEmpty) continue;
    final text = rawLine.replaceAll(_timestampRe, '').trim();
    if (text.isEmpty || text == '//') continue;
    for (final duration in timestamps) {
      result.add(_TranslationEntry(duration.inMilliseconds, text));
    }
  }
  result.sort((a, b) => a.ms.compareTo(b.ms));
  return result;
}

/// 从一行文本中提取所有时间戳，按出现顺序返回。
///
/// 支持 `[01:23.45]` / `[01:23.456]` / `[01:23]` / `[01:23:45]`（网易冒号格式）。
/// 同一行多时间戳 `[01:23.45][02:34.56]` 会被全部提取。
List<Duration> _extractTimestamps(String line) {
  final matches = _timestampRe.allMatches(line);
  final result = <Duration>[];
  for (final m in matches) {
    final minutes = int.parse(m.group(1)!);
    final seconds = int.parse(m.group(2)!);
    final ms = _parseMilliseconds(m.group(3));
    result.add(Duration(
      minutes: minutes,
      seconds: seconds,
      milliseconds: ms,
    ));
  }
  return result;
}

/// 按 LRC 标准正确解析小数部分到毫秒：
///   - 3 位（`.456`）→ 456ms（毫秒精度）
///   - 2 位（`.45`） → 450ms（厘秒精度，LRC 标准常用）
///   - 1 位（`.4`）  → 400ms（分秒精度）
///   - 缺省          → 0ms
///
/// 不使用 `padRight(3, '0')` — 那会把 2 位 `45` 膨胀成 `450` 后再被 `int.parse`
/// 当作 450ms（正确），但更危险的是 `5` 被膨胀成 `500` 而非 `50`，导致 10× 偏移。
/// 直接按位数计算更明确、更安全。
int _parseMilliseconds(String? msStr) {
  if (msStr == null || msStr.isEmpty) return 0;
  switch (msStr.length) {
    case 1:
      return int.parse(msStr) * 100;
    case 2:
      return int.parse(msStr) * 10;
    case 3:
      return int.parse(msStr);
    default:
      // 超过 3 位（极罕见）截断到前 3 位，避免 int.parse 抛异常
      return int.parse(msStr.substring(0, 3));
  }
}

/// 二分查找距离 [main] 最近的翻译条目。
///
/// 仅当距离 ≤ [kTranslationToleranceMs]ms 才返回翻译文本，否则返回 `null`。
/// 若前一个（≤ main）和后一个（> main）候选距离相等，优先选前一个 —
/// 匹配"翻译紧跟原文之后"的视觉直觉。
String? _findTranslation(List<_TranslationEntry> translations, Duration main) {
  if (translations.isEmpty) return null;
  final ms = main.inMilliseconds;

  // 标准二分：找到第一个 translations[i].ms >= ms 的位置
  int lo = 0, hi = translations.length;
  while (lo < hi) {
    final mid = (lo + hi) >> 1;
    if (translations[mid].ms < ms) {
      lo = mid + 1;
    } else {
      hi = mid;
    }
  }
  // lo 是第一个 >= ms 的索引；lo-1 是最后一个 < ms 的索引

  String? best;
  int bestDist = kTranslationToleranceMs + 1; // 容差外的哨兵值

  // 候选 1：前一个（<= ms）
  if (lo > 0) {
    final d = ms - translations[lo - 1].ms;
    if (d <= bestDist) {
      bestDist = d;
      best = translations[lo - 1].text;
    }
  }
  // 候选 2：后一个（>= ms）— 用严格 `<` 保证等距时优先前一个
  if (lo < translations.length) {
    final d = translations[lo].ms - ms;
    if (d < bestDist) {
      best = translations[lo].text;
    }
  }
  return best;
}

/// 内嵌双语的识别容差。内嵌翻译通常与原文共享时间戳，部分来源会有
/// 少量偏移；不能放得太大，否则普通相邻歌词可能被误合并。
const int _inlineTranslationToleranceMs = 120;

class _ParsedLine {
  final Duration start;
  final String text;

  const _ParsedLine({required this.start, required this.text});
}

Duration? _nextStart(List<_ParsedLine> lines, int index) {
  final current = lines[index].start;
  for (var i = index + 1; i < lines.length; i++) {
    if (lines[i].start > current) return lines[i].start;
  }
  return null;
}

/// 判断一行是否更像中文翻译，而不是原文。
/// 只在同时存在日文假名和中文字符时启用合并，避免破坏英文、韩文、
/// 西里尔文等其他语言的既有逐行显示逻辑。
bool _isChineseTranslation(String text) {
  final hasHan = RegExp(r'[\u4e00-\u9fff]').hasMatch(text);
  final hasJapaneseKana =
      RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text);
  return hasHan && !hasJapaneseKana;
}

bool _isJapaneseOriginal(String text) {
  return RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text);
}

String? _findInlineTranslation(List<_ParsedLine> lines, int index) {
  if (index + 1 >= lines.length) return null;
  final current = lines[index];
  final next = lines[index + 1];
  final delta = next.start.inMilliseconds - current.start.inMilliseconds;
  if (delta < 0 || delta > _inlineTranslationToleranceMs) return null;
  if (!_isJapaneseOriginal(current.text) || !_isChineseTranslation(next.text)) {
    return null;
  }
  return next.text;
}

List<LyricWord>? _buildApproximateWords(
  String text,
  Duration start,
  Duration? nextStart,
) {
  if (text.isEmpty) return null;
  final end = nextStart ?? (start + const Duration(seconds: 3));
  final total = end - start;
  if (total <= Duration.zero) return null;

  // LRC 没有字级时间，只能均匀估算；真实 QRC 会在 flutter_lyric 的
  // QrcParser 中提供精确 LyricWord，此处仅作为 LRC 的安全降级效果。
  final characters = text.runes.map(String.fromCharCode).toList();
  if (characters.length < 2) return null;
  final perWord = total.inMicroseconds ~/ characters.length;
  return characters.asMap().entries.map((entry) {
    final wordStart = start + Duration(microseconds: perWord * entry.key);
    final wordEnd = entry.key == characters.length - 1
        ? end
        : start + Duration(microseconds: perWord * (entry.key + 1));
    return LyricWord(text: entry.value, start: wordStart, end: wordEnd);
  }).toList();
}

List<LyricLine> _removeInlineTranslationRows(
  List<LyricLine> lines,
  List<_ParsedLine> parsedLines,
) {
  if (lines.length != parsedLines.length) return lines;
  final removedKeys = <String>{};
  for (var i = 0; i < parsedLines.length - 1; i++) {
    if (_findInlineTranslation(parsedLines, i) != null) {
      final translationRow = parsedLines[i + 1];
      removedKeys
          .add('${translationRow.start.inMicroseconds}|${translationRow.text}');
    }
  }
  if (removedKeys.isEmpty) return lines;
  return lines
      .where((line) =>
          !removedKeys.contains('${line.start.inMicroseconds}|${line.text}'))
      .toList();
}

/// 内部翻译条目：时间戳（毫秒）+ 翻译文本。
class _TranslationEntry {
  final int ms;
  final String text;
  const _TranslationEntry(this.ms, this.text);
}
