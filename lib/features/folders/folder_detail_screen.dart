import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/media_folder.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/media_grid_view.dart';
import '../../widgets/media_list_view.dart';
import '../media/media_type_screen.dart';

/// Shows the media items contained in a single [MediaFolder] group.
class FolderDetailScreen extends ConsumerWidget {
  final MediaFolder folder;

  const FolderDetailScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGrid = ref.watch(settingsProvider.select((s) => s.isGridView));
    final items = folder.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(folder.label, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: isGrid ? context.l10n.listView : context.l10n.gridView,
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => ref.read(settingsProvider.notifier).toggleView(),
          ),
        ],
      ),
      body: isGrid
          ? MediaGridView(
              items: items,
              onTap: (i) => openMedia(context, ref, items, i),
            )
          : MediaListView(
              items: items,
              onTap: (i) => openMedia(context, ref, items, i),
            ),
    );
  }
}
