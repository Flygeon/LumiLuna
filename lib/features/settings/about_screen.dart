import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/format_utils.dart';
import '../../l10n/l10n.dart';
import '../../services/cache_manager.dart';

final packageInfoProvider =
    FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(packageInfoProvider);
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
              ],
            ),
          ),
        ],
      ),
    );
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
