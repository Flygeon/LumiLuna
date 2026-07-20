import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../l10n/l10n.dart';
import '../../providers/player_provider.dart';

/// Video playback screen backed by the shared media_kit player.
///
/// The [Video] widget ships Material controls (play/pause, seek, fullscreen).
/// Because the player was opened with the full playlist, videos advance
/// automatically for continuous playback.
class VideoPlayerScreen extends ConsumerWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(playbackControllerProvider.notifier);
    final current = ref.watch(
      playbackControllerProvider.select((s) => s.current),
    );
    final rate = ref.watch(
      playbackControllerProvider.select((s) => s.rate),
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
        body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Video(
                controller: controller.videoController,
                controls: (state) => MaterialVideoControlsTheme(
                  normal: kDefaultMaterialVideoControlsThemeData.copyWith(
                    speedUpOnLongPress: true,
                    speedUpFactor: 2.0,
                    primaryButtonBar: const [],
                    bottomButtonBar: const [
                      MaterialSkipPreviousButton(),
                      SizedBox(width: 12),
                      MaterialPlayOrPauseButton(iconSize: 32),
                      SizedBox(width: 12),
                      MaterialSkipNextButton(),
                      Spacer(),
                      MaterialPositionIndicator(),
                      SizedBox(width: 12),
                      MaterialFullscreenButton(),
                    ],
                    bottomButtonBarMargin:
                        const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  fullscreen:
                      kDefaultMaterialVideoControlsThemeDataFullscreen.copyWith(
                    speedUpOnLongPress: true,
                    speedUpFactor: 2.0,
                    primaryButtonBar: const [],
                    bottomButtonBar: const [
                      MaterialSkipPreviousButton(),
                      SizedBox(width: 12),
                      MaterialPlayOrPauseButton(iconSize: 32),
                      SizedBox(width: 12),
                      MaterialSkipNextButton(),
                      Spacer(),
                      MaterialPositionIndicator(),
                      SizedBox(width: 12),
                      MaterialFullscreenButton(),
                    ],
                    bottomButtonBarMargin:
                        const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: MaterialVideoControls(state),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 16,
              child: SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topRight,
                  child: _VideoSpeedButton(
                    rate: rate,
                    onSelected: controller.setRate,
                  ),
                ),
              ),
            ),
            // Video metadata overlay - bottom left
            Positioned(
              left: 16,
              bottom: 80,
              child: SafeArea(
                top: false,
                child: _VideoInfoBadge(
                  width: current?.videoWidth,
                  height: current?.videoHeight,
                  codec: current?.videoCodec,
                  fps: current?.videoFps,
                  fileSize: current?.size,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoSpeedButton extends StatelessWidget {
  static const _rates = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  final double rate;
  final ValueChanged<double> onSelected;

  const _VideoSpeedButton({required this.rate, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: '播放速度',
      initialValue: rate,
      onSelected: onSelected,
      color: const Color(0xff262626),
      itemBuilder: (context) => _rates
          .map(
            (value) => PopupMenuItem<double>(
              value: value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    value == rate
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: value == rate ? Colors.white : Colors.white54,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${value}x',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          value == rate ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            '${rate}x',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoInfoBadge extends StatelessWidget {
  final int? width;
  final int? height;
  final String? codec;
  final double? fps;
  final int? fileSize;

  const _VideoInfoBadge({
    this.width,
    this.height,
    this.codec,
    this.fps,
    this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (width != null && height != null) {
      parts.add('${width}x$height');
    }
    if (codec != null && codec!.isNotEmpty) {
      parts.add(codec!.toUpperCase());
    }
    if (fps != null && fps! > 0) {
      parts.add('${fps!.toStringAsFixed(1)} FPS');
    }
    if (fileSize != null && fileSize! > 0) {
      parts.add(_formatFileSize(fileSize!));
    }
    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        parts.join(' · '),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
