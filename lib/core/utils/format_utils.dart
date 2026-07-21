import 'package:intl/intl.dart';

/// Formatting helpers for file size, dates and durations.
class FormatUtils {
  FormatUtils._();

  /// Human-readable file size, e.g. "1.5 MB".
  static String fileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    final str = unit == 0 ? size.toStringAsFixed(0) : size.toStringAsFixed(1);
    return '$str ${units[unit]}';
  }

  /// Full date-time, e.g. "2026-07-15 20:31".
  static String dateTime(DateTime dt) =>
      DateFormat('yyyy-MM-dd HH:mm').format(dt);

  /// Date only, e.g. "2026-07-15".
  static String date(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  /// Month grouping key, e.g. "2026-07".
  static String monthKey(DateTime dt) => DateFormat('yyyy-MM').format(dt);

  /// Month label, e.g. "2026年7月".
  static String monthLabel(DateTime dt) => '${dt.year}年${dt.month}月';

  /// Duration as mm:ss or h:mm:ss.
  static String duration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$mm:$ss';
    }
    return '$mm:$ss';
  }
}
