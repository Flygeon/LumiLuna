import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/media_folder.dart';
import '../../providers/filter_provider.dart';
import '../../providers/media_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/async_view.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_thumbnail.dart';
import 'folder_detail_screen.dart';
import '../books/book_shelf_view.dart';

enum _BrowseType { media, books }

/// Library grouping view: shows folders / albums / date buckets as cards.
class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final grouped = ref.watch(groupedMediaProvider);
    final mode = ref.watch(settingsProvider.select((s) => s.groupMode));

    final browseType = ref.watch(_browseTypeProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: SegmentedButton<_BrowseType>(
            segments: const [
              ButtonSegment(value: _BrowseType.media, label: Text('媒体')),
              ButtonSegment(value: _BrowseType.books, label: Text('图书')),
            ],
            selected: {browseType},
            onSelectionChanged: (value) =>
                ref.read(_browseTypeProvider.notifier).state = value.first,
          ),
        ),
        if (browseType == _BrowseType.books)
          const Expanded(child: BookShelfView())
        else ...[
          _GroupModeSelector(mode: mode),
          Expanded(
            child: AsyncView<List<MediaFolder>>(
              value: grouped,
              onRetry: () => ref.read(mediaProvider.notifier).retry(),
              builder: (folders) {
                if (folders.isEmpty) {
                  return EmptyState(
                    icon: Icons.folder_outlined,
                    title: l10n.noGroups,
                    message: l10n.addFolderHint,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(mediaProvider.notifier).rescan(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          (constraints.maxWidth / 200).floor().clamp(2, 6);
                      return GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: folders.length,
                        itemBuilder: (context, index) => _FolderCard(
                          folder: folders[index],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

final _browseTypeProvider =
    StateProvider<_BrowseType>((ref) => _BrowseType.media);

class _GroupModeSelector extends ConsumerWidget {
  final GroupMode mode;

  const _GroupModeSelector({required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: SegmentedButton<GroupMode>(
        segments: GroupMode.values
            .map((m) => ButtonSegment(
                  value: m,
                  label: Text(groupModeName(context, m)),
                ))
            .toList(),
        selected: {mode},
        onSelectionChanged: (set) =>
            ref.read(settingsProvider.notifier).setGroupMode(set.first),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final MediaFolder folder;

  const _FolderCard({required this.folder});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cover = folder.cover;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FolderDetailScreen(folder: folder),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: cover != null
                  ? MediaThumbnail(item: cover)
                  : Container(
                      color: scheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.folder,
                        size: 48,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.itemsCount(folder.count),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
