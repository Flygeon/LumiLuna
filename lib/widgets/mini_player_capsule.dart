import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/player/music_player_screen.dart';
import '../providers/player_provider.dart';

/// A capsule-shaped mini-player that floats at the bottom of the home screen
/// when music is playing. Shows album art, track info, volume slider, and a
/// playlist peek button.
///
/// Animated: slides up / down + fades in / out when the playback state changes.
class MiniPlayerCapsule extends ConsumerStatefulWidget {
  const MiniPlayerCapsule({super.key, this.onOpen});

  final VoidCallback? onOpen;

  @override
  ConsumerState<MiniPlayerCapsule> createState() => _MiniPlayerCapsuleState();
}

class _MiniPlayerCapsuleState extends ConsumerState<MiniPlayerCapsule>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  bool _visible = false;
  bool _showVolume = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _fade = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playbackControllerProvider);
    final current = state.current;

    // Show/hide based on whether something is playing.
    final shouldShow = current != null;
    if (shouldShow != _visible) {
      _visible = shouldShow;
      if (shouldShow) {
        _animCtrl.forward();
      } else {
        _animCtrl.reverse();
      }
    }

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child:
            _visible ? _buildCapsule(state, context) : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildCapsule(PlaybackState state, BuildContext context) {
    final current = state.current!;
    final scheme = Theme.of(context).colorScheme;
    final title = current.title ?? current.name;
    final subtitle =
        [current.artist, current.album].whereType<String>().join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(28),
        color: scheme.surfaceContainerHigh,
        surfaceTintColor: scheme.surfaceTint,
        shadowColor: scheme.shadow.withValues(alpha: 0.3),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            widget.onOpen?.call();
            if (widget.onOpen == null) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MusicPlayerScreen()),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _showVolume ? 88 : 64,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main row: album art + info + controls
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      // Album art
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: current.artworkPath != null
                              ? Image.file(
                                  File(current.artworkPath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _artPlaceholder(scheme),
                                )
                              : _artPlaceholder(scheme),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Track info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                      ),

                      // Play / Pause
                      IconButton(
                        icon: Icon(state.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                        onPressed: () => ref
                            .read(playbackControllerProvider.notifier)
                            .playOrPause(),
                      ),

                      // Volume toggle
                      IconButton(
                        icon: Icon(_showVolume
                            ? Icons.volume_up_rounded
                            : Icons.volume_down_rounded),
                        onPressed: () =>
                            setState(() => _showVolume = !_showVolume),
                      ),

                      // Playlist peek
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.queue_music_rounded),
                        onSelected: (value) {
                          if (value == 'open_playlist') {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const MusicPlayerScreen()),
                            );
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'open_playlist',
                            child: ListTile(
                              leading: Icon(Icons.playlist_play),
                              title: Text('查看歌单'),
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          ...state.playlist.asMap().entries.map((entry) {
                            final item = entry.value;
                            final isCurrent = entry.key == state.index;
                            return PopupMenuItem(
                              enabled: false,
                              child: ListTile(
                                leading: Icon(
                                  isCurrent
                                      ? Icons.play_arrow
                                      : Icons.music_note,
                                  color: isCurrent ? scheme.primary : null,
                                  size: 18,
                                ),
                                title: Text(
                                  item.title ?? item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        isCurrent ? FontWeight.w600 : null,
                                  ),
                                ),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),

                // Volume slider (expandable)
                if (_showVolume)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.volume_down,
                            size: 16, color: scheme.onSurfaceVariant),
                        Expanded(
                          child: Slider(
                            value: state.volume.clamp(0, 100),
                            min: 0.0,
                            max: 100.0,
                            divisions: 100,
                            onChanged: (v) {
                              ref
                                  .read(playbackControllerProvider.notifier)
                                  .setVolume(v);
                            },
                          ),
                        ),
                        Icon(Icons.volume_up,
                            size: 16, color: scheme.onSurfaceVariant),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _artPlaceholder(ColorScheme scheme) => Container(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        child:
            Icon(Icons.music_note, size: 22, color: scheme.onPrimaryContainer),
      );
}
