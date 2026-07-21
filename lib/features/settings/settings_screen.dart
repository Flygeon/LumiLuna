import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'about_screen.dart';
import 'settings_category_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('图片', Icons.image_outlined, SettingsCategory.image, '图片排列方式和浏览体验'),
      ('视频', Icons.movie_outlined, SettingsCategory.video, '视频排列方式和缩略图体验'),
      ('音乐', Icons.music_note_outlined, SettingsCategory.music, '播放器、歌词和专辑封面'),
      ('通用', Icons.tune_outlined, SettingsCategory.general, '主题、语言、媒体库和缓存'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(title ?? context.l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ...entries.map((entry) => _SettingsEntry(
                title: entry.$1,
                subtitle: entry.$4,
                icon: entry.$2,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SettingsCategoryScreen(category: entry.$3),
                )),
              )),
          _SettingsEntry(
            title: context.l10n.about,
            subtitle: context.l10n.aboutDesc,
            icon: Icons.info_outline,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
        ],
      ),
    );
  }
}

class _SettingsEntry extends StatelessWidget {
  const _SettingsEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Icon(icon, color: scheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
