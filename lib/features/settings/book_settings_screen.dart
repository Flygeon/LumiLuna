import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';

class BookSettingsScreen extends ConsumerWidget {
  const BookSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('图书设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('阅读主题'),
                  trailing: DropdownButton<BookTheme>(
                    value: settings.bookTheme,
                    items: const [
                      DropdownMenuItem(
                          value: BookTheme.light, child: Text('浅色')),
                      DropdownMenuItem(
                          value: BookTheme.dark, child: Text('深色')),
                      DropdownMenuItem(
                          value: BookTheme.sepia, child: Text('护眼')),
                    ],
                    onChanged: (value) {
                      if (value != null) notifier.setBookTheme(value);
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: Text('字体大小 ${settings.bookFontSize.toInt()}'),
                ),
                Slider(
                  value: settings.bookFontSize,
                  min: 12,
                  max: 28,
                  divisions: 8,
                  onChanged: notifier.setBookFontSize,
                ),
                ListTile(
                  leading: const Icon(Icons.view_agenda_outlined),
                  title: const Text('页面布局'),
                  trailing: SegmentedButton<BookLayout>(
                    segments: const [
                      ButtonSegment(
                          value: BookLayout.scroll, label: Text('滚动')),
                      ButtonSegment(
                          value: BookLayout.paginated, label: Text('分页')),
                    ],
                    selected: {settings.bookLayout},
                    onSelectionChanged: (value) =>
                        notifier.setBookLayout(value.first),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
