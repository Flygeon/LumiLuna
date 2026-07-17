import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format_utils.dart';
import '../../l10n/l10n.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/lyrics.dart';
import '../../models/media_item.dart';
import '../../providers/lyrics_provider.dart';
import '../../providers/player_provider.dart';

/// Music player inspired by Apple Music's design language, retaining some
/// Material Design affordances for consistency.
///
/// Features large album artwork, blurred background, synchronized lyrics,
/// playback controls, and the current playlist.
class MusicPlayerScreen extends ConsumerStatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  ConsumerState<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends ConsumerState<MusicPlayerScreen> {
  bool _showLyrics = true;

  final ScrollController _lyricsScroll = ScrollController();

  @override
  void dispose() {
    _lyricsScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playbackControllerProvider);
    final controller = ref.read(playbackControllerProvider.notifier);
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final current = state.current;
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
      body: current == null
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
                // --- Background (blurred artwork or gradient) ---
                Positioned.fill(child: _buildBackground(current, scheme)),

                // --- Foreground content ---
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // Album art
                      _AlbumArt(item: current),

                      const SizedBox(height: 24),

                      // Title + artist
                      _SongInfo(item: current, scheme: scheme),

                      const SizedBox(height: 20),

                      // Seek bar
                      _SeekBar(state: state, onSeek: controller.seek),

                      const SizedBox(height: 8),

                      // Controls
                      _Controls(
                        state: state,
                        controller: controller,
                        l10n: l10n,
                      ),

                      const SizedBox(height: 16),

                      // Toggle: Lyrics / Queue
                      _PanelToggle(
                        showLyrics: _showLyrics,
                        onToggle: () =>
                            setState(() => _showLyrics = !_showLyrics),
                      ),

                      // Lyrics panel
                      if (_showLyrics)
                        Flexible(
                          flex: 3,
                          child: _buildLyricsPanel(
                              lyricsAsync, state, scheme),
                        )
                      else
                        Flexible(
                          flex: 3,
                          child: _Playlist(
                              state: state, controller: controller),
                        ),

