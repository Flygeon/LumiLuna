import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../models/media_item.dart';
import '../models/media_type.dart';
import '../main.dart';
import 'play_history_provider.dart';

/// How the playlist advances when a track finishes.
///
/// [sequential] — stop at end of playlist (or wrap if media_kit's own mode is
///                `loop`, but we do not enable that here).
/// [loop]       — replay the current track forever.
/// [shuffle]    — jump to a random track on completion.
enum PlaybackMode {
  sequential,
  loop,
  shuffle;

  /// Advance to the next mode in the cycle.
  PlaybackMode get next {
    switch (this) {
      case PlaybackMode.sequential:
        return PlaybackMode.loop;
      case PlaybackMode.loop:
        return PlaybackMode.shuffle;
      case PlaybackMode.shuffle:
        return PlaybackMode.sequential;
    }
  }
}

/// Immutable snapshot of the current playback session.
class PlaybackState {
  final List<MediaItem> playlist;
  final int index;
  final bool playing;
  final PlaybackMode mode;
  final Duration position;
  final Duration duration;
  final double volume;
  final double rate;

  const PlaybackState({
    this.playlist = const [],
    this.index = -1,
    this.playing = false,
    this.mode = PlaybackMode.sequential,
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

  /// True when the playlist is set to repeat the current track forever.
  bool get looping => mode == PlaybackMode.loop;

  /// True when the next track is picked at random.
  bool get shuffling => mode == PlaybackMode.shuffle;

  PlaybackState copyWith({
    List<MediaItem>? playlist,
    int? index,
    bool? playing,
    PlaybackMode? mode,
    Duration? position,
    Duration? duration,
    double? volume,
    double? rate,
  }) {
    return PlaybackState(
      playlist: playlist ?? this.playlist,
      index: index ?? this.index,
      playing: playing ?? this.playing,
      mode: mode ?? this.mode,
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
  final Random _random = Random();

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
    // When a track completes naturally and shuffle is on, jump to a random
    // track instead of letting media_kit proceed sequentially.  We force
    // PlaylistMode.none while shuffling so that `completed` fires (loop mode
    // would auto-advance and skip our shuffle logic).
    _subs.add(player.stream.completed.listen((completed) async {
      if (!completed || !mounted) return;
      if (state.shuffling && state.playlist.length > 1) {
        await player.jump(_randomIndexExcluding(state.index));
        await player.play();
      }
    }));
  }

  /// Picks a random playlist index different from [exclude].
  int _randomIndexExcluding(int exclude) {
    if (state.playlist.length <= 1) return exclude;
    int idx;
    do {
      idx = _random.nextInt(state.playlist.length);
    } while (idx == exclude);
    return idx;
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

  /// Skip to the next track.  When shuffle is on, jumps to a random index
  /// instead of the sequential next.
  Future<void> next() async {
    if (state.shuffling && state.playlist.length > 1) {
      await player.jump(_randomIndexExcluding(state.index));
      return;
    }
    await player.next();
  }

  /// Skip to the previous track.  When shuffle is on, jumps to a random
  /// index (same as next) since "previous" has no meaningful order in
  /// shuffle mode.
  Future<void> previous() async {
    if (state.shuffling && state.playlist.length > 1) {
      await player.jump(_randomIndexExcluding(state.index));
      return;
    }
    await player.previous();
  }

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
    final next = state.mode == PlaybackMode.loop
        ? PlaybackMode.sequential
        : PlaybackMode.loop;
    await setMode(next);
  }

  /// Toggle shuffle on/off.  When on, PlaylistMode is forced to `none` so
  /// that track completion triggers our random-advance logic (loop mode would
  /// auto-advance sequentially and bypass shuffle).  The user's loop
  /// preference is preserved in [PlaybackState.mode] and restored when
  /// shuffle is turned off.
  Future<void> toggleShuffle() async {
    final next = state.mode == PlaybackMode.shuffle
        ? PlaybackMode.sequential
        : PlaybackMode.shuffle;
    await setMode(next);
  }

  /// Cycle to the next playback mode: sequential → loop → shuffle → …
  Future<void> cyclePlayMode() => setMode(state.mode.next);

  /// Set the playback mode and sync media_kit's playlist mode accordingly.
  ///
  /// Shuffle requires `PlaylistMode.none` so the `completed` event fires and
  /// our random-advance logic runs.  Loop sets `PlaylistMode.loop` so
  /// media_kit auto-restarts the current track.  Sequential uses `none` so
  /// the playlist simply stops at the end (no auto-advance).
  Future<void> setMode(PlaybackMode mode) async {
    state = state.copyWith(mode: mode);
    final PlaylistMode playlistMode;
    switch (mode) {
      case PlaybackMode.loop:
        playlistMode = PlaylistMode.loop;
        break;
      case PlaybackMode.shuffle:
      case PlaybackMode.sequential:
        playlistMode = PlaylistMode.none;
        break;
    }
    await player.setPlaylistMode(playlistMode);
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
