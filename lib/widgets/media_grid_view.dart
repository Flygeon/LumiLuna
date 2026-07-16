import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import 'media_thumbnail.dart';

/// Responsive grid of media items. Column count adapts to available width so
/// the layout works from phones to wide desktop windows.
class MediaGridView extends StatelessWidget {
  final List<MediaItem> items;
  final void Function(int index) onTap;
  final void Function(int index)? onSecondaryTap;

  const MediaGridView({
    super.key,
    required this.items,
    required this.onTap,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / AppConstants.gridTargetTileWidth)
            .floor()
            .clamp(
              AppConstants.gridMinColumns.toInt(),
              AppConstants.gridMaxColumns.toInt(),
            );
        return GridView.builder(
          padding: const EdgeInsets.all(10),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          cacheExtent: 250,
          // Stable key preserves widget state across rebuilds.
          itemBuilder: (context, index) => _GridTile(
            key: ValueKey(items[index].path),
            item: items[index],
            onTap: () => onTap(index),
            onSecondaryTap: onSecondaryTap != null
                ? () => onSecondaryTap!(index)
                : null,
          ),
        );
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;

  const _GridTile({
    super.key,
    required this.item,
    required this.onTap,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: GestureDetector(
        // Right-click / secondary tap on desktop triggers the context menu.
        onSecondaryTapDown: (_) => onSecondaryTap?.call(),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              MediaThumbnail(item: item),
              // Play affordance for playable media.
              if (item.type != MediaType.image)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              // Name label with a gradient scrim for readability.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // Small type badge, top-left.
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child:
                      Icon(item.type.icon, size: 14, color: scheme.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
