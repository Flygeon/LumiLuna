import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/media_item.dart';
import '../../models/media_type.dart';
import '../../providers/media_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/async_view.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_context_sheet.dart';
import '../../widgets/media_grid_view.dart';
import '../../widgets/media_list_view.dart';
import '../player/image_viewer_screen.dart';
import '../player/music_player_screen.dart';
import '../player/video_player_screen.dart';

/// Displays all media items the user has marked as favourites.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mediaProvider);
    final isGrid = ref.watch(settingsProvider.select((s) => s.isGridView));
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favorite)),
      body: AsyncView<List<MediaItem>>(
        value: async,
        onRetry: () => ref.read(mediaProvider.notifier).retry(),
        builder: (all) {
          final items = all.where((i) => i.isFavorite).toList();

          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.star_border,
              title: l10n.favoritesEmpty,
              message: l10n.favoritesEmptyHint,
            );
          }

          return isGrid
              ? MediaGridView(
                  items: items,
                  onTap: (i) => openMedia(context, ref, items, i),
                  onSecondaryTap: (i) => MediaContextSheet.show(
                    context: context,
                    item: items[i],
                    ref: ref,
                  ),
                )
              : MediaListView(
                  items: items,
                  onTap: (i) => openMedia(context, ref, items, i),
                  onSecondaryTap: (i) => MediaContextSheet.show(
                    context: context,
                    item: items[i],
                    ref: ref,
                  ),
                );
        },
      ),
    );
  }
}

/// Opens the correct player for [items] at [index].
/// Duplicated from [media_type_screen] because [FavoritesScreen] mixes
/// media types and the filtered playlists should respect the whole set.
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
