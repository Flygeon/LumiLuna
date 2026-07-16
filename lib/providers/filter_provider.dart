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

  return async.whenData((items) {
    Iterable<MediaItem> result = items;
    if (typeFilter != null) {
      result = result.where((i) => i.type == typeFilter);
    }
    if (query.isNotEmpty) {
      result = result.where((i) =>
        i.name.toLowerCase().contains(query) ||
        (i.title?.toLowerCase().contains(query) ?? false) ||
        (i.artist?.toLowerCase().contains(query) ?? false));
    }
    return result.toList();
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
        // Music groups by its album tag when present, everything else by folder.
        key = (item.type == MediaType.audio && item.album != null)
            ? item.album!
            : item.folderName;
        label = key;
        break;
      case GroupMode.folder:
        key = item.folderPath;
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
    folders.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
  }
  return folders;
}
