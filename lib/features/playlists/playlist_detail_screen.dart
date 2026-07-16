import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/media_item.dart';
import '../../models/media_type.dart';
import '../../models/playlist.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/media_list_view.dart';
import '../player/music_player_screen.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = playlist.items ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.name),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.playlist_play),
              tooltip: '播放全部',
              onPressed: () {
                final audioItems = items.where((i) => i.type == MediaType.audio).toList();
                if (audioItems.isNotEmpty) {
                  ref.read(playbackControllerProvider.notifier).openPlaylist(audioItems, 0);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MusicPlayerScreen()),
                  );
                }
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text('播放列表为空'))
          : MediaListView(
              items: items,
              onTap: (i) {
                final audioItems = items.where((i) => i.type == MediaType.audio).toList();
                final idx = audioIndex(items[i], audioItems);
                if (idx >= 0) {
                  ref.read(playbackControllerProvider.notifier).openPlaylist(audioItems, idx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MusicPlayerScreen()),
                  );
                }
              },
              onSecondaryTap: (i) => _showItemMenu(context, ref, items[i]),
            ),
    );
  }

  int audioIndex(MediaItem item, List<MediaItem> audioItems) {
    for (int j = 0; j < audioItems.length; j++) {
      if (audioItems[j].path == item.path) return j;
    }
    return -1;
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
              title: const Text('从播放列表移除'),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(playlistManagerProvider).removeItem(playlist.id!, item.path);
              },
            ),
          ],
        ),
      ),
    );
  }
}
