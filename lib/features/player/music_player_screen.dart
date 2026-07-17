import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format_utils.dart';
import '../../l10n/l10n.dart';
import '../../models/lyrics.dart';
import '../../models/media_item.dart';
import '../../providers/lyrics_provider.dart';
import '../../providers/player_provider.dart';

/// Music player inspired by Apple Music's design language, retaining some
/// Material Design affordances for consistency.
///
/// Features large album artwork, blurred background, synchronized lyrics,
/// playback controls, and the current playlist.
class MusicPlayerScreen extends ConsumerWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when the track or playback mode changes — NOT on every
    // position tick.  Position-sensitive children (seek bar, lyrics) use their
    // own fine-grained subscriptions.
    final state = ref.watch(playbackControllerProvider.select((s) => _PlaybackSummary.fromState(s)));
    final controller = ref.read(playbackControllerProvider.notifier);
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final lyricsAsync = ref.watch(lyricsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.nowPlaying,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<double>(
            tooltip: l10n.playbackSpeed,
            initialValue: state.rate,
            onSelected: controller.setRate,
            itemBuilder: (_) => const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                .map((rate) => PopupMenuItem(
                      value: rate,
                      child: Text('${rate}x'),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('${state.rate}x',
                  style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
      body: state.current == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.music_note_outlined,
                      size: 80, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(l10n.notPlaying,
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            )
          : Stack(
              children: [
                Positioned.fill(child: _buildBackground(state.current!, scheme)),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      return isWide
                          ? _WideLayout(
                              current: state.current!,
                              scheme: scheme,
                              controller: controller,
                              lyricsAsync: lyricsAsync,
                              playlist: state.playlist,
                              playlistIndex: state.index,
                            )
                          : _NarrowLayout(
                              current: state.current!,
                              scheme: scheme,
                              controller: controller,
                              lyricsAsync: lyricsAsync,
                              playlist: state.playlist,
                              playlistIndex: state.index,
                            );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBackground(MediaItem item, ColorScheme scheme) {
    if (item.artworkPath != null) {
      try {
        return Image.file(
          File(item.artworkPath!),
          fit: BoxFit.cover,
          color: Colors.black.withValues(alpha: 0.55),
          colorBlendMode: BlendMode.darken,
        );
      } catch (_) {}
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.surfaceContainerHighest, scheme.surface],
        ),
      ),
    );
  }
}

/// Lightweight summary that changes only when the track / playback mode
/// changes — never on every position tick.
class _PlaybackSummary {
  final MediaItem? current;
  final double rate;
  final bool looping;
  final int index;
  final List<MediaItem> playlist;

  const _PlaybackSummary({
    this.current,
    required this.rate,
    required this.looping,
    required this.index,
    required this.playlist,
  });

  static _PlaybackSummary fromState(PlaybackState s) => _PlaybackSummary(
        current: s.current,
        rate: s.rate,
        looping: s.looping,
        index: s.index,
        playlist: s.playlist,
      );

  @override
  bool operator ==(Object o) =>
      o is _PlaybackSummary &&
      o.current?.path == current?.path &&
      o.rate == rate &&
      o.looping == looping &&
      o.index == index &&
      o.playlist.length == playlist.length &&
      (o.playlist.isEmpty ||
          playlist.isEmpty ||
          o.playlist.first.path == playlist.first.path);

  @override
  int get hashCode => Object.hash(current?.path, rate, looping, index);
}

// ---------------------------------------------------------------------------
// Narrow layout (phones / narrow windows — stacked)
// ---------------------------------------------------------------------------
class _NarrowLayout extends StatelessWidget {
  final MediaItem current;
  final ColorScheme scheme;
  final PlaybackController controller;
  final AsyncValue<Lyrics?> lyricsAsync;
  final List<MediaItem> playlist;
  final int playlistIndex;

  const _NarrowLayout({
    required this.current,
    required this.scheme,
    required this.controller,
    required this.lyricsAsync,
    required this.playlist,
    required this.playlistIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 1),
        _AlbumArt(item: current, maxWidth: 400),
        const SizedBox(height: 24),
        _SongInfo(item: current),
        const SizedBox(height: 20),
        const _PlaybackRegion(),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Wide layout (desktop — left: art + info, right: lyrics + controls)
// ---------------------------------------------------------------------------
class _WideLayout extends StatelessWidget {
  final MediaItem current;
  final ColorScheme scheme;
  final PlaybackController controller;
  final AsyncValue<Lyrics?> lyricsAsync;
  final List<MediaItem> playlist;
  final int playlistIndex;

  const _WideLayout({
    required this.current,
    required this.scheme,
    required this.controller,
    required this.lyricsAsync,
    required this.playlist,
    required this.playlistIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left column: album art + info
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              _AlbumArt(item: current, maxWidth: 360),
              const SizedBox(height: 24),
              _SongInfo(item: current),
              const Spacer(flex: 1),
              const SizedBox(
                width: 360,
                child: _SeekBar(),
              ),
              const SizedBox(height: 8),
              const _Controls(),
              const SizedBox(height: 24),
            ],
          ),
        ),
        // Right column: lyrics / queue
        Expanded(
          flex: 3,
          child: _LyricsOrQueue(
            lyricsAsync: lyricsAsync,
            playlist: playlist,
            playlistIndex: playlistIndex,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Playback region — subscribes to position independently
// ---------------------------------------------------------------------------
class _PlaybackRegion extends ConsumerStatefulWidget {
  const _PlaybackRegion();

  @override
  ConsumerState<_PlaybackRegion> createState() => _PlaybackRegionState();
}

class _PlaybackRegionState extends ConsumerState<_PlaybackRegion> {
  bool _showLyrics = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playbackControllerProvider);
    final lyricsAsync = ref.watch(lyricsProvider);
    final playlist = state.playlist;
    final index = state.index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _SeekBar(),
        const SizedBox(height: 8),
        const _Controls(),
        const SizedBox(height: 16),
        _PanelToggle(
          showLyrics: _showLyrics,
          onToggle: () => setState(() => _showLyrics = !_showLyrics),
        ),
        Flexible(
          flex: 3,
          child: _showLyrics
              ? _buildLyricsPanel(lyricsAsync)
              : _Playlist(playlist: playlist, currentIndex: index),
        ),
      ],
    );
  }

  Widget _buildLyricsPanel(AsyncValue<Lyrics?> async) {
    return async.when(
      data: (lyrics) {
        if (lyrics == null || lyrics.lines.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lyrics_outlined, size: 40, color: Colors.white38),
                SizedBox(height: 8),
                Text('暂无歌词',
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          );
        }
        return _LyricsView(lyrics: lyrics);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) =>
          const Center(child: Text('无法加载歌词', style: TextStyle(color: Colors.white60))),
    );
  }
}

// ---------------------------------------------------------------------------
// Lyrics or Queue panel (used in _WideLayout)
// ---------------------------------------------------------------------------
class _LyricsOrQueue extends ConsumerStatefulWidget {
  final AsyncValue<Lyrics?> lyricsAsync;
  final List<MediaItem> playlist;
  final int playlistIndex;

  const _LyricsOrQueue({
    required this.lyricsAsync,
    required this.playlist,
    required this.playlistIndex,
  });

  @override
  ConsumerState<_LyricsOrQueue> createState() => _LyricsOrQueueState();
}

class _LyricsOrQueueState extends ConsumerState<_LyricsOrQueue> {
  bool _showLyrics = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PanelToggle(
          showLyrics: _showLyrics,
          onToggle: () => setState(() => _showLyrics = !_showLyrics),
        ),
        Expanded(
          child: _showLyrics
              ? _buildLyricsPanel()
              : _Playlist(
                  playlist: widget.playlist,
                  currentIndex: widget.playlistIndex,
                  onTap: (i) => ref.read(playbackControllerProvider.notifier).jump(i),
                ),
        ),
      ],
    );
  }

  Widget _buildLyricsPanel() {
    return widget.lyricsAsync.when(
      data: (lyrics) {
        if (lyrics == null || lyrics.lines.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lyrics_outlined, size: 40, color: Colors.white38),
                SizedBox(height: 8),
                Text('暂无歌词',
                    style: TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          );
        }
        return _LyricsView(lyrics: lyrics);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          const Center(child: Text('无法加载歌词', style: TextStyle(color: Colors.white60))),
    );
  }
}

