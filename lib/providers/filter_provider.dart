import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/format_utils.dart';
import '../models/media_folder.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import 'media_provider.dart';
import 'settings_provider.dart';

/// Current search query (matched against file names).
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Optional media-type filter for the library view (null = all types).
final libraryTypeFilterProvider = StateProvider<MediaType?>((ref) => null);

/// Media items after applying the search query (across all types).
final searchedMediaProvider = Provider<AsyncValue<List<MediaItem>>>((ref) {
  final async = ref.watch(mediaProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final typeFilter = ref.watch(libraryTypeFilterProvider);
  final settings = ref.watch(settingsProvider);

  return async.whenData((items) {
    Iterable<MediaItem> result = items;
    if (typeFilter != null) {
      result = result.where((i) => i.type == typeFilter);
    }
    if (query.isNotEmpty) {
      result = result.where((i) =>
          i.name.toLowerCase().contains(query) ||
          (i.title?.toLowerCase().contains(query) ?? false) ||
          (i.artist?.toLowerCase().contains(query) ?? false) ||
          (i.album?.toLowerCase().contains(query) ?? false) ||
          i.folderPath.toLowerCase().contains(query));
    }
    final sorted = result.toList();
    sorted.sort((a, b) {
      final comparison = switch (settings.mediaSortMode) {
        MediaSortMode.modified => a.modified.compareTo(b.modified),
        MediaSortMode.name =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        MediaSortMode.size => a.size.compareTo(b.size),
        MediaSortMode.duration =>
          (a.durationMs ?? 0).compareTo(b.durationMs ?? 0),
      };
      final value = comparison == 0 ? a.path.compareTo(b.path) : comparison;
      return settings.mediaSortAscending ? value : -value;
    });
    return sorted;
  });
});

/// Grouped folders for the library view, honouring the current group mode.
final groupedMediaProvider = Provider<AsyncValue<List<MediaFolder>>>((ref) {
  final async = ref.watch(searchedMediaProvider);
  final mode = ref.watch(settingsProvider.select((s) => s.groupMode));

  return async.whenData((items) => _group(items, mode));
});

List<MediaFolder> _group(List<MediaItem> items, GroupMode mode) {
  final map = <String, List<MediaItem>>{};
  final labels = <String, String>{};

  for (final item in items) {
    late String key;
    late String label;
    switch (mode) {
      case GroupMode.album:
        final album = item.album?.trim();
        if (item.type == MediaType.audio && album != null && album.isNotEmpty) {
          final artist = item.artist?.trim();
          key = 'album:${artist?.toLowerCase() ?? ''}:${album.toLowerCase()}';
          label = album;
        } else {
          key = 'folder:${item.folderPath.toLowerCase()}';
          label = item.folderName;
        }
        break;
      case GroupMode.folder:
        key = 'folder:${item.folderPath.toLowerCase()}';
        label = item.folderName;
        break;
      case GroupMode.date:
        key = FormatUtils.monthKey(item.modified);
        label = FormatUtils.monthLabel(item.modified);
        break;
    }
    map.putIfAbsent(key, () => []).add(item);
    labels[key] = label;
  }

  final folders = map.entries
      .map((e) => MediaFolder(
            key: e.key,
            label: labels[e.key] ?? e.key,
            items: e.value,
          ))
      .toList();

  // Sort: date descending, otherwise by label.
  if (mode == GroupMode.date) {
    folders.sort((a, b) => b.key.compareTo(a.key));
  } else {
    folders
        .sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  }
  return folders;
}
