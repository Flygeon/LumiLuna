import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          current?.name ?? '视频',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: Center(
        child: Video(
          controller: controller.videoController,
          controls: AdaptiveVideoControls,
        ),
      ),
    );
  }
}
