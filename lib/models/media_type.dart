import 'package:flutter/material.dart';

/// The category of a media file.
enum MediaType {
  image,
  video,
  audio;

  /// Human-readable label (Chinese).
  String get label {
    switch (this) {
      case MediaType.image:
        return '图片';
      case MediaType.video:
        return '视频';
      case MediaType.audio:
        return '音乐';
    }
  }

  /// Representative icon for the media type.
  IconData get icon {
    switch (this) {
      case MediaType.image:
        return Icons.image_outlined;
      case MediaType.video:
        return Icons.movie_outlined;
      case MediaType.audio:
        return Icons.music_note_outlined;
    }
  }

  IconData get filledIcon {
    switch (this) {
      case MediaType.image:
        return Icons.image;
      case MediaType.video:
        return Icons.movie;
      case MediaType.audio:
        return Icons.music_note;
    }
  }
}
