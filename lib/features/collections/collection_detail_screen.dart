import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/collection.dart';
import '../../models/media_item.dart';
import '../../models/media_type.dart';
import '../../providers/collection_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/media_list_view.dart';
import '../media/media_type_screen.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final MediaCollection collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = collection.items ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(collection.name),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.playlist_play),
              tooltip: '播放全部',
              onPressed: () {
                final audioItems = items.where((i) => i.type == MediaType.audio).toList();
                if (audioItems.isNotEmpty) {
                  ref.read(playbackControllerProvider.notifier).openPlaylist(audioItems, 0);
                }
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.collections_bookmark, size: 64),
                  const SizedBox(height: 16),
                  const Text('收藏集为空'),
                  const SizedBox(height: 8),
                  Text('从媒体浏览页面添加到收藏集'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                // Refresh the collections data
                ref.invalidate(collectionsProvider);
              },
              child: MediaListView(
                items: items,
                onTap: (i) => openMedia(context, ref, items, i),
                onSecondaryTap: (i) => _showItemMenu(context, ref, items[i]),
              ),
            ),
    );
  }

  void _showItemMenu(BuildContext context, WidgetRef ref, MediaItem item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('从收藏集移除'),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(collectionManagerProvider).removeItem(collection.id!, item.path);
              },
            ),
          ],
        ),
      ),
    );
  }
}
