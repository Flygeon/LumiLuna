import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/constants/app_constants.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import '../providers/tab_provider.dart';
import 'lazy_load_widget.dart';
import 'skeleton_placeholder.dart';

/// Displays a thumbnail for a [MediaItem].
///
/// - Images are lazy-loaded (only when near the viewport) with a shimmer
///   skeleton placeholder and a smooth fade-in when ready.
/// - Videos get a real frame extracted once (and cached to disk) via
///   [FcNativeVideoThumbnail], which supports Windows out of the box. A
///   skeleton is shown while the frame is being extracted.
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
      return LazyLoadWidget(
        loadAheadViewports: 1.5,
        placeholder: LayoutBuilder(
          builder: (context, constraints) => SkeletonPlaceholder(
            width: constraints.maxWidth > 0 ? constraints.maxWidth : 180,
            height: constraints.maxHeight > 0 ? constraints.maxHeight : 180,
            borderRadius: 0,
          ),
        ),
        builder: (context) => _FadeInImageWidget(
          child: Image.file(
            item.file,
            fit: fit,
            cacheWidth: AppConstants.thumbnailCacheWidth,
            gaplessPlayback: true,
            filterQuality: FilterQuality.low,
            errorBuilder: (_, __, ___) => _placeholder(context, item),
          ),
        ),
      );
    }
    if (item.type == MediaType.video) {
      return _VideoThumbnail(item: item, fit: fit, iconSize: iconSize);
    }
    if (item.type == MediaType.audio && item.artworkPath != null) {
      return LazyLoadWidget(
        loadAheadViewports: 1.5,
        placeholder: LayoutBuilder(
          builder: (context, constraints) => SkeletonPlaceholder(
            width: constraints.maxWidth > 0 ? constraints.maxWidth : 180,
            height: constraints.maxHeight > 0 ? constraints.maxHeight : 180,
            borderRadius: 8,
          ),
        ),
        builder: (context) => _FadeInImageWidget(
          child: Image.file(
            File(item.artworkPath!),
            fit: fit,
            gaplessPlayback: true,
            filterQuality: FilterQuality.low,
            errorBuilder: (_, __, ___) => _placeholder(context, item),
          ),
        ),
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
      // Use package:path join so the path separator is correct on every
      // platform (Windows uses '\', POSIX uses '/').  Mixing them — as the
      // previous string interpolation did — produced paths that *usually*
      // worked on Windows but could confuse File.exists() in some edge
      // cases, contributing to thumbnail-state flicker on sort.
      final dir = Directory(p.join(base.path, 'lumiluna_thumbs'));
      if (!await dir.exists()) return;
      final key = _cacheKey(widget.item);
      final dest = p.join(dir.path, '$key.jpg');
      if (await File(dest).exists() && mounted) {
        setState(() => _thumbPath = dest);
      }
    } catch (e, st) {
      // Surface cache-load errors instead of swallowing them silently — a
      // silent failure here is exactly what made the grey-screen bug on
      // Windows impossible to diagnose.
      debugPrint('_loadFromDiskCache failed: $e\n$st');
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
      return _FadeInImageWidget(
        child: Image.file(
          File(_thumbPath!),
          fit: widget.fit,
          gaplessPlayback: true,
          filterQuality: FilterQuality.low,
          errorBuilder: (_, __, ___) =>
              _placeholder(context, widget.item, widget.iconSize),
        ),
      );
    }
    // Loading, deferred or failed: show a shimmer skeleton.
    return LayoutBuilder(
      builder: (context, constraints) => SkeletonPlaceholder(
        width: constraints.maxWidth > 0 ? constraints.maxWidth : 180,
        height: constraints.maxHeight > 0 ? constraints.maxHeight : 180,
        borderRadius: 8,
      ),
    );
  }

  Future<void> _generate() async {
    if (!mounted) return;
    try {
      final key = _cacheKey(widget.item);
      final path = await (_pending[key] ??= _generateThumbnail(widget.item)
          .whenComplete(() => _pending.remove(key)));
      if (mounted && path != null) setState(() => _thumbPath = path);
    } catch (e, st) {
      debugPrint('_VideoThumbnail._generate failed for ${widget.item.path}: $e\n$st');
    }
  }

  static Future<String?> _generateThumbnail(MediaItem item) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final thumbDir = Directory(p.join(cacheDir.path, 'lumiluna_thumbs'));
      await thumbDir.create(recursive: true);
      final key = _cacheKey(item);
      final dest = p.join(thumbDir.path, '$key.jpg');

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
    } catch (e, st) {
      debugPrint('_generateThumbnail failed for ${item.path}: $e\n$st');
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

/// Wraps [child] with a fade-in animation triggered on insertion.
///
/// Used when the thumbnail content becomes available (e.g. after lazy-loading
/// or video-frame extraction completes) so the user sees a smooth transition
/// instead of a hard pop-in.
class _FadeInImageWidget extends StatefulWidget {
  final Widget child;

  const _FadeInImageWidget({required this.child});

  @override
  State<_FadeInImageWidget> createState() => _FadeInImageWidgetState();
}

class _FadeInImageWidgetState extends State<_FadeInImageWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    // Start fading in on the next frame so the widget tree is settled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
