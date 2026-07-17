import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format_utils.dart';
import '../../l10n/l10n.dart';
import '../../models/media_item.dart';
import '../../providers/player_provider.dart';
import 'package:lumiluna/l10n/generated/app_localizations.dart';

/// Music player with a now-playing header, transport controls, a seek bar and
/// the full playlist. Backed by the shared media_kit player.
class MusicPlayerScreen extends ConsumerWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(playbackControllerProvider);
    final controller = ref.read(playbackControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final current = state.current;

    final title = current?.title ?? current?.name ?? l10n.notPlaying;
    final subtitle = _subtitle(current);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nowPlaying),
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('${state.rate}x'),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Album-art: embedded cover when available, themed icon otherwise.
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: current?.artworkPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      File(current!.artworkPath!),
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (_, __, ___) => _artPlaceholder(scheme),
                    ),
                  )
                : _artPlaceholder(scheme),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          _SeekBar(state: state, onSeek: controller.seek),
          _Controls(state: state, controller: controller, l10n: l10n),
          const Divider(height: 1),
          Expanded(
            child: _Playlist(state: state, controller: controller),
          ),
        ],
      ),
    );
  }

  /// Build the secondary line: "artist · album", falling back to the folder
  /// name when no tags are present.
  String _subtitle(MediaItem? item) {
    if (item == null) return '';
    final parts = [item.artist, item.album].whereType<String>().toList();
    if (parts.isNotEmpty) return parts.join('  ·  ');
    return item.folderName;
  }

  Widget _artPlaceholder(ColorScheme scheme) => Icon(
        Icons.music_note,
        size: 96,
        color: scheme.onSecondaryContainer,
      );
}

class _SeekBar extends StatelessWidget {
  final PlaybackState state;
  final ValueChanged<Duration> onSeek;

  const _SeekBar({required this.state, required this.onSeek});

  @override
  Widget build(BuildContext context) {
    final duration = state.duration.inMilliseconds.toDouble();
    final maxValue = duration <= 0 ? 1.0 : duration;
    final position =
        state.position.inMilliseconds.toDouble().clamp(0.0, maxValue);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Slider(
            value: position,
            max: maxValue,
            onChanged: duration <= 0
                ? null
                : (v) => onSeek(Duration(milliseconds: v.round())),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(FormatUtils.duration(state.position)),
                Text(FormatUtils.duration(state.duration)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          icon: const Icon(Icons.repeat),
          selectedIcon: const Icon(Icons.repeat_on),
          onPressed: controller.toggleLoop,
        ),
        const SizedBox(width: 8),
        IconButton(
          iconSize: 40,
          icon: const Icon(Icons.skip_previous),
          onPressed: state.hasPrevious ? controller.previous : null,
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: state.current == null ? null : controller.playOrPause,
          style: FilledButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(18),
          ),
          child: Icon(state.playing ? Icons.pause : Icons.play_arrow, size: 32),
        ),
        const SizedBox(width: 8),
        IconButton(
          iconSize: 40,
          icon: const Icon(Icons.skip_next),
          onPressed: state.hasNext ? controller.next : null,
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: l10n.stopTooltip,
          icon: const Icon(Icons.stop),
          onPressed: state.current == null ? null : controller.stop,
        ),
      ],
    );
  }
}

class _Playlist extends StatelessWidget {
  final PlaybackState state;
  final PlaybackController controller;

  const _Playlist({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: state.playlist.length,
      itemBuilder: (context, index) {
        final item = state.playlist[index];
        final isCurrent = index == state.index;
        final title = item.title ?? item.name;
        final subtitle = item.artist ?? FormatUtils.fileSize(item.size);
        return ListTile(
          dense: true,
          selected: isCurrent,
          leading: isCurrent
              ? Icon(Icons.equalizer, color: scheme.primary)
              : Text(
                  '${index + 1}',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () => controller.jump(index),
        );
      },
    );
  }
}
