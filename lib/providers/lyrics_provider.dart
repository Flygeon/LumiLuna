import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lyrics.dart';
import '../services/lyrics_service.dart';
import 'player_provider.dart';

/// Lyrics for the currently playing audio track.
///
/// IMPORTANT: This provider depends on [currentMediaProvider] (a lightweight
/// selector that ONLY changes when the current track changes), NOT on the
/// full [playbackControllerProvider] which fires on every position tick.
/// This prevents lyrics from being reloaded/rebuild every frame.
final lyricsProvider = FutureProvider<Lyrics?>((ref) async {
  final current = ref.watch(currentMediaProvider);
  if (current == null) return null;
  if (current.type.name != 'audio') return null;
  return LyricsService.load(current.path);
});
