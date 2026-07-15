import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';

/// Displays a thumbnail for a [MediaItem].
///
/// Images are decoded at a limited [cacheWidth] to keep memory usage low even
/// with very large source files. Videos and audio fall back to a themed icon
/// placeholder (frame extraction / cover art are out of scope for v1).
class MediaThumbnail extends StatelessWidget {
  final MediaItem item;
  final BoxFit fit;
  final double iconSize;

  const MediaThumbnail({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (item.type == MediaType.image) {
      return Image.file(
        item.file,
        fit: fit,
        cacheWidth: AppConstants.thumbnailCacheWidth,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => _placeholder(scheme),
      );
    }
    return _placeholder(scheme);
  }

  Widget _placeholder(ColorScheme scheme) {
    final (bg, fg) = switch (item.type) {
      MediaType.image => (scheme.primaryContainer, scheme.onPrimaryContainer),
      MediaType.video => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      MediaType.audio => (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Icon(item.type.filledIcon, color: fg, size: iconSize),
    );
  }
}
