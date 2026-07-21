import 'package:flutter/material.dart';

String mediaHeroTag(String path) => 'media-hero:${path.replaceAll('\\', '/')}';

class MediaHero extends StatelessWidget {
  final String tag;
  final Widget child;
  final bool loaded;

  const MediaHero({
    super.key,
    required this.tag,
    required this.child,
    this.loaded = true,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        reverseDuration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(loaded),
          child: child,
        ),
      ),
    );
  }
}
