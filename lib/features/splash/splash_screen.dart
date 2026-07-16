import 'dart:async';

import 'package:flutter/material.dart';

import '../home/home_screen.dart';

/// Animated splash screen displayed while the app initialises.
///
/// Shows the brand name with a subtle glow, a loading indicator, then
/// cross-fades into the main [HomeScreen].
class SplashScreen extends StatefulWidget {
  final String? startupError;

  const SplashScreen({super.key, this.startupError});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Start the entrance animation.
    _controller.forward();

    // Simulate loading progress.
    _animateProgress();
  }

  Future<void> _animateProgress() async {
    // Wait for the entrance animation to finish first.
    await Future.delayed(const Duration(milliseconds: 600));

    // Animate progress from 0 → 0.7 quickly, then 0.7 → 1.0 slowly.
    await _tickProgress(0.7, 800);
    await _tickProgress(0.85, 600);
    await _tickProgress(0.95, 400);
    await _tickProgress(1.0, 300);

    // Brief pause so the user sees the completed bar.
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    // Navigate to home with a fade transition.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _tickProgress(double target, int durationMs) async {
    final step = 0.02;
    final interval = Duration(milliseconds: (durationMs / ((target - _progress) / step)).round());

    while (_progress < target && mounted) {
      await Future.delayed(interval);
      setState(() => _progress = (_progress + step).clamp(0.0, 1.0));
    }
    if (mounted) setState(() => _progress = target);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [scheme.surface, scheme.surfaceContainerHigh]
                : [
                    scheme.primary.withValues(alpha: 0.05),
                    scheme.surface,
                  ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // App icon / logo area
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.3),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_stories,
                    size: 48,
                    color: scheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(height: 32),

                // App name
                Text(
                  'LumiLuna',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: scheme.onSurface,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '光影 · 媒体库',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4,
                    color: scheme.onSurfaceVariant,
                  ),
                ),

                const Spacer(flex: 2),

                // Loading bar
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 4,
                          backgroundColor: scheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(scheme.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Startup error banner (if any)
                if (widget.startupError != null) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      widget.startupError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.error,
                      ),
                    ),
                  ),
                ],

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
