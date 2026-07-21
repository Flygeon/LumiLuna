import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/media_folder.dart';
import '../../providers/media_provider.dart';
import '../../providers/settings_provider.dart';

enum SettingsCategory { image, video, music, general }

class SettingsCategoryScreen extends ConsumerWidget {
  const SettingsCategoryScreen({super.key, required this.category});

  final SettingsCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final title = switch (category) {
      SettingsCategory.image => '图片',
      SettingsCategory.video => '视频',
      SettingsCategory.music => '音乐',
      SettingsCategory.general => '通用',
    };
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (category == SettingsCategory.image)
            _Group(title, Icons.image_outlined, [
              _DensityTile(
                  settings.imageLayoutDensity, notifier.setImageLayoutDensity),
            ]),
          if (category == SettingsCategory.video)
            _Group(title, Icons.movie_outlined, [
              _DensityTile(
                  settings.videoLayoutDensity, notifier.setVideoLayoutDensity),
            ]),
          if (category == SettingsCategory.music)
            _Group(title, Icons.music_note_outlined, [
              SwitchListTile.adaptive(
                title: const Text('播放器背景模糊'),
                subtitle: const Text('使用专辑封面作为柔和的模糊背景'),
                value: settings.musicBackgroundBlur,
                onChanged: notifier.setMusicBackgroundBlur,
              ),
              SwitchListTile.adaptive(
                title: const Text('歌词模糊效果'),
                subtitle: const Text('弱化非当前播放歌词，突出当前歌词'),
                value: settings.lyricsBlur,
                onChanged: notifier.setLyricsBlur,
              ),
              ListTile(
                leading: const Icon(Icons.text_fields_outlined),
                title: const Text('歌词字号'),
                subtitle: Text('${settings.lyricsFontSize.toInt()} px'),
              ),
              Slider(
                value: settings.lyricsFontSize,
                min: 12,
                max: 24,
                divisions: 6,
                label: '${settings.lyricsFontSize.toInt()} px',
                padding: const EdgeInsetsDirectional.only(start: 72, end: 16),
                onChanged: notifier.setLyricsFontSize,
              ),
            ]),
          if (category == SettingsCategory.general)
            _GeneralGroup(settings: settings, notifier: notifier, ref: ref),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.title, this.icon, this.children);
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Row(children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  color: scheme.primary, fontWeight: FontWeight.w700)),
        ]),
      ),
      Card(
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(children: children),
      ),
    ]);
  }
}

class _DensityTile extends StatelessWidget {
  const _DensityTile(this.value, this.onChanged);
  final MediaLayoutDensity value;
  final ValueChanged<MediaLayoutDensity> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.grid_view_outlined),
        title: const Text('排列方式'),
        trailing: SegmentedButton<MediaLayoutDensity>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
                value: MediaLayoutDensity.standard, label: Text('标准')),
            ButtonSegment(value: MediaLayoutDensity.compact, label: Text('紧密')),
          ],
          selected: {value},
          onSelectionChanged: (selected) => onChanged(selected.first),
        ),
      );
}

class _GeneralGroup extends StatelessWidget {
  const _GeneralGroup(
      {required this.settings, required this.notifier, required this.ref});
  final AppSettings settings;
  final SettingsNotifier notifier;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) => _Group('通用', Icons.tune_outlined, [
        _ThemeTile(settings, notifier),
        SwitchListTile.adaptive(
          title: Text(context.l10n.defaultGridView),
          subtitle: Text(context.l10n.offListView),
          value: settings.isGridView,
          onChanged: notifier.setGridView,
        ),
        ListTile(
          leading: const Icon(Icons.category_outlined),
          title: Text(context.l10n.mediaGrouping),
          trailing: DropdownButton<GroupMode>(
            value: settings.groupMode,
            underline: const SizedBox.shrink(),
            items: GroupMode.values
                .map((m) => DropdownMenuItem(
                    value: m, child: Text(groupModeName(context, m))))
                .toList(),
            onChanged: (m) => notifier.setGroupMode(m!),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.folder_outlined),
          title: Text(context.l10n.scanFoldersTitle),
          subtitle: Text('${settings.scanFolders.length} 个文件夹'),
          onTap: () => _showFolders(context),
        ),
      ]);

  Future<void> _showFolders(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(ctx.l10n.scanFoldersDesc),
            ...settings.scanFolders.map((path) => ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(path),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => notifier.removeFolder(path),
                  ),
                )),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.add),
              label: Text(ctx.l10n.addFolder),
              onPressed: () async {
                Navigator.pop(ctx);
                final path = await FilePicker.platform.getDirectoryPath();
                if (path != null && path.isNotEmpty) {
                  await notifier.addFolder(path);
                  await ref.read(mediaProvider.notifier).rescan();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile(this.settings, this.notifier);
  final AppSettings settings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.palette_outlined),
        title: Text(context.l10n.theme),
        trailing: DropdownButton<ThemeMode>(
          value: settings.themeMode,
          underline: const SizedBox.shrink(),
          items: [
            DropdownMenuItem(
                value: ThemeMode.system, child: Text(context.l10n.themeSystem)),
            DropdownMenuItem(
                value: ThemeMode.light, child: Text(context.l10n.themeLight)),
            DropdownMenuItem(
                value: ThemeMode.dark, child: Text(context.l10n.themeDark)),
          ],
          onChanged: (mode) => notifier.setThemeMode(mode!),
        ),
      );
}
