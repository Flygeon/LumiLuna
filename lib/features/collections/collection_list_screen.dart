import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/collection_provider.dart';
import 'collection_detail_screen.dart';

class CollectionListScreen extends ConsumerWidget {
  const CollectionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(collectionsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('收藏集')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (collections) {
          if (collections.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.collections_bookmark, size: 64, color: scheme.outline),
                  const SizedBox(height: 16),
                  Text('暂无收藏集', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('创建收藏集来整理您的媒体文件'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final col = collections[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.collections_bookmark, color: scheme.primary),
                ),
                title: Text(col.name),
                subtitle: Text('${col.itemCount} 项 · 更新于 ${_formatDate(col.updatedAt)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('删除收藏集'),
                        content: Text('确定删除"${col.name}"吗？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('删除')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      ref.read(collectionManagerProvider).delete(col.id!);
                    }
                  },
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CollectionDetailScreen(collection: col)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('新建收藏集'),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建收藏集'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: '收藏集名称'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (ok == true && controller.text.trim().isNotEmpty) {
      ref.read(collectionManagerProvider).create(controller.text.trim());
    }
  }
}
