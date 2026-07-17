import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/media_folder.dart';
import '../../models/media_item.dart';
import '../../providers/selection_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/batch_action_bar.dart';
import '../../widgets/media_context_sheet.dart';
import '../../widgets/media_grid_view.dart';
import '../../widgets/media_list_view.dart';
import '../media/media_type_screen.dart';

/// Shows the media items contained in a single [MediaFolder] group.
///
/// Supports batch selection via long-press.
class FolderDetailScreen extends ConsumerStatefulWidget {
  final MediaFolder folder;

  const FolderDetailScreen({super.key, required this.folder});

  @override
  ConsumerState<FolderDetailScreen> createState() =>
      _FolderDetailScreenState();
}

class _FolderDetailScreenState extends ConsumerState<FolderDetailScreen> {
  String get _selectionId => 'folder_detail_${widget.folder.label}';

  @override
  Widget build(BuildContext context) {
    final isGrid = ref.watch(settingsProvider.select((s) => s.isGridView));
    final items = widget.folder.items;
    final sel = ref.watch(selectionProvider(_selectionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.label,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: isGrid ? context.l10n.listView : context.l10n.gridView,
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => ref.read(settingsProvider.notifier).toggleView(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isGrid
                ? MediaGridView(
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
          if (sel.isSelecting) BatchActionBar(selectionId: _selectionId),
        ],
      ),
    );
  }

  void _onItemTap(List<MediaItem> items, int index, SelectionState sel) {
    if (sel.isSelecting) {
      ref.read(selectionProvider(_selectionId).notifier).toggle(items[index].path);
    } else {
      openMedia(context, ref, items, index);
    }
  }

  void _onItemLongPress(List<MediaItem> items, int index) {
    final item = items[index];
    // On mobile, long-press opens the context menu (the menu has a "多选"
    // tile that lets the user enter batch-selection mode).
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
      notifier.startSelection({item.path});
    } else {
      notifier.toggle(item.path);
    }
  }
}
