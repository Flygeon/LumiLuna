import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/format_utils.dart';
import '../../l10n/l10n.dart';
import '../../models/media_folder.dart';
import '../../providers/media_provider.dart';
import '../../providers/settings_provider.dart';

/// Provides the app's [PackageInfo] (version / build number) for the About page.
final packageInfoProvider =
    FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

/// Settings screen: theme mode, default view, group mode, scan folders,
/// language, cache management and an About / licenses section.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final pkg = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _SettingsGroup(title: '图片', icon: Icons.image_outlined, children: [
            _LayoutDensityTile(
                title: '图片排列方式',
                value: settings.imageLayoutDensity,
                onChanged: notifier.setImageLayoutDensity),
          ]),
          _SettingsGroup(title: '视频', icon: Icons.movie_outlined, children: [
            _LayoutDensityTile(
                title: '视频排列方式',
                value: settings.videoLayoutDensity,
                onChanged: notifier.setVideoLayoutDensity),
          ]),
          _SettingsGroup(
              title: '音乐',
              icon: Icons.music_note_outlined,
              children: [
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
                  padding: const EdgeInsetsDirectional.only(
                    start: 72,
                    end: 16,
                  ),
                  onChanged: notifier.setLyricsFontSize,
                ),
              ]),
          _SettingsGroup(title: '通用', icon: Icons.tune_outlined, children: [
            _ThemeTile(settings: settings, notifier: notifier),
            _ThemeColorTile(settings: settings, notifier: notifier),
            if (Platform.isAndroid)
              SwitchListTile.adaptive(
                title: const Text('动态取色'),
                subtitle: const Text('使用 Android 系统主题色'),
                value: settings.dynamicColor,
                onChanged: notifier.setDynamicColor,
              ),
            SwitchListTile.adaptive(
              title: Text(l10n.defaultGridView),
              subtitle: Text(l10n.offListView),
              value: settings.isGridView,
              onChanged: notifier.setGridView,
            ),
            _LocaleTile(settings: settings, notifier: notifier),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: Text(l10n.mediaGrouping),
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
                title: Text(l10n.scanFoldersTitle),
                subtitle: Text('${settings.scanFolders.length} 个文件夹'),
                onTap: () =>
                    _showFolders(context, ref, notifier, settings.scanFolders)),
            ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),
                title: Text(l10n.clearCache),
                onTap: () => _clearCache(context)),
            ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.version),
                subtitle: pkg.when(
                    data: (p) => Text('${p.version} (${p.buildNumber})'),
                    loading: () => const Text('…'),
                    error: (_, __) => const Text(''))),
            ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.viewLicenses),
                onTap: () => showLicensePage(
                    context: context, applicationName: AppConstants.appName)),
          ]),
        ],
      ),
    );
  }

  Future<void> _showFolders(BuildContext context, WidgetRef ref,
      SettingsNotifier notifier, List<String> folders) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Text(context.l10n.scanFoldersDesc),
            ...folders.map((path) => ListTile(
                leading: const Icon(Icons.folder),
                title: Text(path),
                trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => notifier.removeFolder(path)))),
            FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addFolder),
                onPressed: () async {
                  Navigator.pop(context);
                  await _pickFolder(ref, notifier);
                }),
          ],
        ),
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

  /// Delete the cached video thumbnails and audio cover-art directories and
  /// report how much disk space was freed.
  Future<void> _clearCache(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final cacheDir = await getTemporaryDirectory();
      var freed = 0;
      for (final name in const ['lumiluna_thumbs', 'lumiluna_artwork']) {
        final dir = Directory('${cacheDir.path}/$name');
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: true)) {
            if (entity is File) freed += await entity.length();
          }
          await dir.delete(recursive: true);
        }
      }
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
              content:
                  Text(context.l10n.cacheCleared(FormatUtils.fileSize(freed)))),
        );
      }
    } catch (_) {
      // Best-effort cleanup; ignore individual failures.
    }
  }
}

class _ThemeTile extends ConsumerWidget {
  final AppSettings settings;
  final SettingsNotifier notifier;

  const _ThemeTile({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final entries = {
      ThemeMode.system: l10n.themeSystem,
      ThemeMode.light: l10n.themeLight,
      ThemeMode.dark: l10n.themeDark,
    };
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: Text(l10n.theme),
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

class _ThemeColorTile extends StatelessWidget {
  final AppSettings settings;
  final SettingsNotifier notifier;

  const _ThemeColorTile({required this.settings, required this.notifier});

  static const colors = [
    Color(0xFF527A72),
    Color(0xFF8C6E63),
    Color(0xFF657A9A),
    Color(0xFF9A6A84),
    Color(0xFF7C8450),
    Color(0xFFB06A4F),
  ];

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.color_lens_outlined),
      title: const Text('主题色'),
      subtitle: const Text('莫奈配色'),
      trailing: Wrap(
        spacing: 8,
        children: colors
            .map(
              (color) => GestureDetector(
                onTap: () => notifier.setThemeSeed(color.toARGB32()),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: color,
                  child: settings.themeSeed == color.toARGB32()
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LocaleTile extends ConsumerWidget {
  final AppSettings settings;
  final SettingsNotifier notifier;

  const _LocaleTile({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current =
        settings.localeTag.isEmpty ? null : Locale(settings.localeTag);
    final entries = <Locale?, String>{
      null: l10n.langSystem,
      const Locale('zh'): l10n.langChinese,
      const Locale('en'): l10n.langEnglish,
    };
    return ListTile(
      leading: const Icon(Icons.language_outlined),
      title: Text(l10n.language),
      trailing: DropdownButton<Locale?>(
        value: current,
        underline: const SizedBox.shrink(),
        items: entries.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (loc) =>
            notifier.setLocale(loc == null ? '' : loc.languageCode),
      ),
    );
  }
}

class _LayoutDensityTile extends StatelessWidget {
  final String title;
  final MediaLayoutDensity value;
  final ValueChanged<MediaLayoutDensity> onChanged;

  const _LayoutDensityTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.grid_view_outlined),
      title: Text(title),
      trailing: SegmentedButton<MediaLayoutDensity>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: MediaLayoutDensity.standard,
            label: Text('标准'),
          ),
          ButtonSegment(
            value: MediaLayoutDensity.compact,
            label: Text('紧密'),
          ),
        ],
        selected: {value},
        onSelectionChanged: (selected) => onChanged(selected.first),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsGroup(
      {required this.title, required this.icon, required this.children});

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
            child: Row(
              children: [
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: scheme.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            color: scheme.surfaceContainerLowest,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
