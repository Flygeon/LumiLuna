import 'package:flutter/material.dart';

/// A shimmer-animated skeleton placeholder that matches the target [width],
/// [height] and [borderRadius] of the eventual content.
///
/// Uses [AnimationController.repeat] to produce a moving highlight effect.
/// Dispose the controller when the widget is removed from the tree.
class SkeletonPlaceholder extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonPlaceholder> createState() => _SkeletonPlaceholderState();
}

class _SkeletonPlaceholderState extends State<SkeletonPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade800;
    final highlight = theme.brightness == Brightness.light
        ? Colors.grey.shade100
        : Colors.grey.shade700;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(
                -1.0 + _controller.value * 2.0,
                -1.0,
              ),
              end: Alignment(
                1.0 + _controller.value * 2.0,
                1.0,
              ),
              colors: [
                base,
                highlight,
                base,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
