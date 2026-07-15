import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format_utils.dart';
import '../../providers/player_provider.dart';

/// Music player with a now-playing header, transport controls, a seek bar and
/// the full playlist. Backed by the shared media_kit player.
class MusicPlayerScreen extends ConsumerWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playbackControllerProvider);
    final controller = ref.read(playbackControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final current = state.current;

    return Scaffold(
      appBar: AppBar(title: const Text('正在播放')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Album-art placeholder.
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.music_note,
              size: 96,
              color: scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              current?.name ?? '未在播放',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            current?.folderName ?? '',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          _SeekBar(state: state, onSeek: controller.seek),
          _Controls(state: state, controller: controller),
          const Divider(height: 1),
          Expanded(
            child: _Playlist(state: state, controller: controller),
          ),
        ],
      ),
    );
  }
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

  const _Controls({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: '循环播放',
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
          tooltip: '停止',
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
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            FormatUtils.fileSize(item.size),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          onTap: () => controller.jump(index),
        );
      },
    );
  }
}
