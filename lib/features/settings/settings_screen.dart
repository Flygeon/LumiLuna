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
final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

/// Settings screen: theme mode, default view, group mode, scan folders,
/// language, cache management and an About / licenses section.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final pkg = ref.watch(packageInfoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(l10n.appearance),
          _ThemeTile(settings: settings, notifier: notifier),
          SwitchListTile(
            title: Text(l10n.defaultGridView),
            subtitle: Text(l10n.offListView),
            value: settings.isGridView,
            onChanged: (v) => notifier.setGridView(v),
          ),
          if (settings.isGridView)
            _LayoutDensityTile(
              title: '图片排列方式',
              value: settings.imageLayoutDensity,
              onChanged: notifier.setImageLayoutDensity,
            ),
          if (settings.isGridView)
            _LayoutDensityTile(
              title: '视频排列方式',
              value: settings.videoLayoutDensity,
              onChanged: notifier.setVideoLayoutDensity,
            ),
          const Divider(),
          _SectionTitle(l10n.mediaGrouping),
          ...GroupMode.values.map(
            (m) => RadioListTile<GroupMode>(
              title: Text(groupModeName(context, m)),
              value: m,
              groupValue: settings.groupMode,
              onChanged: (v) => notifier.setGroupMode(v!),
            ),
          ),
          const Divider(),
          _SectionTitle(l10n.scanFoldersTitle),
          Text(
            l10n.scanFoldersDesc,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          if (settings.scanFolders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(l10n.noFoldersConfigured),
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
            label: Text(l10n.addFolder),
            onPressed: () => _pickFolder(ref, notifier),
          ),
          const Divider(),
          _SectionTitle(l10n.language),
          _LocaleTile(settings: settings, notifier: notifier),
          const Divider(),
          _SectionTitle(l10n.cacheTitle),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(l10n.clearCache),
            onTap: () => _clearCache(context),
          ),
          const Divider(),
          _SectionTitle(l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            subtitle: pkg.when(
              data: (p) => Text('${p.version} (${p.buildNumber})'),
              loading: () => const Text('…'),
              error: (_, __) => const Text(''),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.viewLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: AppConstants.appName,
            ),
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
          SnackBar(content: Text(context.l10n.cacheCleared(FormatUtils.fileSize(freed)))),
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

class _LocaleTile extends ConsumerWidget {
  final AppSettings settings;
  final SettingsNotifier notifier;

  const _LocaleTile({required this.settings, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = settings.localeTag.isEmpty ? null : Locale(settings.localeTag);
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
        onChanged: (loc) => notifier.setLocale(loc == null ? '' : loc.languageCode),
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
