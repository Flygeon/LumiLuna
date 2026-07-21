import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/collection_provider.dart';
import '../providers/media_provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/selection_provider.dart';
import '../main.dart';

import 'tag_editor_dialog.dart';

/// Bottom bar shown when in selection mode, with batch action buttons.
///
/// The action strip is horizontally scrollable so a long list of chips can
/// be swiped to access buttons that would otherwise overflow on narrow phones.
class BatchActionBar extends ConsumerWidget {
  final String selectionId;

  const BatchActionBar({super.key, required this.selectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(selectionProvider(selectionId));
    if (!sel.isSelecting) return const SizedBox.shrink();

    final count = sel.count;
    final paths = sel.selected.toList();
    final notifier = ref.read(selectionProvider(selectionId).notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header — count + cancel/clear-all buttons.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text('已选 $count 项',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  if (count > 0)
                    TextButton(
                      onPressed: notifier.clearSelection,
                      child: const Text('全部取消', style: TextStyle(fontSize: 12)),
                    ),
                  TextButton(
                    onPressed: notifier.endSelection,
                    child: const Text('退出', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Action strip — horizontally scrollable so every button is
            // reachable even on a phone with many actions.
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                physics: const BouncingScrollPhysics(),
                children: [
                  _ActionChip(
                    icon: Icons.favorite_outline,
                    label: '收藏',
                    onTap: () => _favorite(context, ref, paths),
                  ),
                  _ActionChip(
                    icon: Icons.label_outline,
                    label: '标签',
                    onTap: () => TagEditorDialog.show(context, paths),
                  ),
                  _ActionChip(
                    icon: Icons.collections_bookmark,
                    label: '收藏集',
                    onTap: () => _addToCollection(context, ref, paths),
                  ),
                  _ActionChip(
                    icon: Icons.playlist_add,
                    label: '播放列表',
                    onTap: () => _addToPlaylist(context, ref, paths),
                  ),
                  _ActionChip(
                    icon: Icons.delete_outline,
                    label: '删除',
                    onTap: () => _confirmDelete(context, ref, paths, count),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mark the given [paths] as favourites, refresh the in-memory media list
  /// (so the heart icon updates immediately), then exit selection mode.
  Future<void> _favorite(
    BuildContext context,
    WidgetRef ref,
    List<String> paths,
  ) async {
    final db = ref.read(appDatabaseProvider);
    for (final path in paths) {
      await db.setFavorite(path, true);
    }
    // Reload from DB so the in-memory state (and heart icons) reflect the
    // change. Without this the toggle in [MediaContextSheet] would show the
    // item as unfavourited even though the database was updated.
    await ref.read(mediaProvider.notifier).reloadFromDatabase();
    ref.read(selectionProvider(selectionId).notifier).endSelection();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    List<String> paths,
    int count,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定删除选中的 $count 项？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(appDatabaseProvider).removeMediaItems(paths);
      // Keep the in-memory list in sync with the database after deletion.
      await ref.read(mediaProvider.notifier).reloadFromDatabase();
      ref.read(selectionProvider(selectionId).notifier).endSelection();
    }
  }

  Future<void> _addToCollection(
      BuildContext context, WidgetRef ref, List<String> paths) async {
    final collections = await ref.read(collectionsProvider.future);
    if (!context.mounted) return;

    final selectedCol = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('添加到收藏集'),
        children: [
          if (collections.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('暂无收藏集，请先创建'),
            )
          else
            ...collections.map((c) => SimpleDialogOption(
                  onPressed: () => Navigator.of(ctx).pop(c.id),
                  child: Text(c.name),
                )),
          SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop(-1),
            child: const Text('新建收藏集...'),
          ),
        ],
      ),
    );

    if (selectedCol == null) return;
    if (selectedCol == -1) {
      // Create new collection then add
      // Simplified: just show create dialog
    } else {
      ref.read(collectionManagerProvider).addItems(selectedCol, paths);
    }
    ref.read(selectionProvider(selectionId).notifier).endSelection();
  }

  Future<void> _addToPlaylist(
      BuildContext context, WidgetRef ref, List<String> paths) async {
    final playlists = await ref.read(playlistsProvider.future);
    if (!context.mounted) return;

    final selectedPl = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('添加到播放列表'),
        children: [
          if (playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('暂无播放列表，请先创建'),
            )
          else
            ...playlists.map((p) => SimpleDialogOption(
                  onPressed: () => Navigator.of(ctx).pop(p.id),
                  child: Text(p.name),
                )),
        ],
      ),
    );

    if (selectedPl != null) {
      ref.read(playlistManagerProvider).addItems(selectedPl, paths);
    }
    ref.read(selectionProvider(selectionId).notifier).endSelection();
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: onTap,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