// ---------------------------------------------------------------------------
// Album Art
// ---------------------------------------------------------------------------
class _AlbumArt extends StatelessWidget {
  final MediaItem item;
  final double maxWidth;

  const _AlbumArt({required this.item, this.maxWidth = 400});

  @override
  Widget build(BuildContext context) {
    final avail = MediaQuery.of(context).size.width * 0.55;
    final size = (avail > maxWidth ? maxWidth : avail).clamp(160.0, maxWidth);
    final borderRadius = BorderRadius.circular(20);
    final shadow = BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 32,
      offset: const Offset(0, 8),
    );

    Widget art;
    if (item.artworkPath != null) {
      art = ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          File(item.artworkPath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => _placeholder(size),
        ),
      );
    } else {
      art = _placeholder(size);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: [shadow]),
      child: art,
    );
  }

  Widget _placeholder(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade700, Colors.grey.shade900],
          ),
        ),
        child: Center(
          child: Icon(Icons.music_note, size: size * 0.35, color: Colors.white38),
        ),
      );
}

// ---------------------------------------------------------------------------
// Song Info
// ---------------------------------------------------------------------------
class _SongInfo extends StatelessWidget {
  final MediaItem item;
  const _SongInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    final title = item.title ?? item.name;
    final subtitle = () {
      final parts = [item.artist, item.album].whereType<String>().toList();
      if (parts.isNotEmpty) return parts.join('  ·  ');
      return item.folderName;
    }();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seek Bar — fine-grained position subscription
// ---------------------------------------------------------------------------
class _SeekBar extends ConsumerWidget {
  const _SeekBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      playbackControllerProvider.select((s) => _SeekState(
        position: s.position,
        duration: s.duration,
      )),
    );
    final controller = ref.read(playbackControllerProvider.notifier);
    final duration = state.duration.inMilliseconds.toDouble();
    final maxValue = duration <= 0 ? 1.0 : duration;
    final position = state.position.inMilliseconds.toDouble().clamp(0.0, maxValue);

