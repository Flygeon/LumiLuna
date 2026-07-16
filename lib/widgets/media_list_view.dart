import 'package:flutter/material.dart';

import '../core/utils/format_utils.dart';
import '../models/media_item.dart';
import 'media_thumbnail.dart';

/// Compact list of media items with a thumbnail, name and metadata line.
class MediaListView extends StatelessWidget {
  final List<MediaItem> items;
  final void Function(int index) onTap;
  final void Function(int index)? onSecondaryTap;

  const MediaListView({
    super.key,
    required this.items,
    required this.onTap,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      cacheExtent: 600,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          key: ValueKey(item.path),
          // Right-click / secondary tap on desktop triggers the context menu.
          onSecondaryTapDown: (_) => onSecondaryTap?.call(index),
          child: ListTile(
            onTap: () => onTap(index),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 52,
                height: 52,
                child: MediaThumbnail(item: item, iconSize: 24),
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
            trailing: Icon(item.type.icon),
          ),
        );
      },
    );
  }
}
