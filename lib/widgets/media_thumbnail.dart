import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import '../providers/tab_provider.dart';

/// Displays a thumbnail for a [MediaItem].
///
/// - Images are decoded at a limited [cacheWidth] to keep memory low.
/// - Videos get a real frame extracted once (and cached to disk) via
///   [FcNativeVideoThumbnail], which supports Windows out of the box.
/// - Audio shows its embedded cover art when available, otherwise a themed
///   icon placeholder.
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
    if (item.type == MediaType.audio && item.artworkPath != null) {
      return Image.file(
        File(item.artworkPath!),
        fit: fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => _placeholder(context, item),
      );
    }
    return _placeholder(context, item);
  }
}

/// Themed icon placeholder used while a video thumbnail is generating, and
/// for audio items (no cover art in v1).
Widget _placeholder(BuildContext context, MediaItem item,
    [double iconSize = 40]) {
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
///
/// The disk-cache check runs immediately in [initState] so that thumbnails
/// that were generated in a previous session show without delay.
/// The (native, CPU-bound) extraction is deferred: it only runs when this
/// video's tab is the active one AND the tab-switch slide has finished. That
/// keeps the frame-extraction burst off the animation frames and stops
/// off-screen tabs from doing work.
class _VideoThumbnail extends ConsumerStatefulWidget {
  final MediaItem item;
  final BoxFit fit;
  final double iconSize;

  const _VideoThumbnail({
    required this.item,
    required this.fit,
    required this.iconSize,
  });

  @override
  ConsumerState<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends ConsumerState<_VideoThumbnail> {
  static final _plugin = FcNativeVideoThumbnail();
  static final Map<String, Future<String?>> _pending = {};
  String? _thumbPath;
  bool _extractionScheduled = false;

  @override
  void initState() {
    super.initState();
    _loadFromDiskCache();
  }

  /// Check the disk cache immediately so already-cached thumbnails show
  /// without waiting for the tab-animation deferral.
  Future<void> _loadFromDiskCache() async {
    try {
      final base = await getTemporaryDirectory();
      final dir = Directory('${base.path}/lumiluna_thumbs');
      if (!await dir.exists()) return;
      final key = _cacheKey(widget.item);
      final dest = '${dir.path}${Platform.pathSeparator}$key.jpg';
      if (await File(dest).exists() && mounted) {
        setState(() => _thumbPath = dest);
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only trigger the native extraction when this tab is active + settled.
    final canExtract = ref.watch(activeTypeProvider) == widget.item.type &&
        !ref.watch(tabAnimatingProvider);
    if (canExtract && _thumbPath == null && !_extractionScheduled) {
      _extractionScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
    }

    if (_thumbPath != null) {
      return Image.file(
        File(_thumbPath!),
        fit: widget.fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) =>
            _placeholder(context, widget.item, widget.iconSize),
      );
    }
    // Loading, deferred or failed: keep the themed icon placeholder.
    return _placeholder(context, widget.item, widget.iconSize);
  }

  Future<void> _generate() async {
    if (!mounted) return;
    try {
      final key = _cacheKey(widget.item);
      final path = await (_pending[key] ??= _generateThumbnail(widget.item)
          .whenComplete(() => _pending.remove(key)));
      if (mounted && path != null) setState(() => _thumbPath = path);
    } catch (_) {}
  }

  static Future<String?> _generateThumbnail(MediaItem item) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final thumbDir = Directory('${cacheDir.path}/lumiluna_thumbs');
      await thumbDir.create(recursive: true);
      final key = _cacheKey(item);
      final dest = '${thumbDir.path}${Platform.pathSeparator}$key.jpg';

      if (await File(dest).exists()) return dest;

      final ok = await _plugin.getVideoThumbnail(
        srcFile: item.path,
        destFile: dest,
        width: AppConstants.thumbnailCacheWidth,
        height: AppConstants.thumbnailCacheWidth,
        format: 'jpeg',
        quality: 80,
      );
      return ok ? dest : null;
    } catch (_) {
      return null;
    }
  }

  static String _cacheKey(MediaItem item) {
    final input = '${item.path.replaceAll('\\', '/').toLowerCase()}|'
        '${item.size}|${item.modified.millisecondsSinceEpoch}';
    var hash = 0xcbf29ce484222325;
    for (final unit in input.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return hash.toRadixString(16);
  }
}
