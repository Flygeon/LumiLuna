import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../models/media_item.dart';
import '../models/media_type.dart';
import '../main.dart';
import 'play_history_provider.dart';

/// Immutable snapshot of the current playback session.
class PlaybackState {
  final List<MediaItem> playlist;
  final int index;
  final bool playing;
  final bool looping;
  final Duration position;
  final Duration duration;
  final double volume;
  final double rate;

  const PlaybackState({
    this.playlist = const [],
    this.index = -1,
    this.playing = false,
    this.looping = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 100,
    this.rate = 1,
  });

  MediaItem? get current =>
      (index >= 0 && index < playlist.length) ? playlist[index] : null;

  bool isPlayingAudio(String path) =>
      playing && current?.type == MediaType.audio && current?.path == path;

  bool get hasNext => index >= 0 && index < playlist.length - 1;
  bool get hasPrevious => index > 0;

  PlaybackState copyWith({
    List<MediaItem>? playlist,
    int? index,
    bool? playing,
    bool? looping,
    Duration? position,
    Duration? duration,
    double? volume,
    double? rate,
  }) {
    return PlaybackState(
      playlist: playlist ?? this.playlist,
      index: index ?? this.index,
      playing: playing ?? this.playing,
      looping: looping ?? this.looping,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      rate: rate ?? this.rate,
    );
  }
}

/// Owns the shared [media_kit] player used for both video and audio playback,
/// enabling seamless switching between media types.
class PlaybackController extends StateNotifier<PlaybackState> {
  PlaybackController({this.onPlay}) : super(const PlaybackState()) {
    _bind();
  }

  final Player player = Player();
  late final VideoController videoController = VideoController(player);
  final Future<void> Function(String path)? onPlay;

  final List<StreamSubscription> _subs = [];

  void _bind() {
    _subs.add(player.stream.playing.listen((v) {
      if (mounted) state = state.copyWith(playing: v);
    }));
    _subs.add(player.stream.position.listen((v) {
      if (mounted) state = state.copyWith(position: v);
    }));
    _subs.add(player.stream.duration.listen((v) {
      if (mounted) state = state.copyWith(duration: v);
    }));
    _subs.add(player.stream.playlist.listen((pl) {
      if (!mounted) return;
      final previous = state.index;
      state = state.copyWith(index: pl.index);
      if (pl.index != previous &&
          pl.index >= 0 &&
          pl.index < state.playlist.length) {
        onPlay?.call(state.playlist[pl.index].path);
      }
    }));
    _subs.add(player.stream.volume.listen((v) {
      if (mounted) state = state.copyWith(volume: v);
    }));
  }

  /// Open a playlist starting at [startIndex] and begin playback.
  Future<void> openPlaylist(List<MediaItem> items, int startIndex) async {
    if (items.isEmpty) return;
    final safeIndex = startIndex.clamp(0, items.length - 1);
    state = state.copyWith(
      playlist: items,
      index: safeIndex,
      position: Duration.zero,
      duration: Duration.zero,
    );
    await player.open(
      Playlist(
        items.map((e) => Media(e.path)).toList(),
        index: safeIndex,
      ),
    );
    await onPlay?.call(items[safeIndex].path);
  }

  Future<void> openAudioPlaylist(
    List<MediaItem> items,
    int startIndex,
  ) async {
    if (items.isEmpty) return;
    final safeIndex = startIndex.clamp(0, items.length - 1);
    if (state.isPlayingAudio(items[safeIndex].path)) return;
    await stop();
    await openPlaylist(items, safeIndex);
  }

  Future<void> playOrPause() => player.playOrPause();
  Future<void> play() => player.play();
  Future<void> pause() => player.pause();
  Future<void> next() => player.next();
  Future<void> previous() => player.previous();
  Future<void> jump(int index) => player.jump(index);
  Future<void> seek(Duration position) => player.seek(position);

  Future<void> setVolume(double volume) async {
    final next = volume.clamp(0, 100).toDouble();
    state = state.copyWith(volume: next);
    await player.setVolume(next);
  }

  Future<void> setRate(double rate) async {
    final next = rate.clamp(0.5, 2).toDouble();
    state = state.copyWith(rate: next);
    await player.setRate(next);
  }

  Future<void> toggleLoop() async {
    final looping = !state.looping;
    state = state.copyWith(looping: looping);
    await player.setPlaylistMode(
      looping ? PlaylistMode.loop : PlaylistMode.none,
    );
  }

  Future<void> stop() async {
    await player.stop();
    state = const PlaybackState();
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    player.dispose();
    super.dispose();
  }
}

final playbackControllerProvider =
    StateNotifierProvider<PlaybackController, PlaybackState>(
  (ref) {
    final db = ref.watch(appDatabaseProvider);
    return PlaybackController(
      onPlay: (path) async {
        await db.recordPlay(path);
        ref.invalidate(playHistoryProvider);
      },
    );
  },
);

/// Lightweight provider that only changes when the *current track identity*
/// changes (track path).  It does NOT fire on position ticks, volume changes,
/// or play/pause toggles — making it safe for lyrics / artwork / metadata
/// providers that should not rebuild 60 times per second.
final currentMediaProvider = Provider<MediaItem?>((ref) {
  return ref.watch(
    playbackControllerProvider.select((s) => s.current),
  );
});
