import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lyric/core/lyric_model.dart' show LyricModel;
import 'package:flutter_lyric/core/lyric_style.dart' show LyricStyle;
import 'package:flutter_lyric/flutter_lyric.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format_utils.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../models/media_item.dart';
import '../../providers/lyrics_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/lyrics_parser.dart';

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
    final state = ref.watch(playbackControllerProvider
        .select((s) => _PlaybackSummary.fromState(s)));
    final controller = ref.read(playbackControllerProvider.notifier);
    final l10n = context.l10n;
    final appTheme = Theme.of(context);
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: appTheme.brightness,
    );
    final playerTheme = appTheme.brightness == Brightness.dark
        ? AppTheme.dark(const Color(0xFF6750A4))
        : AppTheme.light(const Color(0xFF6750A4));
    final blurBackground = ref.watch(
      settingsProvider.select((settings) => settings.musicBackgroundBlur),
    );
    final dynamicBackground = ref.watch(
      settingsProvider.select((settings) => settings.musicDynamicBackground),
    );
    final animationIntensity = ref.watch(
      settingsProvider.select((settings) => settings.musicAnimationIntensity),
    );
    final lyricsFontSize = ref.watch(
      settingsProvider.select((settings) => settings.musicLyricsFontSize),
    );

    final player = _PlayerKeyboardShortcuts(
      enabled: _isDesktop,
      onPrevious: controller.previous,
      onNext: controller.next,
      hasPrev: state.index > 0,
      hasNext: state.current != null && state.index < state.playlist.length - 1,
      child: Scaffold(
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
                  Positioned.fill(
                      child: _MusicBackground(
                    item: state.current!,
                    scheme: scheme,
                    blur: blurBackground,
                    dynamic: dynamicBackground,
                    intensity: animationIntensity,
                  )),
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 900;
                        return isWide
                            ? _WideLayout(
                                current: state.current!,
                                scheme: scheme,
                                controller: controller,
                                playlist: state.playlist,
                                playlistIndex: state.index,
                                lyricsFontSize: lyricsFontSize,
                              )
                            : _NarrowLayout(
                                current: state.current!,
                                scheme: scheme,
                                controller: controller,
                                playlist: state.playlist,
                                playlistIndex: state.index,
                                lyricsFontSize: lyricsFontSize,
                              );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );

    return Theme(data: playerTheme, child: player);
  }

  /// True when shortcuts should be active.  Only the Windows / macOS / Linux
  /// desktop builds enable keyboard control — phones and tablets have no
  /// physical keyboard and we want the Space key to keep its default
  /// behaviour in the seek slider / playlist etc.
  static bool get _isDesktop {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  Widget _buildBackground(
      MediaItem item, ColorScheme scheme, bool blurBackground) {
    if (item.artworkPath != null && File(item.artworkPath!).existsSync()) {
      try {
        final image = Image.file(
          File(item.artworkPath!),
          fit: BoxFit.cover,
          color: Colors.black.withValues(alpha: 0.55),
          colorBlendMode: BlendMode.darken,
        );
        return blurBackground
            ? ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: image,
              )
            : image;
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

class _MusicBackground extends StatefulWidget {
  final MediaItem item;
  final ColorScheme scheme;
  final bool blur;
  final bool dynamic;
  final double intensity;

  const _MusicBackground({
    required this.item,
    required this.scheme,
    required this.blur,
    required this.dynamic,
    required this.intensity,
  });

  @override
  State<_MusicBackground> createState() => _MusicBackgroundState();
}

class _MusicBackgroundState extends State<_MusicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: Duration(
        milliseconds: (20000 / widget.intensity.clamp(0.1, 1.5)).round()),
  )..repeat();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _MusicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.intensity != widget.intensity) {
      _animation.duration = Duration(
        milliseconds: (20000 / widget.intensity.clamp(0.1, 1.5)).round(),
      );
      if (widget.dynamic && !_animation.isAnimating) _animation.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.item.artworkPath;
    final artwork = path != null && File(path).existsSync()
        ? Image.file(File(path), fit: BoxFit.cover)
        : null;
    final base = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.scheme.primaryContainer,
            widget.scheme.surface,
            widget.scheme.secondaryContainer,
          ],
        ),
      ),
    );
    if (!widget.dynamic) {
      if (artwork == null) return base;
      final image = widget.blur
          ? ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: artwork,
            )
          : artwork;
      return Stack(
        fit: StackFit.expand,
        children: [image, DecoratedBox(decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45)))],
      );
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          base,
          if (artwork != null)
            Opacity(
              opacity: 0.18 + widget.intensity.clamp(0, 1) * 0.12,
              child: widget.blur
                  ? ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Transform.scale(
                        scale: 1.35,
                        child: Transform.rotate(
                          angle: (_animation.value - 0.5) * 0.025,
                          child: artwork,
                        ),
                      ),
                    )
                  : Transform.scale(
                      scale: 1.35,
                      child: Transform.rotate(
                        angle: (_animation.value - 0.5) * 0.025,
                        child: artwork,
                      ),
                    ),
              ),
            ),
          DecoratedBox(
            decoration:
                BoxDecoration(color: Colors.black.withValues(alpha: 0.45)),
          ),
        ],
      ),
    );
  }
}

