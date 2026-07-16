import '../models/media_item.dart';
import '../models/media_type.dart';
import 'database_service.dart';

/// Repository that mediates between the scanner / providers and the database.
///
/// Responsible for batch-inserting scan results, querying with filters,
/// and synchronising the in-memory state with SQLite.
class MediaRepository {
  /// Replace the entire media library with [items] from a full scan.
  static Future<void> replaceAll(List<MediaItem> items) async {
    await DatabaseService.clearMediaItems();
    await DatabaseService.upsertMediaItems(items);
  }

  /// Insert only new/changed items (incremental scan result).
  static Future<void> upsertAll(List<MediaItem> items) async {
    await DatabaseService.upsertMediaItems(items);
  }

  /// Remove items whose files no longer exist.
  static Future<void> removeAbsent(List<String> existingPaths) async {
    final db = await DatabaseService.database;
    final allPaths = await db.rawQuery('SELECT path FROM media_items');
    final stored = allPaths.map((r) => r['path'] as String).toSet();
    final missing = stored.difference(existingPaths.toSet());
    if (missing.isNotEmpty) {
      await DatabaseService.removeMediaItems(missing.toList());
    }
  }

  /// Query media items with various filters.
  static Future<List<MediaItem>> query({
    MediaType? type,
    String? searchQuery,
    bool? favoritesOnly,
    String? folderPath,
    int? limit,
    int? offset,
  }) {
    return DatabaseService.getMediaItems(
      type: type,
      searchQuery: searchQuery,
      favoritesOnly: favoritesOnly,
      folderPath: folderPath,
      limit: limit,
      offset: offset,
    );
  }

  /// Counts per type.
  static Future<Map<MediaType, int>> counts() {
    return DatabaseService.getMediaCounts();
  }

  /// Total item count.
  static Future<int> totalCount() {
    return DatabaseService.getMediaCount();
  }

  /// Toggle favorite.
  static Future<void> toggleFavorite(String path, bool isFavorite) {
    return DatabaseService.setFavorite(path, isFavorite);
  }

  /// Batch toggle favorites.
  static Future<void> batchToggleFavorite(List<String> paths, bool isFavorite) async {
    for (final path in paths) {
      await DatabaseService.setFavorite(path, isFavorite);
    }
  }

  /// Batch delete items.
  static Future<void> batchDelete(List<String> paths) async {
    await DatabaseService.removeMediaItems(paths);
  }
}
