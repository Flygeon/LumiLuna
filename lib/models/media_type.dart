import 'package:flutter/material.dart';

/// The category of a media file.
enum MediaType {
  image,
  video,
  audio;

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
