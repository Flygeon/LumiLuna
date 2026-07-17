import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../models/media_item.dart';

final playHistoryProvider =
    FutureProvider<List<MediaItem>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.getPlayHistory(limit: 200);
});