/// Lightweight summary that changes only when the track / playback mode
/// changes — never on every position tick.
class _PlaybackSummary {
  final MediaItem? current;
  final double rate;
  final PlaybackMode mode;
  final int index;
  final List<MediaItem> playlist;

  const _PlaybackSummary({
    this.current,
    required this.rate,
    required this.mode,
    required this.index,
    required this.playlist,
  });

  static _PlaybackSummary fromState(PlaybackState s) => _PlaybackSummary(
        current: s.current,
        rate: s.rate,
        mode: s.mode,
        index: s.index,
        playlist: s.playlist,
      );

  @override
  bool operator ==(Object o) =>
      o is _PlaybackSummary &&
      o.current?.path == current?.path &&
      o.rate == rate &&
      o.mode == mode &&
      o.index == index &&
      o.playlist.length == playlist.length &&
      (o.playlist.isEmpty ||
          playlist.isEmpty ||
          o.playlist.first.path == playlist.first.path);

  @override
  int get hashCode => Object.hash(current?.path, rate, mode, index);
}

// ---------------------------------------------------------------------------
// Narrow layout (phones / narrow windows)
// Page 0: player (tap cover → lyrics overlay)
// Page 1: playlist (swipe left from player to reach)
// ---------------------------------------------------------------------------
class _NarrowLayout extends ConsumerStatefulWidget {
  final MediaItem current;
  final ColorScheme scheme;
  final PlaybackController controller;
  final List<MediaItem> playlist;
  final int playlistIndex;
  final double lyricsFontSize;

  const _NarrowLayout({
    required this.current,
    required this.scheme,
    required this.controller,
    required this.playlist,
    required this.playlistIndex,
    required this.lyricsFontSize,
  });

