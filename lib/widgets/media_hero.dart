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
      motion: const MaterialSpringMotion.standardSpatialDefault().copyWith(
        stiffness: 550,
        snapToEnd: true,
      ),
      flightShuttleBuilder: const _MediaHeroShuttleBuilder(),
      child: KeyedSubtree(key: ValueKey(loaded), child: child),
    );
  }
}

class _MediaHeroShuttleBuilder extends SimpleShuttleBuilder {
  const _MediaHeroShuttleBuilder();

  @override
  Widget buildHero({
    required BuildContext flightContext,
    required Widget fromHero,
    required Widget toHero,
    required double valueFromTo,
    required HeroFlightDirection flightDirection,
  }) {
    final hero =
        flightDirection == HeroFlightDirection.push ? fromHero : toHero;
    return RepaintBoundary(child: hero);
  }

  @override
  List<Object?> get props => [];
}
