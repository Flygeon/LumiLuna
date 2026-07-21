import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/media_item.dart';
import '../../models/media_type.dart';
import '../../providers/filter_provider.dart';
import '../../providers/media_provider.dart';
import '../../providers/player_provider.dart';
import '../../main.dart';
import '../../providers/play_history_provider.dart';
import '../../providers/selection_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/async_view.dart';
import '../../widgets/batch_action_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_context_sheet.dart';
import '../../widgets/media_grid_view.dart';
import '../../widgets/media_list_view.dart';
import '../player/image_viewer_screen.dart';
import '../player/music_player_screen.dart';
import '../player/video_player_screen.dart';
import '../books/book_reader_screen.dart';

/// Generic tab body listing all media of a single [MediaType], honouring the
/// current search query and grid/list preference, and opening the appropriate
/// player on tap.
///
/// Supports batch selection via long-press. When in selection mode, tapping
/// toggles selection instead of opening the player.
class MediaTypeScreen extends ConsumerStatefulWidget {
  final MediaType type;

  const MediaTypeScreen({super.key, required this.type});

  @override
  ConsumerState<MediaTypeScreen> createState() => _MediaTypeScreenState();
}

class _MediaTypeScreenState extends ConsumerState<MediaTypeScreen> {
  /// Unique selection scope for this media-type tab.
  String get _selectionId => 'media_${widget.type.name}';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(searchedMediaProvider).whenData(
          (items) => items.where((item) => item.type == widget.type).toList(),
        );
    final query = ref.watch(searchQueryProvider).trim();
    final settings = ref.watch(settingsProvider);
    final isGrid = settings.isGridView;
    final density = switch (widget.type) {
      MediaType.image => settings.imageLayoutDensity,
      MediaType.video => settings.videoLayoutDensity,
      MediaType.audio => MediaLayoutDensity.standard,
      MediaType.book => MediaLayoutDensity.standard,
    };
    final sel = ref.watch(selectionProvider(_selectionId));
    final l10n = context.l10n;

    return AsyncView<List<MediaItem>>(
      value: async,
      onRetry: () => ref.read(mediaProvider.notifier).retry(),
      builder: (items) {
        if (items.isEmpty) {
          final typeLabel = mediaTypeName(context, widget.type);
          return EmptyState(
            icon: widget.type.icon,
            title: query.isEmpty
                ? l10n.noItems(typeLabel)
                : l10n.noMatch(typeLabel),
            message: query.isEmpty
                ? l10n.emptyAddFolderHint
                : l10n.tryAnotherKeyword,
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(mediaProvider.notifier).rescan(),
                child: isGrid
                    ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: MediaGridView(
                          key: ValueKey(density),
                          items: items,
                          density: density,
                          onTap: (i) => _onItemTap(items, i, sel),
                          onLongPress: (i) => _onItemLongPress(items, i),
                          onSecondaryTap: sel.isSelecting
                              ? null
                              : (i) => MediaContextSheet.show(
                                    context: context,
                                    item: items[i],
                                    ref: ref,
                                    selectionId: _selectionId,
                                  ),
                          selectedPaths: sel.selected,
                        ),
                      )
                    : MediaListView(
                        items: items,
                        onTap: (i) => _onItemTap(items, i, sel),
                        onLongPress: (i) => _onItemLongPress(items, i),
                        onSecondaryTap: sel.isSelecting
                            ? null
                            : (i) => MediaContextSheet.show(
                                  context: context,
                                  item: items[i],
                                  ref: ref,
                                  selectionId: _selectionId,
                                ),
                        selectedPaths: sel.selected,
                      ),
              ),
            ),
            // Batch action bar at the bottom when in selection mode.
            if (sel.isSelecting) BatchActionBar(selectionId: _selectionId),
          ],
        );
      },
    );
  }

  Future<void> _onItemTap(
    List<MediaItem> items,
    int index,
    SelectionState sel,
  ) async {
    final item = items[index];
    if (sel.isSelecting) {
      // Toggle selection.
      ref.read(selectionProvider(_selectionId).notifier).toggle(item.path);
    } else {
      await openMedia(context, ref, items, index);
    }
  }

  void _onItemLongPress(List<MediaItem> items, int index) {
    final item = items[index];
    // On mobile (no mouse) the user expects a context menu, just like the
    // right-click menu on Windows. The menu has a "多选" entry-point so the
    // user can still get into batch-selection mode intentionally.
    // On desktop, keep the previous behaviour: long-press == enter selection.
    if (!kIsWeb && !Platform.isWindows) {
      MediaContextSheet.show(
        context: context,
        item: item,
        ref: ref,
        selectionId: _selectionId,
      );
      return;
    }
    final notifier = ref.read(selectionProvider(_selectionId).notifier);
    if (!ref.read(selectionProvider(_selectionId)).isSelecting) {
      // Enter selection mode and select this item.
      notifier.startSelection({item.path});
    } else {
      notifier.toggle(item.path);
    }
  }
}

/// Opens the correct player for [items] at [index]:
/// - images  -> swipeable viewer
/// - videos  -> media_kit video screen (continuous playlist)
/// - audio   -> music player with playlist
///
/// Shared so the folder detail view can reuse identical behaviour.
Future<void> openMedia(
  BuildContext context,
  WidgetRef ref,
  List<MediaItem> items,
  int index,
) async {
  final item = items[index];
  switch (item.type) {
    case MediaType.image:
      final images = items.where((i) => i.type == MediaType.image).toList();
      final start = images.indexOf(item);
      ref.read(appDatabaseProvider).recordPlay(item.path).then(
            (_) => ref.invalidate(playHistoryProvider),
          );
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
      await ref
          .read(playbackControllerProvider.notifier)
          .openAudioPlaylist(tracks, start < 0 ? 0 : start);
      if (!context.mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const MusicPlayerScreen(),
      ));
      break;
    case MediaType.book:
      ref.read(appDatabaseProvider).recordPlay(item.path).then(
            (_) => ref.invalidate(playHistoryProvider),
          );
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BookReaderScreen(item: item),
      ));
      break;
  }
}
