import 'package:flutter_test/flutter_test.dart';
import 'package:lumiluna/models/media_item.dart';
import 'package:lumiluna/models/media_type.dart';

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
}
