import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';

/// Displays a thumbnail for a [MediaItem].
///
/// - Images are decoded at a limited [cacheWidth] to keep memory low.
/// - Videos get a real frame extracted once (and cached to disk) via
///   [FcNativeVideoThumbnail], which supports Windows out of the box.
/// - Audio falls back to a themed icon placeholder (cover art is out of scope).
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
    if (item.type == MediaType.image) {
      return Image.file(
        item.file,
        fit: fit,
        cacheWidth: AppConstants.thumbnailCacheWidth,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => _placeholder(context, item),
      );
    }
    if (item.type == MediaType.video) {
      return _VideoThumbnail(item: item, fit: fit, iconSize: iconSize);
    }
    return _placeholder(context, item);
  }
}

/// Themed icon placeholder used while a video thumbnail is generating, and
/// for audio items (no cover art in v1).
Widget _placeholder(BuildContext context, MediaItem item, [double iconSize = 40]) {
  final scheme = Theme.of(context).colorScheme;
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

/// Extracts and caches a single video frame on demand.
class _VideoThumbnail extends StatefulWidget {
  final MediaItem item;
  final BoxFit fit;
  final double iconSize;

  const _VideoThumbnail({
    required this.item,
    required this.fit,
    required this.iconSize,
  });

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  static final _plugin = FcNativeVideoThumbnail();
  String? _thumbPath;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final thumbDir = Directory('${cacheDir.path}/lumiluna_thumbs');
      await thumbDir.create(recursive: true);

      // Stable, collision-free cache key derived from the video path.
      final key = widget.item.path.hashCode.abs().toString();
      final dest = '${thumbDir.path}/$key.jpg';

      if (await File(dest).exists()) {
        if (mounted) setState(() => _thumbPath = dest);
        return;
      }

      final ok = await _plugin.getVideoThumbnail(
        srcFile: widget.item.path,
        destFile: dest,
        width: AppConstants.thumbnailCacheWidth,
        height: AppConstants.thumbnailCacheWidth,
        format: 'jpeg',
        quality: 80,
      );
      if (!mounted) return;
      if (ok) {
        setState(() => _thumbPath = dest);
      } else {
        setState(() => _failed = true);
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_thumbPath != null) {
      return Image.file(
        File(_thumbPath!),
        fit: widget.fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => _placeholder(context, widget.item, widget.iconSize),
      );
    }
    // Loading or failed: keep the themed icon placeholder.
    return _placeholder(context, widget.item, widget.iconSize);
  }
}
