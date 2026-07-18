import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../l10n/l10n.dart';
import '../../providers/player_provider.dart';

/// Video playback screen backed by the shared media_kit player.
///
/// Supports:
/// - Long-press speed boost (~500ms) with on-screen indicator.
/// - Bottom-bar rate toggle button with a popup panel.
/// - Shared rate state between long-press and button selection.
class VideoPlayerScreen extends ConsumerWidget {
  const VideoPlayerScreen({super.key});

  /// Available playback rates shown in the popup panel.
  static const _rates = [0.5, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playbackControllerProvider.notifier);
    final current = ref.watch(
      playbackControllerProvider.select((s) => s.current),
    );

    return PopScope(
      // Pause playback when the user leaves this screen (e.g. via the back
      // button or gesture) so the video does not keep playing in the
      // background after returning to the home screen.
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          controller.pause();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            current?.name ?? context.l10n.videoTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        body: MaterialVideoControlsTheme(
          normal: _themeData(context),
          fullscreen: _themeDataFullscreen(context),
          child: Video(
            controller: controller.videoController,
            controls: MaterialVideoControls,
          ),
        ),
      ),
    );
  }

  MaterialVideoControlsThemeData _themeData(BuildContext context) {
    return MaterialVideoControlsThemeData(
      speedUpOnLongPress: true,
      speedUpFactor: 2.0,
      speedUpIndicatorBuilder: (_, double factor) => _SpeedIndicator(
        label: '${factor.toStringAsFixed(1)}x',
      ),
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const _RateButton(),
        const Spacer(),
        const MaterialFullscreenButton(),
      ],
    );
  }

  MaterialVideoControlsThemeData _themeDataFullscreen(BuildContext context) {
    return MaterialVideoControlsThemeData(
      speedUpOnLongPress: true,
      speedUpFactor: 2.0,
      speedUpIndicatorBuilder: (_, double factor) => _SpeedIndicator(
        label: '${factor.toStringAsFixed(1)}x',
      ),
      bottomButtonBar: [
        const MaterialPositionIndicator(),
        const _RateButton(),
        const Spacer(),
        const MaterialFullscreenButton(),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Playback rate indicator shown during long-press speed boost.
/// ---------------------------------------------------------------------------
class _SpeedIndicator extends StatelessWidget {
  final String label;
  const _SpeedIndicator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0x88000000),
          borderRadius: BorderRadius.circular(64.0),
        ),
        height: 48.0,
        width: 120.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.fast_forward, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Playback rate button shown in the bottom control bar.
/// Tapping opens a popup panel to pick a preset rate.
/// ---------------------------------------------------------------------------
class _RateButton extends ConsumerWidget {
  const _RateButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rate = ref.watch(
      playbackControllerProvider.select((s) => s.rate),
    );
    return GestureDetector(
      onTap: () => _showRateSheet(context, ref, rate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${rate.toStringAsFixed(2)}x',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showRateSheet(BuildContext context, WidgetRef ref, double currentRate) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        // Wrap the sheet content so that tapping outside (e.g. on the
        // scrim / barrier) dismisses it — that's the default behaviour of
        // [showModalBottomSheet] already.
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    '播放速度',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...VideoPlayerScreen._rates.map(
                  (r) => _RateOption(
                    rate: r,
                    selected: (r - currentRate).abs() < 0.01,
                    onTap: () {
                      ref
                          .read(playbackControllerProvider.notifier)
                          .setRate(r);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A single rate option row inside the modal bottom sheet.
class _RateOption extends StatelessWidget {
  final double rate;
  final bool selected;
  final VoidCallback onTap;

  const _RateOption({
    required this.rate,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '${rate.toStringAsFixed(2)}x',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: selected ? Colors.orangeAccent : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      dense: true,
      trailing: selected
          ? const Icon(Icons.check, color: Colors.orangeAccent, size: 20)
          : null,
    );
  }
}
