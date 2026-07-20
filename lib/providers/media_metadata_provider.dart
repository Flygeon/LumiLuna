import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/media_metadata.dart';

/// Lazily loads [MediaMetadata] for a given media path from the database.
///
/// Only fetched when the user opens the image detail dialog or video player,
/// keeping in-memory [MediaItem] objects small.
final mediaMetadataProvider =
    FutureProvider.family<MediaMetadata?, String>((ref, mediaPath) async {
  final db = ref.read(appDatabaseProvider);
  return db.getMediaMetadata(mediaPath);
});
