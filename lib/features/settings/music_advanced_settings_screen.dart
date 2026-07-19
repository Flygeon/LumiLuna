import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';

class MusicAdvancedSettingsScreen extends ConsumerWidget {
  const MusicAdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('音乐高级设置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _Group(title: '动态背景', children: [
            SwitchListTile.adaptive(
              title: const Text('启用动态背景'),
              subtitle: const Text('使用专辑封面生成流动的环境背景'),
              value: settings.musicDynamicBackground,
              onChanged: notifier.setMusicDynamicBackground,
            ),
            _SliderTile(
              title: '动效强度',
              value: settings.musicAnimationIntensity,
              min: 0,
              max: 1.5,
              divisions: 6,
              label: '${(settings.musicAnimationIntensity * 100).round()}%',
              onChanged: notifier.setMusicAnimationIntensity,
            ),
          ]),
          _Group(title: '播放行为', children: [
            _SliderTile(
              title: '默认音量',
              value: settings.musicDefaultVolume,
              min: 0,
              max: 100,
              divisions: 20,
              label: '${settings.musicDefaultVolume.round()}%',
              onChanged: notifier.setMusicDefaultVolume,
            ),
            _SliderTile(
              title: '默认倍速',
              value: settings.musicDefaultRate,
              min: 0.5,
              max: 2,
              divisions: 6,
              label: '${settings.musicDefaultRate.toStringAsFixed(2)}x',
              onChanged: notifier.setMusicDefaultRate,
            ),
            SwitchListTile.adaptive(
              title: const Text('打开歌曲后自动播放'),
              value: settings.musicAutoPlay,
              onChanged: notifier.setMusicAutoPlay,
            ),
          ]),
          _Group(title: '歌词', children: [
            _SliderTile(
              title: '歌词字号',
              value: settings.musicLyricsFontSize,
              min: 14,
              max: 32,
              divisions: 9,
              label: '${settings.musicLyricsFontSize.round()} px',
              onChanged: notifier.setMusicLyricsFontSize,
            ),
            _SliderTile(
              title: '歌词时间偏移',
              value: settings.musicLyricsOffset.toDouble(),
              min: -5000,
              max: 5000,
              divisions: 20,
              label: '${settings.musicLyricsOffset} ms',
              onChanged: (value) =>
                  notifier.setMusicLyricsOffset(value.round()),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Group({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            color: scheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String label;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(title), Text(label)],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: label,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
