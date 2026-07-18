import 'package:flutter/material.dart';

/// Defers building [builder] until the widget is near the viewport of its
/// nearest [Scrollable] ancestor.
///
/// [loadAheadViewports] controls how many viewport-heights ahead of the
/// visible area content starts loading (default 1.5 viewports).
///
/// Until visibility is confirmed, [placeholder] is rendered instead — use
/// this to show a skeleton or other lightweight widget so the user sees
/// immediate layout without the actual content cost.
class LazyLoadWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final Widget placeholder;
  final double loadAheadViewports;

  const LazyLoadWidget({
    super.key,
    required this.builder,
    required this.placeholder,
    this.loadAheadViewports = 1.5,
  });

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _loaded = false;
  ScrollPosition? _attachedPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachToScrollable();
    _checkVisibility();
  }

  @override
  void didUpdateWidget(LazyLoadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loadAheadViewports != widget.loadAheadViewports) {
      _checkVisibility();
    }
  }

  @override
  void dispose() {
    _detachFromScrollable();
    super.dispose();
  }

  void _attachToScrollable() {
    final scrollable = Scrollable.maybeOf(context);
    final newPos = scrollable?.position;
    if (newPos != _attachedPosition) {
      _detachFromScrollable();
      _attachedPosition = newPos;
      _attachedPosition?.addListener(_onScroll);
    }
  }

  void _detachFromScrollable() {
    _attachedPosition?.removeListener(_onScroll);
    _attachedPosition = null;
  }

  void _onScroll() => _checkVisibility();

  void _checkVisibility() {
    if (_loaded) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;

    final scrollableBox =
        scrollable.context.findRenderObject() as RenderBox?;
    if (scrollableBox == null || !scrollableBox.attached) return;

    final axis = scrollable.position.axis;

    // Get the item's position relative to the scrollable's paint bounds.
    // localToGlobal with [ancestor] gives the position in the coordinate
    // space of that ancestor.  As the user scrolls, items move within the
    // scrollable's fixed bounds — items above the visible area have
    // negative values along the scroll axis; items below exceed the
    // viewport extent.
    final itemPos = renderBox.localToGlobal(
      Offset.zero,
      ancestor: scrollableBox,
    );
    final itemExtent = axis == Axis.vertical
        ? renderBox.size.height
        : renderBox.size.width;
    if (itemExtent <= 0) return;

    final viewExtent = axis == Axis.vertical
        ? scrollableBox.size.height
        : scrollableBox.size.width;
    final buffer = viewExtent * widget.loadAheadViewports;

    final pos = axis == Axis.vertical ? itemPos.dy : itemPos.dx;
    final itemEnd = pos + itemExtent;
    final visibleStart = -buffer;
    final visibleEnd = viewExtent + buffer;

    if (itemEnd >= visibleStart && pos <= visibleEnd) {
      setState(() => _loaded = true);
      _detachFromScrollable();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loaded) return widget.builder(context);
    return widget.placeholder;
  }
}
