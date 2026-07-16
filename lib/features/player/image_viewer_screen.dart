import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/media_item.dart';

/// Full-screen swipeable image viewer with pinch / double-tap zoom.
class ImageViewerScreen extends StatefulWidget {
  final List<MediaItem> items;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.items.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.items[_index];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          current.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: Image.file(
                item.file,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 80,
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.items.length > 1
          ? Container(
              color: Colors.black.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                context.l10n.imageCounter(
                  _index + 1,
                  widget.items.length,
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            )
          : null,
    );
  }
}
