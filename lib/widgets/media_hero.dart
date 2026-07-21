import 'package:flutter/material.dart';
import 'package:heroine/heroine.dart';

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
    return Heroine(
      tag: tag,
      motion: Motion.bouncySpring(),
      flightShuttleBuilder: const FadeShuttleBuilder(),
      child: KeyedSubtree(key: ValueKey(loaded), child: child),
    );
  }
}