                      const SizedBox(height: 8),
                    ],
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
    // Fallback: dark gradient.
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            scheme.surfaceContainerHighest,
            scheme.surface,
          ],
        ),
      ),
    );
  }

  Widget _buildLyricsPanel(
    AsyncValue<Lyrics?> async,
    PlaybackState state,
    ColorScheme scheme,
  ) {
    return async.when(
      data: (lyrics) {
        if (lyrics == null || lyrics.lines.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lyrics_outlined,
                    size: 40, color: scheme.onSurfaceVariant.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                Text(
                  '暂无歌词',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }
        return _LyricsView(
          lyrics: lyrics,
          position: state.position,
          scrollController: _lyricsScroll,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('无法加载歌词', style: TextStyle(color: scheme.error)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Album Art
// ---------------------------------------------------------------------------
class _AlbumArt extends StatelessWidget {
  final MediaItem item;
  const _AlbumArt({required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.65;
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
            colors: [
              Colors.grey.shade700,
              Colors.grey.shade900,
            ],
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
  final ColorScheme scheme;

  const _SongInfo({required this.item, required this.scheme});

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
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Seek Bar
// ---------------------------------------------------------------------------
class _SeekBar extends StatelessWidget {
  final PlaybackState state;
  final ValueChanged<Duration> onSeek;

  const _SeekBar({required this.state, required this.onSeek});

  @override
  Widget build(BuildContext context) {
    final duration = state.duration.inMilliseconds.toDouble();
    final maxValue = duration <= 0 ? 1.0 : duration;
    final position = state.position.inMilliseconds.toDouble().clamp(0.0, maxValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: position,
              max: maxValue,
              onChanged:
                  duration <= 0 ? null : (v) => onSeek(Duration(milliseconds: v.round())),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FormatUtils.duration(state.position),
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                ),
                Text(
                  FormatUtils.duration(state.duration),
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Playback Controls
// ---------------------------------------------------------------------------
class _Controls extends StatelessWidget {
  final PlaybackState state;
  final PlaybackController controller;
  final AppLocalizations l10n;

  const _Controls({
    required this.state,
    required this.controller,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: l10n.loopTooltip,
          isSelected: state.looping,
          icon: Icon(Icons.repeat, color: Colors.white.withValues(alpha: 0.7)),
          selectedIcon: const Icon(Icons.repeat_on, color: Colors.white),
          onPressed: controller.toggleLoop,
        ),
        const SizedBox(width: 4),
        IconButton(
          iconSize: 36,
          icon: Icon(Icons.skip_previous,
              color: Colors.white.withValues(alpha: 0.85)),
          onPressed: state.hasPrevious ? controller.previous : null,
        ),
        const SizedBox(width: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            iconSize: 32,
            padding: const EdgeInsets.all(14),
            color: Colors.black,
            icon: Icon(state.playing ? Icons.pause : Icons.play_arrow),
            onPressed: state.current == null ? null : controller.playOrPause,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          iconSize: 36,
          icon: Icon(Icons.skip_next,
              color: Colors.white.withValues(alpha: 0.85)),
          onPressed: state.hasNext ? controller.next : null,
        ),
        const SizedBox(width: 4),
        IconButton(
          tooltip: l10n.stopTooltip,
          icon: Icon(Icons.stop, color: Colors.white.withValues(alpha: 0.7)),
          onPressed: state.current == null ? null : controller.stop,
        ),
      ],
    );
  }
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
        children: [
          _tabButton('歌词', showLyrics, onToggle),
          const SizedBox(width: 16),
          _tabButton('播放列表', !showLyrics, onToggle),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: 14,
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active
              ? Colors.white
              : Colors.white.withValues(alpha: 0.5),
        ),
        child: Text(label),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Synchronized Lyrics View
// ---------------------------------------------------------------------------
class _LyricsView extends StatefulWidget {
  final Lyrics lyrics;
  final Duration position;
  final ScrollController scrollController;

  const _LyricsView({
    required this.lyrics,
    required this.position,
    required this.scrollController,
  });

  @override
  State<_LyricsView> createState() => _LyricsViewState();
}

class _LyricsViewState extends State<_LyricsView> {
  int _activeLine = -1;

  @override
  void didUpdateWidget(covariant _LyricsView old) {
    super.didUpdateWidget(old);
    if (widget.lyrics == old.lyrics && widget.position == old.position) return;
    _updateActiveLine();
  }

  void _updateActiveLine() {
    final idx = widget.lyrics.lineIndexAt(widget.position);
    if (idx == _activeLine) return;
    setState(() => _activeLine = idx);
    if (idx >= 3 && widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        (idx - 2) * 52.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      itemCount: widget.lyrics.lines.length,
      itemExtent: 52,
      itemBuilder: (context, index) {
        final line = widget.lyrics.lines[index];
        final isActive = index == _activeLine;
        return AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: isActive ? 18 : 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            height: 1.4,
          ),
          child: Text(
            line.text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Playlist / Queue
// ---------------------------------------------------------------------------
class _Playlist extends StatelessWidget {
  final PlaybackState state;
  final PlaybackController controller;

  const _Playlist({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.playlist.length,
      itemBuilder: (context, index) {
        final item = state.playlist[index];
        final isCurrent = index == state.index;
        final title = item.title ?? item.name;
        final subtitle = item.artist ?? FormatUtils.fileSize(item.size);
        return ListTile(
          dense: true,
          selected: isCurrent,
          selectedTileColor: Colors.white.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: isCurrent
              ? Icon(Icons.play_arrow, color: Colors.white, size: 20)
              : SizedBox(
                  width: 20,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
          onTap: () => controller.jump(index),
        );
      },
    );
  }
}
