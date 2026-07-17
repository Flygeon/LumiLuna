import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/collection.dart';
import '../../models/media_item.dart';
import '../../models/media_type.dart';
import '../../models/playlist.dart';
import '../../models/tag.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

@DataClassName('MediaItemRow')
class MediaItems extends Table {
  TextColumn get path => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get size => integer().withDefault(const Constant(0))();
  TextColumn get modified => text()();
  TextColumn? get title => text().nullable()();
  TextColumn? get artist => text().nullable()();
  TextColumn? get album => text().nullable()();
  IntColumn? get durationMs => integer().nullable()();
  TextColumn? get artworkPath => text().nullable()();
  IntColumn get isFavorite => integer().withDefault(const Constant(0))();
  TextColumn get folderPath => text()();
  TextColumn get scannedAt => text().withDefault(Constant(''))();

  @override
  Set<Column> get primaryKey => {path};
}

@DataClassName('TagRow')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get color => integer().withDefault(const Constant(0xFF5C5C5C))();

  @override
  Set<Column> get primaryKey => {id};
}

class MediaTags extends Table {
  TextColumn get mediaPath => text().references(MediaItems, #path)();
  IntColumn get tagId => integer().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {mediaPath, tagId};
}

@DataClassName('CollectionRow')
class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn? get description => text().nullable()();
  TextColumn? get coverPath => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class CollectionItems extends Table {
  IntColumn get collectionId => integer().references(Collections, #id)();
  TextColumn get mediaPath => text().references(MediaItems, #path)();
  TextColumn get addedAt => text().withDefault(Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {collectionId, mediaPath};
}

@DataClassName('PlaylistRow')
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn? get description => text().nullable()();
  TextColumn? get coverPath => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaylistItems extends Table {
  IntColumn get playlistId => integer().references(Playlists, #id)();
  TextColumn get mediaPath => text().references(MediaItems, #path)();
  TextColumn get addedAt => text().withDefault(Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {playlistId, mediaPath};
}

class ScanFolders extends Table {
  TextColumn get path => text()();
  IntColumn get recursive => integer().withDefault(const Constant(1))();
  TextColumn? get lastScanned => text().nullable()();

  @override
  Set<Column> get primaryKey => {path};
}

@DataClassName('PlayHistoryRow')
class PlayHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mediaPath => text().references(MediaItems, #path)();
  TextColumn get playedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database class
// ---------------------------------------------------------------------------

/// Drift-powered database with type-safe DAO methods.
///
/// Replaces the hand-written [DatabaseService] with generated, type-safe code.
/// All public methods accept/return the existing model classes
/// ([MediaItem], [Tag], [MediaCollection], [Playlist]).
@DriftDatabase(
  tables: [
    MediaItems,
    Tags,
    MediaTags,
    Collections,
    CollectionItems,
    Playlists,
    PlaylistItems,
    ScanFolders,
    PlayHistory,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(playHistory);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'lumiluna.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // ---------------------------------------------------------------------------
  // Media Items DAO
  // ---------------------------------------------------------------------------

  Future<List<MediaItem>> getAllMediaItems({
    MediaType? type,
    String? searchQuery,
    bool? favoritesOnly,
    String? folderPath,
    int? limit,
    int? offset,
  }) async {
    var query = select(mediaItems)
      ..orderBy([
        (t) => OrderingTerm(expression: t.modified, mode: OrderingMode.desc)
      ]);

    if (type != null) {
      query = query..where((t) => t.type.equals(type.name));
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = '%$searchQuery%';
      query = query
        ..where((t) =>
            t.name.like(q) |
            t.title.like(q) |
            t.artist.like(q) |
            t.album.like(q));
    }
    if (favoritesOnly == true) {
      query = query..where((t) => t.isFavorite.equals(1));
    }
    if (folderPath != null) {
      query = query..where((t) => t.folderPath.equals(folderPath));
    }
    if (limit != null) {
      query = query..limit(limit, offset: offset ?? 0);
    }

    final rows = await query.get();
    return rows.map(_mediaItemFromRow).toList();
  }

  Future<MediaItem?> getMediaItemByPath(String path) async {
    final row = await (select(mediaItems)..where((t) => t.path.equals(path)))
        .getSingleOrNull();
    return row != null ? _mediaItemFromRow(row) : null;
  }

  Future<int> getMediaCount({MediaType? type}) async {
    final count = mediaItems.path.count();
    final query = selectOnly(mediaItems)..addColumns([count]);
    if (type != null) query.where(mediaItems.type.equals(type.name));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<Map<MediaType, int>> getMediaCounts() async {
    final counts = {for (final t in MediaType.values) t: 0};
    final query = selectOnly(mediaItems)
      ..addColumns([mediaItems.type, mediaItems.path.count()])
      ..groupBy([mediaItems.type]);
    for (final row in await query.get()) {
      final typeName = row.read(mediaItems.type);
      final type = MediaType.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => MediaType.image,
      );
      counts[type] = row.read(mediaItems.path.count()) ?? 0;
    }
    return counts;
  }

  Future<List<String>> getFolderPaths() async {
    final query = selectOnly(mediaItems)
      ..addColumns([mediaItems.folderPath])
      ..groupBy([mediaItems.folderPath])
      ..orderBy([OrderingTerm(expression: mediaItems.folderPath)]);
    return (await query.get())
        .map((row) => row.read(mediaItems.folderPath)!)
        .toList();
  }

  Future<void> upsertMediaItems(List<MediaItem> items) async {
    for (final item in items) {
      final existing = await (select(mediaItems)
            ..where((table) => table.path.equals(item.path)))
          .getSingleOrNull();
      await into(mediaItems).insertOnConflictUpdate(
        MediaItemsCompanion(
          path: Value(item.path),
          name: Value(item.name),
          type: Value(item.type.name),
          size: Value(item.size),
          modified: Value(item.modified.toIso8601String()),
          title: Value(item.title),
          artist: Value(item.artist),
          album: Value(item.album),
          durationMs: Value(item.durationMs),
          artworkPath: Value(item.artworkPath),
          isFavorite: Value(existing?.isFavorite ?? (item.isFavorite ? 1 : 0)),
          folderPath: Value(item.folderPath),
          scannedAt: Value(DateTime.now().toIso8601String()),
        ),
      );
    }
  }

  Future<void> syncMediaItems(
    List<MediaItem> items,
    List<String> folders,
  ) async {
    final normalizedFolders = folders
        .map((folder) => _normalizePath(folder))
        .where((folder) => folder.isNotEmpty)
        .toList();
    final currentPaths = items.map((item) => _normalizePath(item.path)).toSet();
    final existing = await select(mediaItems).get();
    final stale = existing
        .where((row) => normalizedFolders.any((folder) {
              final path = _normalizePath(row.path);
              return path == folder || path.startsWith('$folder/');
            }))
        .where((row) => !currentPaths.contains(_normalizePath(row.path)))
        .map((row) => row.path)
        .toList();
    await transaction(() async {
      await upsertMediaItems(items);
      if (stale.isNotEmpty) await removeMediaItems(stale);
    });
  }

  Future<Set<String>> findDuplicateMediaPaths(List<MediaItem> items) async {
    if (items.isEmpty) return {};
    final rows = await select(mediaItems).get();
    final keys =
        rows.map((row) => '${row.path}|${row.name}|${row.size}').toSet();
    return items
        .where(
            (item) => keys.contains('${item.path}|${item.name}|${item.size}'))
        .map((item) => item.path)
        .toSet();
  }

  static String _normalizePath(String value) =>
      value.replaceAll('\\', '/').replaceAll(RegExp(r'/+'), '/').toLowerCase();

  Future<void> clearMediaItems() async {
    await delete(mediaItems).go();
  }

  Future<void> removeMediaItems(List<String> paths) async {
    for (final path in paths) {
      await (delete(mediaItems)..where((t) => t.path.equals(path))).go();
    }
  }

  Future<void> setFavorite(String path, bool isFavorite) async {
    await (update(mediaItems)..where((t) => t.path.equals(path))).write(
      MediaItemsCompanion(isFavorite: Value(isFavorite ? 1 : 0)),
    );
  }

  Future<void> updateMediaItemPath(
      String oldPath, String newPath, String newName) async {
    final folderPath = () {
      final normalized = newPath.replaceAll('\\', '/');
      final idx = normalized.lastIndexOf('/');
      return idx >= 0 ? normalized.substring(0, idx) : normalized;
    }();
    await (update(mediaItems)..where((t) => t.path.equals(oldPath))).write(
      MediaItemsCompanion(
        path: Value(newPath),
        name: Value(newName),
        folderPath: Value(folderPath),
      ),
    );
    // Update references in other tables.
    await (update(mediaTags)..where((t) => t.mediaPath.equals(oldPath))).write(
      MediaTagsCompanion(mediaPath: Value(newPath)),
    );
    await (update(collectionItems)..where((t) => t.mediaPath.equals(oldPath)))
        .write(
      CollectionItemsCompanion(mediaPath: Value(newPath)),
    );
    await (update(playlistItems)..where((t) => t.mediaPath.equals(oldPath)))
        .write(
      PlaylistItemsCompanion(mediaPath: Value(newPath)),
    );
  }

  // ---------------------------------------------------------------------------
  // Tags DAO
  // ---------------------------------------------------------------------------

  Future<List<Tag>> getAllTags() async {
    final rows = await (select(tags)
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
    return rows
        .map((r) => Tag(id: r.id, name: r.name, color: r.color))
        .toList();
  }

  Future<Tag> createTag(String name, {int color = 0xFF5C5C5C}) async {
    final id = await into(tags)
        .insert(TagsCompanion(name: Value(name), color: Value(color)));
    return Tag(id: id, name: name, color: color);
  }

  Future<void> deleteTag(int id) async {
    await (delete(tags)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addTagToMedia(String mediaPath, int tagId) async {
    await into(mediaTags).insert(
      MediaTagsCompanion(mediaPath: Value(mediaPath), tagId: Value(tagId)),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> removeTagFromMedia(String mediaPath, int tagId) async {
    await (delete(mediaTags)
          ..where((t) => t.mediaPath.equals(mediaPath))
          ..where((t) => t.tagId.equals(tagId)))
        .go();
  }

  Future<Map<String, List<Tag>>> getTagsForMediaPaths(
      List<String> paths) async {
    if (paths.isEmpty) return {};
    final result = <String, List<Tag>>{};
    // Query media_tags for matching paths, then fetch tag details.
    final relations =
        await (select(mediaTags)..where((t) => t.mediaPath.isIn(paths))).get();
    if (relations.isEmpty) return result;

    final tagIds = relations.map((r) => r.tagId).toSet().toList();
    final tagsList =
        await (select(tags)..where((t) => t.id.isIn(tagIds))).get();
    final tagMap = {
      for (final t in tagsList)
        t.id: Tag(id: t.id, name: t.name, color: t.color)
    };

    for (final rel in relations) {
      final tag = tagMap[rel.tagId];
      if (tag != null) {
        result.putIfAbsent(rel.mediaPath, () => []).add(tag);
      }
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Collections DAO
  // ---------------------------------------------------------------------------

  Future<List<MediaCollection>> getAllCollections() async {
    final rows = await (select(collections)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ]))
        .get();
    final result = <MediaCollection>[];
    for (final row in rows) {
      final items = await _getCollectionItems(row.id);
      result.add(MediaCollection(
        id: row.id,
        name: row.name,
        description: row.description,
        coverPath: row.coverPath,
        createdAt: DateTime.parse(row.createdAt),
        updatedAt: DateTime.parse(row.updatedAt),
        items: items,
      ));
    }
    return result;
  }

  Future<List<MediaItem>> _getCollectionItems(int collectionId) async {
    final query = select(collectionItems).join([
      innerJoin(
          mediaItems, mediaItems.path.equalsExp(collectionItems.mediaPath)),
    ])
      ..where(collectionItems.collectionId.equals(collectionId))
      ..orderBy([OrderingTerm(expression: collectionItems.sortOrder)]);
    final rows = await query.get();
    return rows.map((r) => _mediaItemFromRow(r.readTable(mediaItems))).toList();
  }

  Future<MediaCollection> createCollection(String name,
      {String? description}) async {
    final now = DateTime.now().toIso8601String();
    final id = await into(collections).insert(CollectionsCompanion(
      name: Value(name),
      description: Value(description),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    return MediaCollection(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  Future<void> deleteCollection(int id) async {
    await (delete(collections)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addToCollection(
      int collectionId, List<String> mediaPaths) async {
    final now = DateTime.now().toIso8601String();
    await batch((b) {
      for (var i = 0; i < mediaPaths.length; i++) {
        b.insert(
            collectionItems,
            CollectionItemsCompanion(
              collectionId: Value(collectionId),
              mediaPath: Value(mediaPaths[i]),
              addedAt: Value(now),
              sortOrder: Value(i),
            ),
            mode: InsertMode.insertOrIgnore);
      }
    });
    await (update(collections)..where((t) => t.id.equals(collectionId))).write(
      CollectionsCompanion(updatedAt: Value(now)),
    );
  }

  Future<void> removeFromCollection(int collectionId, String mediaPath) async {
    await (delete(collectionItems)
          ..where((t) => t.collectionId.equals(collectionId))
          ..where((t) => t.mediaPath.equals(mediaPath)))
        .go();
  }

  // ---------------------------------------------------------------------------
  // Playlists DAO
  // ---------------------------------------------------------------------------

  Future<List<Playlist>> getAllPlaylists() async {
    final rows = await (select(playlists)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ]))
        .get();
    final result = <Playlist>[];
    for (final row in rows) {
      final items = await _getPlaylistItems(row.id);
      result.add(Playlist(
        id: row.id,
        name: row.name,
        description: row.description,
        coverPath: row.coverPath,
        createdAt: DateTime.parse(row.createdAt),
        updatedAt: DateTime.parse(row.updatedAt),
        items: items,
      ));
    }
    return result;
  }

  Future<List<MediaItem>> _getPlaylistItems(int playlistId) async {
    final query = select(playlistItems).join([
      innerJoin(mediaItems, mediaItems.path.equalsExp(playlistItems.mediaPath)),
    ])
      ..where(playlistItems.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm(expression: playlistItems.sortOrder)]);
    final rows = await query.get();
    return rows.map((r) => _mediaItemFromRow(r.readTable(mediaItems))).toList();
  }

  Future<Playlist> createPlaylist(String name, {String? description}) async {
    final now = DateTime.now().toIso8601String();
    final id = await into(playlists).insert(PlaylistsCompanion(
      name: Value(name),
      description: Value(description),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    return Playlist(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  Future<void> deletePlaylist(int id) async {
    await (delete(playlists)..where((t) => t.id.equals(id))).go();
  }

  Future<void> addToPlaylist(int playlistId, List<String> mediaPaths) async {
    final now = DateTime.now().toIso8601String();
    final maxOrder = await (select(playlistItems)
          ..where((t) => t.playlistId.equals(playlistId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.sortOrder, mode: OrderingMode.desc)
          ])
          ..limit(1))
        .get();
    final startOder = (maxOrder.isNotEmpty ? maxOrder.first.sortOrder : -1) + 1;
    await batch((b) {
      for (var i = 0; i < mediaPaths.length; i++) {
        b.insert(
            playlistItems,
            PlaylistItemsCompanion(
              playlistId: Value(playlistId),
              mediaPath: Value(mediaPaths[i]),
              addedAt: Value(now),
              sortOrder: Value(startOder + i),
            ),
            mode: InsertMode.insertOrIgnore);
      }
    });
    await (update(playlists)..where((t) => t.id.equals(playlistId))).write(
      PlaylistsCompanion(updatedAt: Value(now)),
    );
  }

  Future<void> removeFromPlaylist(int playlistId, String mediaPath) async {
    await (delete(playlistItems)
          ..where((t) => t.playlistId.equals(playlistId))
          ..where((t) => t.mediaPath.equals(mediaPath)))
        .go();
  }

  Future<void> reorderPlaylist(
      int playlistId, List<String> orderedPaths) async {
    await batch((b) {
      for (var i = 0; i < orderedPaths.length; i++) {
        b.update(
          playlistItems,
          PlaylistItemsCompanion(sortOrder: Value(i)),
          where: (t) =>
              t.playlistId.equals(playlistId) &
              t.mediaPath.equals(orderedPaths[i]),
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Scan folders DAO
  // ---------------------------------------------------------------------------

  Future<List<String>> getScanFolders() async {
    final rows = await select(scanFolders).get();
    return rows.map((r) => r.path).toList();
  }

  Future<void> setScanFolders(List<String> folders) async {
    await delete(scanFolders).go();
    await batch((b) {
      for (final folder in folders) {
        b.insert(scanFolders, ScanFoldersCompanion(path: Value(folder)));
      }
    });
  }

  Future<void> updateLastScanned(String folderPath) async {
    await (update(scanFolders)..where((t) => t.path.equals(folderPath))).write(
      ScanFoldersCompanion(
          lastScanned: Value(DateTime.now().toIso8601String())),
    );
  }

  // ---------------------------------------------------------------------------
  // Play history DAO
  // ---------------------------------------------------------------------------

  Future<void> recordPlay(String mediaPath) async {
    await into(playHistory).insert(PlayHistoryRow(
      id: 0,
      mediaPath: mediaPath,
      playedAt: DateTime.now().toIso8601String(),
    ));
  }

  Future<List<MediaItem>> getPlayHistory({int limit = 100, int offset = 0}) async {
    final query = select(playHistory).join([
      innerJoin(mediaItems, mediaItems.path.equalsExp(playHistory.mediaPath)),
    ])
      ..orderBy([OrderingTerm(expression: playHistory.playedAt, mode: OrderingMode.desc)])
      ..limit(limit, offset: offset);
    final rows = await query.get();
    return rows.map((r) => _mediaItemFromRow(r.readTable(mediaItems))).toList();
  }

  Future<void> clearPlayHistory() async {
    await delete(playHistory).go();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  MediaItem _mediaItemFromRow(MediaItemRow row) => MediaItem(
        path: row.path,
        name: row.name,
        type: MediaType.values.firstWhere((t) => t.name == row.type),
        size: row.size,
        modified: DateTime.parse(row.modified),
        title: row.title,
        artist: row.artist,
        album: row.album,
        durationMs: row.durationMs,
        artworkPath: row.artworkPath,
        isFavorite: row.isFavorite == 1,
      );
}
