import 'package:flutter/material.dart';

import '../core/utils/format_utils.dart';
import '../models/media_item.dart';
import 'media_thumbnail.dart';

/// Compact list of media items with a thumbnail, name and metadata line.
///
/// Each row is wrapped in a [RepaintBoundary] so re-sorting the list never
/// repaints rows whose content hasn't changed — and a paint-phase exception
/// in one row can't cascade into a grey-screen for the whole list.
class MediaListView extends StatelessWidget {
  final List<MediaItem> items;
  final void Function(int index) onTap;
  final void Function(int index)? onSecondaryTap;
  final void Function(int index)? onLongPress;
  final Set<String> selectedPaths;

  const MediaListView({
    super.key,
    required this.items,
    required this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
    this.selectedPaths = const {},
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = selectedPaths.contains(item.path);
        return RepaintBoundary(
          key: ValueKey(item.path),
          child: GestureDetector(
            // Right-click / secondary tap on desktop triggers the context menu.
            onSecondaryTapDown: (_) => onSecondaryTap?.call(index),
            onLongPress: onLongPress != null ? () => onLongPress!(index) : null,
            child: ListTile(
              selected: selected,
              selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.3),
              leading: SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 52,
                        height: 52,
                        child: MediaThumbnail(item: item, iconSize: 24),
                      ),
                    ),
                    if (selected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: scheme.primary, width: 2),
                          ),
                          child: const Icon(Icons.check_circle,
                              color: Colors.white, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
              title: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${FormatUtils.fileSize(item.size)} · ${FormatUtils.date(item.modified)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: selected
                  ? Icon(Icons.check_circle, color: scheme.primary)
                  : Icon(item.type.icon),
              onTap: () => onTap(index),
            ),
          ),
        );
      },
    );
  }
}
