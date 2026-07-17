import 'package:flutter_test/flutter_test.dart';
import 'package:lumiluna/models/media_item.dart';
import 'package:lumiluna/models/media_type.dart';
import 'package:lumiluna/providers/player_provider.dart';

void main() {
  test('recognizes supported media extensions case-insensitively', () {
    final image = MediaItem.fromPath('C:/Media/photo.JPG');
    final video = MediaItem.fromPath('C:/Media/movie.Mp4');
    final audio = MediaItem.fromPath('C:/Media/song.FLAC');
    final text = MediaItem.fromPath('C:/Media/readme.txt');

    expect(image?.type, MediaType.image);
    expect(video?.type, MediaType.video);
    expect(audio?.type, MediaType.audio);
    expect(text, isNull);
  });

  group('audio playback identity', () {
    final first = MediaItem(
      path: 'C:/Media/first.mp3',
      name: 'first.mp3',
      type: MediaType.audio,
      size: 1,
      modified: DateTime(2026),
    );
    final second = MediaItem(
      path: 'C:/Media/second.mp3',
      name: 'second.mp3',
      type: MediaType.audio,
      size: 1,
      modified: DateTime(2026),
    );

    test('recognizes the selected current audio by its unique path', () {
      final state = PlaybackState(
        playlist: [first, second],
        index: 0,
        playing: true,
        position: const Duration(seconds: 42),
      );

      expect(state.isPlayingAudio(first.path), isTrue);
      expect(state.position, const Duration(seconds: 42));
    });

    test('does not treat a different audio as the current one', () {
      final state = PlaybackState(
        playlist: [first, second],
        index: 0,
        playing: true,
      );

      expect(state.isPlayingAudio(second.path), isFalse);
    });

    test('does not preserve a paused audio selection', () {
      final state = PlaybackState(
        playlist: [first, second],
        index: 0,
        playing: false,
        position: const Duration(seconds: 42),
      );

      expect(state.isPlayingAudio(first.path), isFalse);
    });
  });
}
