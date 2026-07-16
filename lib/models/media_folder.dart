import 'media_item.dart';

/// A group of media items sharing a key (folder path, album name or date).
class MediaFolder {
  final String key;
  final String label;
  final List<MediaItem> items;

  const MediaFolder({
    required this.key,
    required this.label,
    required this.items,
  });

  int get count => items.length;

  /// A representative item used for the cover thumbnail (first image if any).
  MediaItem? get cover {
    for (final item in items) {
      if (item.type.name == 'image') return item;
    }
    return items.isNotEmpty ? items.first : null;
  }
}

/// How media items are grouped in the library view.
enum GroupMode {
  album,
  folder,
  date;
}
