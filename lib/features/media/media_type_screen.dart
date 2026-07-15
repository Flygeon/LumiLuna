import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/media_item.dart';
import '../../models/media_type.dart';
import '../../providers/filter_provider.dart';
import '../../providers/media_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/async_view.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_grid_view.dart';
import '../../widgets/media_list_view.dart';
import '../player/image_viewer_screen.dart';
import '../player/music_player_screen.dart';
import '../player/video_player_screen.dart';

/// Generic tab body listing all media of a single [MediaType], honouring the
/// current search query and grid/list preference, and opening the appropriate
/// player on tap.
class MediaTypeScreen extends ConsumerWidget {
  final MediaType type;

  const MediaTypeScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mediaByTypeProvider(type));
    final query = ref.watch(searchQueryProvider).trim().toLowerCase();
    final isGrid = ref.watch(settingsProvider.select((s) => s.isGridView));

    return AsyncView<List<MediaItem>>(
      value: async,
      onRetry: () => ref.read(mediaProvider.notifier).rescan(),
      builder: (all) {
        final items = query.isEmpty
            ? all
            : all
                .where((i) => i.name.toLowerCase().contains(query))
                .toList();

        if (items.isEmpty) {
          return EmptyState(
            icon: type.icon,
            title: query.isEmpty ? '没有${type.label}文件' : '没有匹配的${type.label}',
            message: query.isEmpty
                ? '在右上角菜单进入设置，添加要扫描的文件夹后下拉刷新'
                : '换个关键词再试试',
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(mediaProvider.notifier).rescan(),
          child: isGrid
              ? MediaGridView(
                  items: items,
                  onTap: (i) => openMedia(context, ref, items, i),
                )
              : MediaListView(
                  items: items,
                  onTap: (i) => openMedia(context, ref, items, i),
                ),
        );
      },
    );
  }
}

/// Opens the correct player for [items] at [index]:
/// - images  -> swipeable viewer
/// - videos  -> media_kit video screen (continuous playlist)
/// - audio   -> music player with playlist
///
/// Shared so the folder detail view can reuse identical behaviour.
void openMedia(
  BuildContext context,
  WidgetRef ref,
  List<MediaItem> items,
  int index,
) {
  final item = items[index];
  switch (item.type) {
    case MediaType.image:
      final images = items.where((i) => i.type == MediaType.image).toList();
      final start = images.indexOf(item);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ImageViewerScreen(
          items: images,
          initialIndex: start < 0 ? 0 : start,
        ),
      ));
      break;
    case MediaType.video:
      final videos = items.where((i) => i.type == MediaType.video).toList();
      final start = videos.indexOf(item);
      ref
          .read(playbackControllerProvider.notifier)
          .openPlaylist(videos, start < 0 ? 0 : start);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const VideoPlayerScreen(),
      ));
      break;
    case MediaType.audio:
      final tracks = items.where((i) => i.type == MediaType.audio).toList();
      final start = tracks.indexOf(item);
      ref
          .read(playbackControllerProvider.notifier)
          .openPlaylist(tracks, start < 0 ? 0 : start);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const MusicPlayerScreen(),
      ));
      break;
  }
}
