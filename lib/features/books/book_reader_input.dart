import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class BookReaderInput extends StatelessWidget {
  final Widget child;
  final Axis axis;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Future<void> Function(double delta)? onScroll;

  const BookReaderInput({
    super.key,
    required this.child,
    required this.axis,
    required this.onPrevious,
    required this.onNext,
    this.onScroll,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          final delta = event.scrollDelta.dy;
          onScroll?.call(delta);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          final width = MediaQuery.sizeOf(context).width;
          final height = MediaQuery.sizeOf(context).height;
          if (axis == Axis.horizontal) {
            details.localPosition.dx < width / 2 ? onPrevious() : onNext();
          } else {
            details.localPosition.dy < height / 2 ? onPrevious() : onNext();
          }
        },
        child: child,
      ),
    );
  }
}
