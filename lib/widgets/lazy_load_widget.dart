import 'package:flutter/material.dart';

/// A widget that only renders its [child] when it is visible within (or within
/// [viewportOffset] of) the viewport of the nearest [Scrollable] ancestor.
///
/// Until then, [placeholder] is displayed instead — typically a static themed
/// placeholder. This avoids decoding / loading heavy widgets (large image
/// files, etc.) for items that are off-screen.
///
/// Visibility is determined by comparing the widget's global position (via
/// [RenderBox.localToGlobal]) against the [Scrollable]'s viewport bounds.
/// A listener on the scroll position re-checks whenever the user scrolls.
///
/// Once the child becomes visible, it stays visible — there is no "unload"
/// when the item scrolls back off-screen.
class LazyLoadWidget extends StatefulWidget {
  final Widget child;
  final Widget placeholder;
  final double viewportOffset;

  const LazyLoadWidget({
    super.key,
    required this.child,
    required this.placeholder,
    this.viewportOffset = 100.0,
  });

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _isVisible = false;
  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startListening();
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  void _startListening() {
    _stopListening();
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) {
      // Not inside a scrollable — always visible.
      setState(() => _isVisible = true);
      return;
    }
    _scrollPosition = scrollable.position;
    _scrollPosition!.addListener(_checkVisibility);
    // Wait for layout, then check initial visibility.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _stopListening() {
    _scrollPosition?.removeListener(_checkVisibility);
    _scrollPosition = null;
  }

  void _checkVisibility() {
    if (_isVisible || !mounted) return;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;

    final renderObject = context.findRenderObject() as RenderBox?;
    final scrollableRenderBox =
        scrollable.context.findRenderObject() as RenderBox?;
    if (renderObject == null ||
        scrollableRenderBox == null ||
        !renderObject.hasSize) {
      return;
    }

    final widgetPos = renderObject.localToGlobal(Offset.zero);
    final scrollablePos = scrollableRenderBox.localToGlobal(Offset.zero);
    final scrollableSize = scrollableRenderBox.size;

    // Widget's position relative to the scrollable viewport.
    final relTop = widgetPos.dy - scrollablePos.dy;
    final relBottom = relTop + renderObject.size.height;

    if (relBottom >= -widget.viewportOffset &&
        relTop <= scrollableSize.height + widget.viewportOffset) {
      setState(() => _isVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isVisible) return widget.child;
    return widget.placeholder;
  }
}
