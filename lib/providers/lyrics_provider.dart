import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/lyrics_service.dart';
import '../services/lyrics_translation_service.dart';
import 'player_provider.dart';

/// Raw LRC (or plain-text) lyric string for the currently playing audio track.
///
/// Decoupled from position ticks: depends on [currentMediaProvider] which
/// only changes when the track identity changes — NOT on every position
/// update.  Returns the raw string so that flutter_lyric's LyricController
/// can parse it internally (it needs the raw text to support translation
/// merging and QRC conversion).
final lyricsProvider = FutureProvider<String?>((ref) async {
  final current = ref.watch(currentMediaProvider);
  if (current == null) return null;
  if (current.type.name != 'audio') return null;
  return LyricsService.loadRawLyrics(current.path);
});

/// Whether the currently playing track has any lyrics at all.
/// Used by the UI to decide whether to show the lyrics tab.
final hasLyricsProvider = FutureProvider<bool>((ref) async {
  final lyrics = await ref.watch(lyricsProvider.future);
  return lyrics != null && lyrics.trim().isNotEmpty;
});

/// Translation LRC text for the current track, or `null` if no translation
/// sidecar file exists.  Looked up by [LyricsTranslationService] using
/// convention-based filenames (.zh.lrc, .translation.lrc, …).
final lyricsTranslationProvider = FutureProvider<String?>((ref) async {
  final current = ref.watch(currentMediaProvider);
  if (current == null) return null;
  if (current.type.name != 'audio') return null;
  return LyricsTranslationService.load(current.path);
});
