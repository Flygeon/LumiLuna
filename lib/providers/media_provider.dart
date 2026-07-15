import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_item.dart';
import '../models/media_type.dart';
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
    return MediaScannerService.scan(target);
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
      return MediaScannerService.scan(target);
    });
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
