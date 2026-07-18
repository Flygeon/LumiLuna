import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import '../providers/settings_provider.dart';
import 'media_thumbnail.dart';

/// Responsive grid of media items. Column count adapts to available width so
/// the layout works from phones to wide desktop windows.
///
/// Each tile is wrapped in a [RepaintBoundary] so that re-sorting the list
/// (which causes every tile's index to change) only repaints the tiles that
/// actually need to repaint — not the entire grid.  This also prevents any
/// paint-phase exception in one tile from cascading into a grey-screen for
/// the whole grid.
class MediaGridView extends StatelessWidget {
  final List<MediaItem> items;
  final void Function(int index) onTap;
  final void Function(int index)? onSecondaryTap;
  final void Function(int index)? onLongPress;
  final Set<String> selectedPaths;
  final MediaLayoutDensity density;

  const MediaGridView({
    super.key,
    required this.items,
    required this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
    this.selectedPaths = const {},
    this.density = MediaLayoutDensity.standard,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = density == MediaLayoutDensity.compact;
        final targetWidth = compact ? 110.0 : AppConstants.gridTargetTileWidth;
        final columns = (constraints.maxWidth / targetWidth)
            .floor()
            .clamp(
              AppConstants.gridMinColumns.toInt(),
              AppConstants.gridMaxColumns.toInt(),
            );
        final spacing = compact ? 3.0 : 10.0;
        return GridView.builder(
          padding: EdgeInsets.all(compact ? 4 : 10),
          physics: const AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          // Each tile gets its own RepaintBoundary so that paint work is
          // isolated per-tile.  Combined with the stable ValueKey, this means
          // re-sorting the list never repaints tiles whose content hasn't
          // changed — eliminating the visual flicker / grey-screen after sort.
          itemBuilder: (context, index) => RepaintBoundary(
            key: ValueKey(items[index].path),
            child: _GridTile(
              item: items[index],
              compact: compact,
              selected: selectedPaths.contains(items[index].path),
              onTap: () => onTap(index),
              onSecondaryTap: onSecondaryTap != null
                  ? () => onSecondaryTap!(index)
                  : null,
              onLongPress: onLongPress != null
                  ? () => onLongPress!(index)
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class _GridTile extends StatelessWidget {
  final MediaItem item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback? onLongPress;
  final bool compact;

  const _GridTile({
    required this.item,
    this.selected = false,
    required this.onTap,
    this.onSecondaryTap,
    this.onLongPress,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.3) : null,
      child: GestureDetector(
        // Right-click / secondary tap on desktop triggers the context menu.
        onSecondaryTapDown: (_) => onSecondaryTap?.call(),
        onLongPress: onLongPress,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              MediaThumbnail(item: item, iconSize: compact ? 24 : 40),
              // Selection overlay
              if (selected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.15),
                      border: Border.all(
                        color: scheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(compact ? 3 : 6),
                        child: Icon(
                          Icons.check_circle,
                          color: scheme.primary,
                          size: compact ? 16 : 22,
                        ),
                      ),
                    ),
                  ),
                ),
              // Play affordance for playable media.
              if (item.type != MediaType.image && !selected)
                Center(
                  child: Container(
                        padding: EdgeInsets.all(compact ? 5 : 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: compact ? 20 : 28,
                    ),
                  ),
                ),
              // Name label with a gradient scrim for readability.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: selected
                    ? const SizedBox.shrink()
                    : Container(
                        padding: EdgeInsets.fromLTRB(
                            compact ? 4 : 8, compact ? 8 : 16, compact ? 4 : 8, compact ? 3 : 6),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 9 : 12,
                          ),
                        ),
                      ),
              ),
              // Small type badge, top-left.
              if (!selected)
                Positioned(
                  top: compact ? 3 : 6,
                  left: compact ? 3 : 6,
                  child: Container(
                    padding: EdgeInsets.all(compact ? 2 : 4),
                    decoration: BoxDecoration(
                      color: scheme.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(item.type.icon,
                        size: compact ? 10 : 14, color: scheme.onSurface),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
