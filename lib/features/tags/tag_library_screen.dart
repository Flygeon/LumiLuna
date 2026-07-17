import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main.dart';
import '../../models/media_item.dart';
import '../../models/tag.dart';
import '../../providers/tag_provider.dart';
import '../../widgets/async_view.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_list_view.dart';
import '../media/media_type_screen.dart';

class TagLibraryScreen extends ConsumerWidget {
  const TagLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(tagsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类与标签'),
        actions: [
          IconButton(
            tooltip: '新建分类组',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _createGroup(context, ref),
          ),
        ],
      ),
      body: AsyncView<List<Tag>>(
        value: tags,
        onRetry: () => ref.invalidate(tagsProvider),
        builder: (items) {
          final groups = items.where((tag) => tag.isGroup).toList();
          final ungrouped = items
              .where((tag) => !tag.isGroup && tag.parentId == null)
              .toList();
          if (groups.isEmpty && ungrouped.isEmpty) {
            return const EmptyState(
              icon: Icons.label_outline,
              title: '暂无分类',
              message: '先在这里建立分类组，再为媒体添加标签',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final group in groups)
                _TagGroupCard(
                  group: group,
                  tags: items.where((tag) => tag.parentId == group.id).toList(),
                ),
              if (ungrouped.isNotEmpty)
                _TagGroupCard(
                  group: const Tag(name: '未分类', isGroup: true),
                  tags: ungrouped,
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('新建分类组'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: const InputDecoration(hintText: '例如：人物、地点、主题'),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('创建')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    try {
      await ref.read(tagManagerProvider).create(name, isGroup: true);
    } on ArgumentError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
  }
}

class _TagGroupCard extends ConsumerWidget {
  final Tag group;
  final List<Tag> tags;

  const _TagGroupCard({required this.group, required this.tags});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: const Icon(Icons.folder_outlined),
        title: Text(group.name),
        subtitle: Text('${tags.length} 个标签'),
        trailing: group.id == null
            ? null
            : IconButton(
                tooltip: '删除分类组',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => ref.read(tagManagerProvider).delete(group.id!),
              ),
        children: tags.isEmpty
            ? const [
                ListTile(title: Text('暂无标签'), subtitle: Text('批量选择媒体后可添加到此分类'))
              ]
            : tags
                .map((tag) => ListTile(
                      leading: CircleAvatar(
                          backgroundColor: tag.colorValue, radius: 6),
                      title: Text(tag.name),
                      trailing: IconButton(
                        tooltip: '删除标签',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            ref.read(tagManagerProvider).delete(tag.id!),
                      ),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => _TaggedMediaScreen(tag: tag),
                      )),
                    ))
                .toList(),
      ),
    );
  }
}

class _TaggedMediaScreen extends ConsumerWidget {
  final Tag tag;

  const _TaggedMediaScreen({required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(tag.name)),
      body: FutureBuilder<List<MediaItem>>(
        future: ref.read(appDatabaseProvider).getMediaItemsForTag(tag.id!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const EmptyState(
                icon: Icons.label_outline,
                title: '此标签暂无内容',
                message: '选择媒体并添加该标签后会显示在这里');
          }
          return MediaListView(
            items: items,
            onTap: (index) => openMedia(context, ref, items, index),
          );
        },
      ),
    );
  }
}