    return SizedBox(
      width: 600,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 3,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              overlayColor: Colors.white12,
            ),
            child: Slider(
              value: position,
              max: maxValue,
              onChanged: duration <= 0
                  ? null
                  : (v) => controller.seek(Duration(milliseconds: v.round())),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(FormatUtils.duration(state.position),
                    style: const TextStyle(fontSize: 12, color: Colors.white60)),
                Text(FormatUtils.duration(state.duration),
                    style: const TextStyle(fontSize: 12, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeekState {
  final Duration position;
  final Duration duration;

  const _SeekState({required this.position, required this.duration});

  @override
  bool operator ==(Object o) =>
      o is _SeekState &&
      o.position == position &&
      o.duration == duration;

  @override
  int get hashCode => Object.hash(position, duration);
}

// ---------------------------------------------------------------------------
// Playback Controls
// ---------------------------------------------------------------------------
class _Controls extends ConsumerWidget {
  const _Controls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      playbackControllerProvider.select(
        (s) => _ControlState(
          playing: s.playing,
          looping: s.looping,
          hasPrev: s.hasPrevious,
          hasNext: s.hasNext,
          hasCurrent: s.current != null,
        ),
      ),
    );
    final controller = ref.read(playbackControllerProvider.notifier);
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: l10n.loopTooltip,
          isSelected: state.looping,
          icon: const Icon(Icons.repeat, color: Colors.white70),
          selectedIcon: const Icon(Icons.repeat_on, color: Colors.white),
          onPressed: controller.toggleLoop,
        ),
        const SizedBox(width: 4),
        IconButton(
          iconSize: 36,
          icon: Icon(Icons.skip_previous, color: Colors.white.withValues(alpha: 0.85)),
          onPressed: state.hasPrev ? controller.previous : null,
        ),
        const SizedBox(width: 4),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            iconSize: 32,
            padding: const EdgeInsets.all(14),
            color: Colors.black,
            icon: Icon(state.playing ? Icons.pause : Icons.play_arrow),
            onPressed: state.hasCurrent ? controller.playOrPause : null,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          iconSize: 36,
          icon: Icon(Icons.skip_next, color: Colors.white.withValues(alpha: 0.85)),
          onPressed: state.hasNext ? controller.next : null,
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: l10n.stopTooltip,
          icon: const Icon(Icons.stop, color: Colors.white70),
          onPressed: state.hasCurrent ? controller.stop : null,
        ),
      ],
    );
  }
}

class _ControlState {
  final bool playing;
  final bool looping;
  final bool hasPrev;
  final bool hasNext;
  final bool hasCurrent;

  const _ControlState({
    required this.playing,
    required this.looping,
    required this.hasPrev,
    required this.hasNext,
    required this.hasCurrent,
  });

  @override
  bool operator ==(Object o) =>
      o is _ControlState &&
      o.playing == playing &&
      o.looping == looping &&
      o.hasPrev == hasPrev &&
      o.hasNext == hasNext &&
      o.hasCurrent == hasCurrent;

