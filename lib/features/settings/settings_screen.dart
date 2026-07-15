import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/media_folder.dart';
import '../../providers/media_provider.dart';
import '../../providers/settings_provider.dart';

/// Settings screen: theme mode, default view, group mode and scan folders.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('外观'),
          _ThemeTile(settings: settings, notifier: notifier),
          SwitchListTile(
            title: const Text('默认网格视图'),
            subtitle: const Text('关闭则使用列表视图'),
            value: settings.isGridView,
            onChanged: (v) => notifier.setGridView(v),
          ),
          const Divider(),
          _SectionTitle('媒体分组'),
          ...GroupMode.values.map(
            (m) => RadioListTile<GroupMode>(
              title: Text(m.label),
              value: m,
              groupValue: settings.groupMode,
              onChanged: (v) => notifier.setGroupMode(v!),
            ),
          ),
          const Divider(),
          _SectionTitle('扫描文件夹'),
          Text(
            '应用会递归扫描以下文件夹中的图片、视频和音乐。',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          if (settings.scanFolders.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('尚未配置，将扫描默认图片/视频/音乐目录。'),
            ),
          ...settings.scanFolders.map(
            (path) => ListTile(
              leading: const Icon(Icons.folder),
              title: Text(path, style: const TextStyle(fontSize: 13)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => notifier.removeFolder(path),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.add),
            label: const Text('添加文件夹'),
            onPressed: () => _pickFolder(ref, notifier),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFolder(
    WidgetRef ref,
    SettingsNotifier notifier,
  ) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null && result.isNotEmpty) {
      await notifier.addFolder(result);
      // New folder list triggers a rescan via the media provider.
      await ref.read(mediaProvider.notifier).rescan();
    }
  }
}

class _ThemeTile extends ConsumerWidget {
  final AppSettings settings;
  final SettingsNotifier notifier;

  const _ThemeTile({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = {
      ThemeMode.system: '跟随系统',
      ThemeMode.light: '浅色',
      ThemeMode.dark: '深色',
    };
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('主题'),
      trailing: DropdownButton<ThemeMode>(
        value: settings.themeMode,
        underline: const SizedBox.shrink(),
        items: entries.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (m) => notifier.setThemeMode(m!),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      );
}
