import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_item.dart';
import '../models/media_type.dart';
import '../services/cache_manager.dart';
import '../services/media_scanner_service.dart';
import 'settings_provider.dart';

/// Holds all scanned media items. Rescans when the folder list changes.
class MediaNotifier extends AsyncNotifier<List<MediaItem>> {
  @override
  Future<List<MediaItem>> build() async {
    // Rebuild whenever the configured folders change.
    final folders = ref.watch(
      settingsProvider.select((s) => s.scanFolders),
    );

    final target = folders.isNotEmpty
        ? folders
        : await MediaScannerService.defaultFolders();

    if (target.isEmpty) return const [];

    // Try loading from cache first.
    final cached = await ScanCacheManager.load(target);
    if (cached != null) return cached;

    // Cache miss — perform a full scan and persist the result.
    final items = await MediaScannerService.scan(target);
    await ScanCacheManager.save(items, target);
    return items;
  }

  /// Force a rescan of the current folders.
  Future<void> rescan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final folders = ref.read(settingsProvider).scanFolders;
      final target = folders.isNotEmpty
          ? folders
          : await MediaScannerService.defaultFolders();
      if (target.isEmpty) return const <MediaItem>[];
      await ScanCacheManager.clear();
      final items = await MediaScannerService.scan(target);
      await ScanCacheManager.save(items, target);
      return items;
    });
  }

  /// Toggle the [isFavorite] flag for the item at [index].
  Future<void> toggleFavorite(int index) async {
    final items = [...state.value ?? []];
    if (index < 0 || index >= items.length) return;
    items[index] = items[index].copyWith(
      isFavorite: !items[index].isFavorite,
    );
    state = AsyncValue.data(items);
    await _persist(items);
  }

  /// Rename the item at [index] to [newName] (on disk and in the list).
  Future<void> renameItem(int index, String newName) async {
    final items = [...state.value ?? []];
    if (index < 0 || index >= items.length) return;
    final item = items[index];

    // Determine the new full path.
    final dot = item.name.lastIndexOf('.');
    final ext = dot >= 0 ? item.name.substring(dot) : '';
    final finalName = newName.endsWith(ext) ? newName : '$newName$ext';
    final parent = item.path.substring(0, item.path.lastIndexOf(Platform.pathSeparator));
    final newPath = '$parent${Platform.pathSeparator}$finalName';

    // Rename on disk.
    await File(item.path).rename(newPath);

    items[index] = item.copyWith(path: newPath, name: finalName);
    state = AsyncValue.data(items);
    await _persist(items);
  }

  /// Remove the item at [index] from the list (after it has been moved to
  /// trash or permanently deleted).
  Future<void> removeItem(int index) async {
    final items = [...state.value ?? []];
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    state = AsyncValue.data(items);
    await _persist(items);
  }

  /// Persist the current item list to the cache file.
  Future<void> _persist(List<MediaItem> items) async {
    final folders = ref.read(settingsProvider).scanFolders;
    await ScanCacheManager.save(items, folders);
  }
}

final mediaProvider =
    AsyncNotifierProvider<MediaNotifier, List<MediaItem>>(MediaNotifier.new);

/// Items filtered by a specific media type.
final mediaByTypeProvider =
    Provider.family<AsyncValue<List<MediaItem>>, MediaType>((ref, type) {
  final async = ref.watch(mediaProvider);
  return async.whenData(
    (items) => items.where((i) => i.type == type).toList(),
  );
});

/// Count per media type for badges / summaries.
final mediaCountsProvider = Provider<Map<MediaType, int>>((ref) {
  final async = ref.watch(mediaProvider);
  final counts = {for (final t in MediaType.values) t: 0};
  async.whenData((items) {
    for (final item in items) {
      counts[item.type] = (counts[item.type] ?? 0) + 1;
    }
  });
  return counts;
});
