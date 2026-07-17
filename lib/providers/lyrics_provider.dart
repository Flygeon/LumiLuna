import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lyrics.dart';
import '../services/lyrics_service.dart';
import 'player_provider.dart';

/// Lyrics for the currently playing audio track.
final lyricsProvider = FutureProvider<Lyrics?>((ref) async {
  final state = ref.watch(playbackControllerProvider);
  final current = state.current;
  if (current == null) return null;
  // Only audio tracks can have lyrics.
  if (current.type.name != 'audio') return null;
  return LyricsService.load(current.path);
});