  @override
  ConsumerState<_NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends ConsumerState<_NarrowLayout> {
  bool _showLyricsOverlay = false;
  final PageController _pageController = PageController();
  final GlobalKey<_LyricsOverlayState> _lyricsOverlayKey =
      GlobalKey<_LyricsOverlayState>();

  void _closeLyricsOverlay() {
    if (!_showLyricsOverlay) return;
    setState(() => _showLyricsOverlay = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lyricsAsync = ref.watch(lyricsProvider);
    final translationAsync = ref.watch(lyricsTranslationProvider);

    final hasLyrics = lyricsAsync.maybeWhen(
      data: (lyrics) => lyrics != null && lyrics.trim().isNotEmpty,
      orElse: () => false,
    );

    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(),
      children: [
        // ── Page 0: Player ──────────────────────────────────────────────
        Column(
          children: [
            // Album art / lyrics overlay — tap to toggle.
            Expanded(
              flex: _showLyricsOverlay ? 5 : 3,
              child: GestureDetector(
                // Only the cover/background toggles the lyrics overlay. When
                // the child LyricView handles a lyric-line tap, its tap
                // callback marks the gesture so this ancestor does nothing.
                onTap: !_showLyricsOverlay && hasLyrics
                    ? () => setState(() => _showLyricsOverlay = true)
                    : null,
                child: _showLyricsOverlay && hasLyrics
                    // When the lyrics overlay is open, grab primary focus so
                    // ESC closes the overlay locally (instead of falling
                    // through to the global handler which would pop the whole
                    // player route). Tapping the overlay still closes it too.
                    ? Focus(
                        autofocus: true,
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.escape) {
                            _closeLyricsOverlay();
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: _LyricsOverlay(
                          key: _lyricsOverlayKey,
                          onLyricLineTap: () {},
                          onBackgroundTap: _closeLyricsOverlay,
                          child: _LyricsPanel(
                            lyricsAsync: lyricsAsync,
                            translationAsync: translationAsync,
                            fontSize: widget.lyricsFontSize,
                            onLyricLineTap: () => _lyricsOverlayKey.currentState
                                ?.markLyricLineTap(),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _AlbumArt(item: widget.current, maxWidth: 400),
                          const SizedBox(height: 24),
                          _SongInfo(item: widget.current),
                          if (hasLyrics)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '点击封面查看歌词',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
            const _PlaybackRegion(),
            const SizedBox(height: 8),
          ],
        ),
        // ── Page 1: Playlist ────────────────────────────────────────────
        _PlaylistPage(
          playlist: widget.playlist,
          currentIndex: widget.playlistIndex,
        ),
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
  final List<MediaItem> playlist;
  final int playlistIndex;
  final double lyricsFontSize;

  const _WideLayout({
    required this.current,
    required this.scheme,
    required this.controller,
    required this.playlist,
    required this.playlistIndex,
    required this.lyricsFontSize,
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
              const SizedBox(width: 360, child: _SeekBar()),
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
            playlist: playlist,
            playlistIndex: playlistIndex,
            lyricsFontSize: lyricsFontSize,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Playback region (narrow layout) — seek bar + controls only
// ---------------------------------------------------------------------------
class _PlaybackRegion extends ConsumerWidget {
  const _PlaybackRegion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SeekBar(),
        SizedBox(height: 8),
        _Controls(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Lyrics or Queue panel (used in _WideLayout)
// ---------------------------------------------------------------------------
class _LyricsOrQueue extends ConsumerStatefulWidget {
  final List<MediaItem> playlist;
  final int playlistIndex;
  final double lyricsFontSize;

  const _LyricsOrQueue({
    required this.playlist,
    required this.playlistIndex,
    required this.lyricsFontSize,
  });

  @override
  ConsumerState<_LyricsOrQueue> createState() => _LyricsOrQueueState();
}

class _LyricsOrQueueState extends ConsumerState<_LyricsOrQueue> {
  bool _showLyrics = true;

  @override
  Widget build(BuildContext context) {
    final lyricsAsync = ref.watch(lyricsProvider);
    final translationAsync = ref.watch(lyricsTranslationProvider);

    return Column(
      children: [
        _PanelToggle(
          showLyrics: _showLyrics,
          onToggle: () => setState(() => _showLyrics = !_showLyrics),
        ),
        Expanded(
          child: _showLyrics
              ? _LyricsPanel(
                  lyricsAsync: lyricsAsync,
                  translationAsync: translationAsync,
                  fontSize: widget.lyricsFontSize,
                )
              : _Playlist(
                  playlist: widget.playlist,
                  currentIndex: widget.playlistIndex,
                  onTap: (i) =>
                      ref.read(playbackControllerProvider.notifier).jump(i),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Lyrics panel — wraps lyrics loading + translation toggle + LyricView
// ---------------------------------------------------------------------------
class _LyricsPanel extends ConsumerStatefulWidget {
  final AsyncValue<String?> lyricsAsync;
  final AsyncValue<String?> translationAsync;
  final VoidCallback? onLyricLineTap;
  final double fontSize;

  const _LyricsPanel({
    required this.lyricsAsync,
    required this.translationAsync,
    this.onLyricLineTap,
    required this.fontSize,
  });

  @override
  ConsumerState<_LyricsPanel> createState() => _LyricsPanelState();
}

class _LyricsPanelState extends ConsumerState<_LyricsPanel> {
  bool _showTranslation = false;

  @override
  Widget build(BuildContext context) {
    return widget.lyricsAsync.when(
      data: (rawLyrics) {
        if (rawLyrics == null || rawLyrics.trim().isEmpty) {
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
        final translation = widget.translationAsync.maybeWhen(
          data: (t) => t,
          orElse: () => null,
        );
        final hasTranslation =
            translation != null && translation.trim().isNotEmpty;

        return Column(
          children: [
            if (hasTranslation)
              _TranslationToggle(
                showTranslation: _showTranslation,
                onToggle: () =>
                    setState(() => _showTranslation = !_showTranslation),
              ),
            Expanded(
              child: _LyricsView(
                rawLyrics: rawLyrics,
                translation: hasTranslation ? translation : null,
                showTranslation: _showTranslation && hasTranslation,
                fontSize: widget.fontSize,
                onLyricLineTap: widget.onLyricLineTap,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
          child: Text('无法加载歌词', style: TextStyle(color: Colors.white60))),
    );
  }
}

// ---------------------------------------------------------------------------
// Translation toggle — "仅原文" / "原文+翻译"
// ---------------------------------------------------------------------------
class _TranslationToggle extends StatelessWidget {
  final bool showTranslation;
  final VoidCallback onToggle;

  const _TranslationToggle({
    required this.showTranslation,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _chip('仅原文', !showTranslation, onToggle),
          const SizedBox(width: 8),
          _chip('原文+翻译', showTranslation, onToggle),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  active ? Colors.white : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  active ? Colors.white : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
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
    if (item.artworkPath != null && File(item.artworkPath!).existsSync()) {
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
      decoration:
          BoxDecoration(borderRadius: borderRadius, boxShadow: [shadow]),
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
          child:
              Icon(Icons.music_note, size: size * 0.35, color: Colors.white38),
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
    final position =
        state.position.inMilliseconds.toDouble().clamp(0.0, maxValue);

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
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white60)),
                Text(FormatUtils.duration(state.duration),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white60)),
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
      o is _SeekState && o.position == position && o.duration == duration;

  @override
  int get hashCode => Object.hash(position, duration);
}

// ---------------------------------------------------------------------------
// Playback Controls — Material Design style with ripple.  A single button
// cycles through sequential → loop → shuffle modes; the stop button has
// been removed.
// ---------------------------------------------------------------------------
class _Controls extends ConsumerWidget {
  const _Controls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      playbackControllerProvider.select(
        (s) => _ControlState(
          playing: s.playing,
          mode: s.mode,
          rate: s.rate,
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
        // Combined play-mode button (sequential / loop / shuffle)
        _PlayModeButton(
          mode: state.mode,
          onCycle: controller.cyclePlayMode,
          l10n: l10n,
        ),
        const SizedBox(width: 8),
        // Previous
        IconButton(
          iconSize: 36,
          icon: Icon(Icons.skip_previous,
              color: Colors.white.withValues(alpha: 0.85)),
          onPressed: state.hasPrev ? controller.previous : null,
        ),
        const SizedBox(width: 8),
        // Play / Pause — Material filled button with ripple
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: state.hasCurrent ? controller.playOrPause : null,
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Icon(
                state.playing ? Icons.pause : Icons.play_arrow,
                size: 32,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Next
        IconButton(
          iconSize: 36,
          icon: Icon(Icons.skip_next,
              color: Colors.white.withValues(alpha: 0.85)),
          onPressed: state.hasNext ? controller.next : null,
        ),
        const SizedBox(width: 4),
        // Speed selector
        _SpeedButton(rate: state.rate, onSelected: controller.setRate),
      ],
    );
  }
}

/// Single button that cycles through sequential → loop → shuffle.  Visual
/// state is encoded both by the icon and by its opacity (sequential is the
/// dim "off" state, the other two are highlighted).
class _PlayModeButton extends StatelessWidget {
  final PlaybackMode mode;
  final Future<void> Function() onCycle;
  final AppLocalizations l10n;

  const _PlayModeButton({
    required this.mode,
    required this.onCycle,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, label, active) = switch (mode) {
      PlaybackMode.sequential => (
          Icons.repeat,
          l10n.playModeSequential,
          false,
        ),
      PlaybackMode.loop => (
          Icons.repeat_one,
          l10n.playModeLoop,
          true,
        ),
      PlaybackMode.shuffle => (
          Icons.shuffle,
          l10n.playModeShuffle,
          true,
        ),
    };
    return IconButton(
      tooltip: l10n.playModeTooltip(label),
      isSelected: active,
      icon: Icon(icon, color: Colors.white.withValues(alpha: 0.5)),
      selectedIcon: Icon(icon, color: Colors.white),
      onPressed: onCycle,
    );
  }
}

/// Compact speed selector — relocated from AppBar into the controls row.
class _SpeedButton extends StatelessWidget {
  final double rate;
  final void Function(double) onSelected;
  const _SpeedButton({required this.rate, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'Playback speed',
      initialValue: rate,
      onSelected: onSelected,
      itemBuilder: (_) => const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
          .map((r) => PopupMenuItem(value: r, child: Text('${r}x')))
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text('${rate}x',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            )),
      ),
    );
  }
}

class _ControlState {
  final bool playing;
  final PlaybackMode mode;
  final double rate;
  final bool hasPrev;
  final bool hasNext;
  final bool hasCurrent;

  const _ControlState({
    required this.playing,
    required this.mode,
    required this.rate,
    required this.hasPrev,
    required this.hasNext,
    required this.hasCurrent,
  });

  @override
  bool operator ==(Object o) =>
      o is _ControlState &&
      o.playing == playing &&
      o.mode == mode &&
      o.rate == rate &&
      o.hasPrev == hasPrev &&
      o.hasNext == hasNext &&
      o.hasCurrent == hasCurrent;

  @override
  int get hashCode =>
      Object.hash(playing, mode, rate, hasPrev, hasNext, hasCurrent);
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              color: isCurrent
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.85),
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          onTap: onTap != null ? () => onTap!(index) : null,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Playlist page — used as the right page of the narrow PageView.
// Swipe left from the player to reach this page.
// ---------------------------------------------------------------------------
class _PlaylistPage extends ConsumerWidget {
  final List<MediaItem> playlist;
  final int currentIndex;

  const _PlaylistPage({
    required this.playlist,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '播放列表',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _Playlist(
        playlist: playlist,
        currentIndex: currentIndex,
        onTap: (i) => ref.read(playbackControllerProvider.notifier).jump(i),
      ),
    );
  }
}

// =============================================================================
// Synchronized Lyrics View — powered by flutter_lyric
//
// flutter_lyric provides smooth scrolling, highlight animation, translation
// support, and touch interaction out of the box.  We feed it the raw LRC text
// and drive it with media_kit's position stream via controller.setProgress().
// =============================================================================
class _LyricsView extends ConsumerStatefulWidget {
  final String rawLyrics;
  final String? translation;
  final bool showTranslation;
  final VoidCallback? onLyricLineTap;
  final double fontSize;

  const _LyricsView({
    required this.rawLyrics,
    this.translation,
    this.showTranslation = false,
    this.onLyricLineTap,
    required this.fontSize,
  });

  @override
  ConsumerState<_LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends ConsumerState<_LyricsView> {
  late final LyricController _controller;
  StreamSubscription<Duration>? _posSub;

  /// Apple Music-inspired style: centered text, white highlight, smooth
  /// fade at top/bottom, generous spacing, translation support.
  LyricStyle get _style => LyricStyles.default1.copyWith(
        textStyle: const TextStyle(fontSize: 16, color: Colors.white54),
        activeStyle: TextStyle(
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        translationStyle: TextStyle(
          fontSize: 14,
          color: Colors.white.withValues(alpha: 0.5),
        ),
        translationActiveColor: Colors.white.withValues(alpha: 0.85),
        lineGap: 30,
        translationLineGap: 8,
        contentPadding:
            const EdgeInsets.only(top: 200, left: 30, right: 30, bottom: 200),
        fadeRange: FadeRange(top: 100, bottom: 100),
        activeHighlightColor: Colors.white,
        activeHighlightGradient: null,
        enableSwitchAnimation: true,
      );

  @override
  void initState() {
    super.initState();
    _controller = LyricController();
    _loadLyrics();
    _startPositionListener();
  }

  void _loadLyrics() {
    // Bypass flutter_lyric 3.0.7's buggy LrcParser (strict ms match + padRight
    // bug) by parsing ourselves and injecting the resulting LyricModel via
    // `loadLyricModel`. The custom parser correctly handles 1/2/3-digit ms
    // fractions and fuzzy-matches translations with ±20ms tolerance.
    final LyricModel model = parseLrcWithTranslation(
      widget.rawLyrics,
      translationLyric: widget.showTranslation ? widget.translation : null,
    );
    _controller.loadLyricModel(model);
  }

  void _startPositionListener() {
    final pc = ref.read(playbackControllerProvider.notifier);
    // Push media_kit's position stream directly into flutter_lyric.
    _posSub = pc.player.stream.position.listen(_controller.setProgress);
    // Tap a lyric line → seek the player.
    _controller.setOnTapLineCallback((position) {
      widget.onLyricLineTap?.call();
      pc.seek(position);
    });
  }

  @override
  void didUpdateWidget(covariant _LyricsView old) {
    super.didUpdateWidget(old);
    if (old.rawLyrics != widget.rawLyrics ||
        old.showTranslation != widget.showTranslation ||
        old.translation != widget.translation) {
      _loadLyrics();
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LyricView(
        controller: _controller,
        style: _style,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

// =============================================================================
// Lyrics Overlay wrapper — captures raw pointer events to distinguish a quick
// tap (close the overlay) from a swipe (let the LyricView handle scrolling).
//
// `Listener` does NOT participate in the gesture arena, so it does not steal
// taps from the LyricView's internal GestureDetector — taps-to-seek and the
// vertical-drag scroll continue to work exactly as before.
// =============================================================================
class _LyricsOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback onLyricLineTap;
  final VoidCallback onBackgroundTap;

  const _LyricsOverlay({
    super.key,
    required this.child,
    required this.onLyricLineTap,
    required this.onBackgroundTap,
  });

  @override
  State<_LyricsOverlay> createState() => _LyricsOverlayState();
}

class _LyricsOverlayState extends State<_LyricsOverlay> {
  Offset? _downPosition;
  bool _lineTapHandled = false;
  int? _pointerId;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _pointerId = event.pointer;
        _downPosition = event.localPosition;
        _lineTapHandled = false;
      },
      onPointerUp: (event) {
        if (event.pointer != _pointerId) return;
        final down = _downPosition;
        _downPosition = null;
        _pointerId = null;
        if (down == null) return;
        final moved = (event.localPosition - down).distance;
        if (moved >= 10) {
          _lineTapHandled = false;
          return;
        }

        // LyricView resolves its tap recognizer after pointer-up dispatch.
        // Defer the background decision so a lyric-line callback can mark this
        // same gesture first; otherwise a line tap would also close the view.
        Future<void>.delayed(Duration.zero, () {
          if (!mounted) return;
          if (!_lineTapHandled) widget.onBackgroundTap();
          _lineTapHandled = false;
        });
      },
      onPointerCancel: (event) {
        if (event.pointer != _pointerId) return;
        _downPosition = null;
        _pointerId = null;
        _lineTapHandled = false;
      },
      child: widget.child,
    );
  }

  void markLyricLineTap() {
    _lineTapHandled = true;
    widget.onLyricLineTap();
  }
}

// =============================================================================
// Windows keyboard shortcuts: ←/→ = previous/next.
//
// Space / mediaPlayPause is handled globally by `MediaKeyShortcuts` (installed
// in MaterialApp.builder) — it works in the music player, video player, and
// even on the Home screen with the mini-player.
//
// Only ←/→ remain here. The previous structure was
// `Focus(autofocus: true) > CallbackShortcuts(...)`, but the outer Focus took
// the primary focus *without* an `onKeyEvent`, so key events bubbled past the
// CallbackShortcuts (whose internal Focus has `canRequestFocus: false` and
// `skipTraversal: true` — it can only act when a descendant holds primary
// focus). Result: nothing worked until the user clicked a focusable widget.
//
// Fix: handle ←/→ directly in the Focus's `onKeyEvent`. Same node that grabs
// focus also processes the keys — no bubbling ambiguity.
// =============================================================================
class _PlayerKeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final Future<void> Function() onPrevious;
  final Future<void> Function() onNext;
  final bool hasPrev;
  final bool hasNext;

  const _PlayerKeyboardShortcuts({
    required this.child,
    required this.enabled,
    required this.onPrevious,
    required this.onNext,
    required this.hasPrev,
    required this.hasNext,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          if (hasPrev) onPrevious();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          if (hasNext) onNext();
          return KeyEventResult.handled;
        }
        // Space / other keys fall through to the global MediaKeyShortcuts.
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
