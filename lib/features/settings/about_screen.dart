import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/format_utils.dart';
import '../../l10n/l10n.dart';
import '../../services/cache_manager.dart';
import '../../services/github_update_service.dart';
import '../../providers/settings_provider.dart';

final packageInfoProvider =
    FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(packageInfoProvider);
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.about)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Icon(Icons.auto_awesome,
                    size: 56, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                info.when(
                  data: (value) => Text(
                      '${context.l10n.version}: ${value.version} (${value.buildNumber})'),
                  loading: () => const Text('…'),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: Text(context.l10n.clearCache),
                  subtitle: const _CacheSizeText(),
                  onTap: () => _clearCache(context),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(context.l10n.viewLicenses),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppConstants.appName,
                  ),
                ),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.sync_outlined),
                  title: const Text('自动检查更新'),
                  subtitle: const Text('启动应用时检查 GitHub 最新版本'),
                  value: settings.autoUpdate,
                  onChanged: ref.read(settingsProvider.notifier).setAutoUpdate,
                ),
                ListTile(
                  leading: const Icon(Icons.system_update_outlined),
                  title: const Text('检查更新'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _checkUpdate(context, ref, info),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkUpdate(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<PackageInfo> info,
  ) async {
    final current = info.valueOrNull?.version;
    if (current == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在检查更新…')),
    );
    final release = await GithubUpdateService.checkForUpdate(current);
    if (!context.mounted) return;
    if (release == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('当前已是最新版本')),
      );
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('发现新版本 ${release.version}'),
        content: SingleChildScrollView(
          child: Text(release.body.isEmpty ? release.name : release.body),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('稍后提醒'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              await _openRelease(release.url);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('查看详情'),
          ),
          FilledButton(
            onPressed: () async {
              await _openRelease(release.url);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('立即更新'),
          ),
        ],
      ),
    );
  }

  Future<void> _openRelease(String url) async {
    final process = await Process.start('cmd', ['/c', 'start', '', url]);
    await process.exitCode;
  }

  Future<void> _clearCache(BuildContext context) async {
    final freed = await CacheManager.clearAll();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(context.l10n.cacheCleared(FormatUtils.fileSize(freed)))),
      );
    }
  }
}

class _CacheSizeText extends StatefulWidget {
  const _CacheSizeText();

  @override
  State<_CacheSizeText> createState() => _CacheSizeTextState();
}

class _CacheSizeTextState extends State<_CacheSizeText> {
  int? _size;

  @override
  void initState() {
    super.initState();
    CacheManager.getCacheSize().then((value) {
      if (mounted) setState(() => _size = value);
    });
  }

  @override
  Widget build(BuildContext context) => Text(
        _size == null ? '计算中…' : FormatUtils.fileSize(_size!),
      );
}