  @override
  int get hashCode => Object.hash(playing, looping, hasPrev, hasNext, hasCurrent);
}

// ---------------------------------------------------------------------------
// Panel Toggle (Lyrics / Queue)
// ---------------------------------------------------------------------------
class _PanelToggle extends StatelessWidget {
  final bool showLyrics;
  final VoidCallback onToggle;

  const _PanelToggle({required this.showLyrics, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tab('歌词', showLyrics, onToggle),
          const SizedBox(width: 16),
          _tab('播放列表', !showLyrics, onToggle),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: 14,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.5),
        ),
        child: Text(label),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Playlist / Queue
// ---------------------------------------------------------------------------
class _Playlist extends StatelessWidget {
  final List<MediaItem> playlist;
  final int currentIndex;
  final void Function(int index)? onTap;

  const _Playlist({
    required this.playlist,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: playlist.length,
      itemBuilder: (context, index) {
        final item = playlist[index];
        final isCurrent = index == currentIndex;
        final title = item.title ?? item.name;
        final subtitle = item.artist ?? FormatUtils.fileSize(item.size);
        return ListTile(
          dense: true,
          selected: isCurrent,
          selectedTileColor: Colors.white.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: isCurrent
              ? const Icon(Icons.play_arrow, color: Colors.white, size: 20)
              : SizedBox(
                  width: 20,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.85),
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          onTap: () {
            // Jump handled via controller - need ref access.
            // This is now handled by the parent PlaybackControllerProvider.
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Synchronized Lyrics View — uses its own ticker for smooth auto-scroll
// ---------------------------------------------------------------------------
class _LyricsView extends ConsumerStatefulWidget {
  final Lyrics lyrics;
  const _LyricsView({required this.lyrics});

  @override
  ConsumerState<_LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<_LyricsView> {
  int _activeLine = -1;
  final ScrollController _controller = ScrollController();
  Timer? _refreshTimer;

  static const double _itemHeight = 60.0;
  static const double _topPadding = 100.0;

  @override
  void initState() {
    super.initState();
    // 50ms 一次轮询：精度足够（≈20Hz），不会像 Ticker(60fps) 那样频繁重建，
    // 因此 active 切换也不会出现"持续闪烁"的感觉。
    _refreshTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _refreshActiveLine(),
    );
  }

  void _refreshActiveLine() {
    if (!mounted) return;
    final pos = ref.read(playbackControllerProvider).position;
    final idx = widget.lyrics.lineIndexAt(pos);
    if (idx == _activeLine) return;
    setState(() => _activeLine = idx);
    _scrollToActive(idx);
  }

  void _scrollToActive(int idx) {
    if (idx < 0 || !_controller.hasClients) return;
    final viewport = _controller.position.viewportDimension;
    final maxScroll = _controller.position.maxScrollExtent;
    final lineCenter = _topPadding + idx * _itemHeight + _itemHeight / 2;
    final target = (lineCenter - viewport / 2).clamp(0.0, maxScroll);
    if ((target - _controller.offset).abs() < 1.0) return;
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Apple Music 风格：基于距离的透明度梯度，远处歌词自然"变虚"。
  double _opacityForDistance(int distance) {
    if (distance == 0) return 1.0;
    if (distance == 1) return 0.55;
    if (distance == 2) return 0.38;
    return 0.22;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: ShaderMask(
          // 关键修复：之前用的是 BlendMode.dstOut，会把黑色区域(中间)擦掉、
          // 透明区域(顶部底部)保留 —— 表现为"中间一大块空白、只在顶部和底部
          // 显示一行歌词"。改用 dstIn 后，行为反过来：黑色区域(中间)保留、
          // 透明区域(顶部底部)渐隐 —— 这正是 Apple Music 的边缘渐变效果。
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            // 顶部 20% / 底部 15% 渐变淡出，中间 65% 完全清晰。
            stops: [0.0, 0.20, 0.85, 1.0],
          ).createShader(bounds),
          child: ListView.builder(
            controller: _controller,
            // 上下加大 padding，确保 active 行能滚到视口中央
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: _topPadding,
            ),
            itemCount: widget.lyrics.lines.length,
            itemExtent: _itemHeight,
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: false,
            itemBuilder: (context, index) {
              final line = widget.lyrics.lines[index];
              final isActive = index == _activeLine;
              final distance = (index - _activeLine).abs();
              final opacity = _opacityForDistance(distance);
              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: isActive ? 22 : 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: Colors.white.withValues(alpha: opacity),
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
                child: Center(
                  child: Text(
                    line.text,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
