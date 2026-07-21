import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/collection.dart';
import '../../models/media_item.dart';
import '../../models/media_metadata.dart';
import '../../models/media_type.dart';
import '../../models/book_reading_state.dart';
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
  IntColumn get fileHash => integer().nullable()();
  TextColumn? get title => text().nullable()();
  TextColumn? get artist => text().nullable()();
  TextColumn? get album => text().nullable()();
  IntColumn? get durationMs => integer().nullable()();
  TextColumn? get artworkPath => text().nullable()();
  IntColumn get isFavorite => integer().withDefault(const Constant(0))();
  TextColumn get folderPath => text()();
  TextColumn get scannedAt => text().withDefault(Constant(''))();
  TextColumn? get thumbnailPath => text().nullable()();
  IntColumn? get imageWidth => integer().nullable()();
  IntColumn? get imageHeight => integer().nullable()();
  TextColumn? get imageDateTaken => text().nullable()();
  TextColumn? get imageCameraMake => text().nullable()();
  TextColumn? get imageCameraModel => text().nullable()();
  RealColumn? get imageGpsLat => real().nullable()();
  RealColumn? get imageGpsLng => real().nullable()();
  IntColumn? get imageIso => integer().nullable()();
  RealColumn? get imageFocalLength => real().nullable()();
  RealColumn? get imageFNumber => real().nullable()();
  IntColumn? get videoWidth => integer().nullable()();
  IntColumn? get videoHeight => integer().nullable()();
  TextColumn? get videoCodec => text().nullable()();
  RealColumn? get videoFps => real().nullable()();

  @override
  Set<Column> get primaryKey => {path};
}

@DataClassName('TagRow')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get color => integer().withDefault(const Constant(0xFF5C5C5C))();
  IntColumn? get parentId => integer().nullable().references(Tags, #id)();
  BoolColumn get isGroup => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class MediaTags extends Table {
  TextColumn get mediaPath => text().references(
        MediaItems,
        #path,
        onUpdate: KeyAction.cascade,
        onDelete: KeyAction.cascade,
      )();
  IntColumn get tagId => integer().references(
        Tags,
        #id,
        onDelete: KeyAction.cascade,
      )();

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

@DataClassName('BookReadingStateRow')
class BookReadingStates extends Table {
  TextColumn get mediaPath => text().references(MediaItems, #path)();
  TextColumn? get coverPath => text().nullable()();
  RealColumn get progress => real().withDefault(const Constant(0))();
  TextColumn? get epubCfi => text().nullable()();
  IntColumn? get pdfPage => integer().nullable()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {mediaPath};
}

@DataClassName('BookBookmarkRow')
class BookBookmarks extends Table {
  TextColumn get mediaPath => text().references(MediaItems, #path)();
  TextColumn get locator => text()();
  TextColumn? get title => text().nullable()();
  TextColumn? get excerpt => text().nullable()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {mediaPath, locator};
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
    BookReadingStates,
    BookBookmarks,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

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
        if (from < 3) {
          await m.addColumn(tags, tags.parentId);
          await m.addColumn(tags, tags.isGroup);
        }
        if (from < 4) {
          await m.addColumn(mediaItems, mediaItems.fileHash);
        }
        if (from < 5) {
          await m.addColumn(mediaItems, mediaItems.thumbnailPath);
          await m.addColumn(mediaItems, mediaItems.imageWidth);
          await m.addColumn(mediaItems, mediaItems.imageHeight);
          await m.addColumn(mediaItems, mediaItems.imageDateTaken);
          await m.addColumn(mediaItems, mediaItems.imageCameraMake);
          await m.addColumn(mediaItems, mediaItems.imageCameraModel);
          await m.addColumn(mediaItems, mediaItems.imageGpsLat);
          await m.addColumn(mediaItems, mediaItems.imageGpsLng);
          await m.addColumn(mediaItems, mediaItems.imageIso);
          await m.addColumn(mediaItems, mediaItems.imageFocalLength);
          await m.addColumn(mediaItems, mediaItems.imageFNumber);
          await m.addColumn(mediaItems, mediaItems.videoWidth);
          await m.addColumn(mediaItems, mediaItems.videoHeight);
          await m.addColumn(mediaItems, mediaItems.videoCodec);
          await m.addColumn(mediaItems, mediaItems.videoFps);
        }
        if (from < 6) {
          await m.createTable(bookReadingStates);
          await m.createTable(bookBookmarks);
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

  /// Return a map of normalized path → fileHash for all media items.
  /// Used by the incremental scanner to skip unchanged files.
  Future<Map<String, int>> getAllFileHashes() async {
    final rows = await select(mediaItems).get();
    final result = <String, int>{};
    for (final row in rows) {
      if (row.fileHash != null) {
        result[row.path.replaceAll('\\', '/').toLowerCase()] = row.fileHash!;
      }
    }
    return result;
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
    if (items.isEmpty) return;
    final existingMap = <String, MediaItemRow>{};
    final paths = items.map((i) => i.path).toList();
    final existingRows =
        await (select(mediaItems)..where((t) => t.path.isIn(paths))).get();
    for (final row in existingRows) {
      existingMap[row.path] = row;
    }
    final now = DateTime.now().toIso8601String();
    await batch((b) {
      for (final item in items) {
        final existing = existingMap[item.path];
        final unchanged = existing?.fileHash != null &&
            item.fileHash != null &&
            existing!.fileHash == item.fileHash;
        b.insert(
          mediaItems,
          MediaItemsCompanion(
            path: Value(item.path),
            name: Value(item.name),
            type: Value(item.type.name),
            size: Value(item.size),
            modified: Value(item.modified.toIso8601String()),
            fileHash: Value(item.fileHash),
            title: Value(item.title ?? existing?.title),
            artist: Value(item.artist ?? existing?.artist),
            album: Value(item.album ?? existing?.album),
            durationMs: Value(item.durationMs ?? existing?.durationMs),
            artworkPath: Value(item.artworkPath ?? existing?.artworkPath),
            isFavorite:
                Value(existing?.isFavorite ?? (item.isFavorite ? 1 : 0)),
            folderPath: Value(item.folderPath),
            scannedAt: Value(now),
            thumbnailPath: Value(item.thumbnailPath),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> syncMediaItems(
    List<MediaItem> items,
    List<String> folders, {
    List<MediaMetadata>? metadata,
  }) async {
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
      final existingMap = <String, MediaItemRow>{};
      final paths = items.map((i) => i.path).toList();
      final existingRows =
          await (select(mediaItems)..where((t) => t.path.isIn(paths))).get();
      for (final row in existingRows) {
        existingMap[row.path] = row;
      }
      final metaMap = {
        if (metadata != null)
          for (final m in metadata) m.mediaPath: m
      };
      final now = DateTime.now().toIso8601String();
      await batch((b) {
        for (final item in items) {
          final existing2 = existingMap[item.path];
          final unchanged = existing2?.fileHash != null &&
              item.fileHash != null &&
              existing2!.fileHash == item.fileHash;
          if (unchanged) continue; // skip unmodified files

          final meta = metaMap[item.path];
          b.insert(
            mediaItems,
            MediaItemsCompanion(
              path: Value(item.path),
              name: Value(item.name),
              type: Value(item.type.name),
              size: Value(item.size),
              modified: Value(item.modified.toIso8601String()),
              fileHash: Value(item.fileHash),
              title: Value(item.title ?? existing2?.title),
              artist: Value(item.artist ?? existing2?.artist),
              album: Value(item.album ?? existing2?.album),
              durationMs: Value(item.durationMs ?? existing2?.durationMs),
              artworkPath: Value(item.artworkPath ?? existing2?.artworkPath),
              isFavorite:
                  Value(existing2?.isFavorite ?? (item.isFavorite ? 1 : 0)),
              folderPath: Value(item.folderPath),
              scannedAt: Value(now),
              thumbnailPath: Value(item.thumbnailPath),
              imageWidth: Value(meta?.imageWidth ?? existing2?.imageWidth),
              imageHeight: Value(meta?.imageHeight ?? existing2?.imageHeight),
              imageDateTaken:
                  Value(meta?.imageDateTaken ?? existing2?.imageDateTaken),
              imageCameraMake:
                  Value(meta?.imageCameraMake ?? existing2?.imageCameraMake),
              imageCameraModel:
                  Value(meta?.imageCameraModel ?? existing2?.imageCameraModel),
              imageGpsLat: Value(meta?.imageGpsLat ?? existing2?.imageGpsLat),
              imageGpsLng: Value(meta?.imageGpsLng ?? existing2?.imageGpsLng),
              imageIso: Value(meta?.imageIso ?? existing2?.imageIso),
              imageFocalLength:
                  Value(meta?.imageFocalLength ?? existing2?.imageFocalLength),
              imageFNumber:
                  Value(meta?.imageFNumber ?? existing2?.imageFNumber),
              videoWidth: Value(meta?.videoWidth ?? existing2?.videoWidth),
              videoHeight: Value(meta?.videoHeight ?? existing2?.videoHeight),
              videoCodec: Value(meta?.videoCodec ?? existing2?.videoCodec),
              videoFps: Value(meta?.videoFps ?? existing2?.videoFps),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
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
    await transaction(() async {
      await delete(playHistory).go();
      await delete(collectionItems).go();
      await delete(playlistItems).go();
      await delete(mediaTags).go();
      await delete(mediaItems).go();
    });
  }

  Future<void> removeMediaItems(List<String> paths) async {
    for (final path in paths) {
      await transaction(() async {
        await (delete(collectionItems)..where((t) => t.mediaPath.equals(path)))
            .go();
        await (delete(playlistItems)..where((t) => t.mediaPath.equals(path)))
            .go();
        await (delete(playHistory)..where((t) => t.mediaPath.equals(path)))
            .go();
        // MediaTags has ON DELETE CASCADE, but explicit delete is safer
        await (delete(mediaTags)..where((t) => t.mediaPath.equals(path))).go();
        await (delete(mediaItems)..where((t) => t.path.equals(path))).go();
      });
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
          ..orderBy([
            (t) => OrderingTerm(expression: t.isGroup, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
    return rows
        .map((r) => Tag(
              id: r.id,
              name: r.name,
              color: r.color,
              parentId: r.parentId,
              isGroup: r.isGroup,
            ))
        .toList();
  }

  Future<Tag> createTag(
    String name, {
    int color = 0xFF5C5C5C,
    int? parentId,
    bool isGroup = false,
  }) async {
    final normalized = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty || normalized.length > 40) {
      throw ArgumentError('标签名称须为 1 到 40 个字符');
    }
    final existing = await getAllTags();
    if (existing
        .any((tag) => tag.name.toLowerCase() == normalized.toLowerCase())) {
      throw ArgumentError('标签名称已存在');
    }
    if (isGroup && parentId != null) {
      throw ArgumentError('分类组不能包含父级');
    }
    if (parentId != null) {
      final parent = existing.where((tag) => tag.id == parentId).firstOrNull;
      if (parent == null || !parent.isGroup) {
        throw ArgumentError('标签父级必须是分类组');
      }
    }
    final id = await into(tags).insert(TagsCompanion(
      name: Value(normalized),
      color: Value(color),
      parentId: Value(parentId),
      isGroup: Value(isGroup),
    ));
    return Tag(
      id: id,
      name: normalized,
      color: color,
      parentId: parentId,
      isGroup: isGroup,
    );
  }

  Future<void> deleteTag(int id) async {
    await transaction(() async {
      await (update(tags)..where((t) => t.parentId.equals(id)))
          .write(const TagsCompanion(parentId: Value(null)));
      await (delete(mediaTags)..where((t) => t.tagId.equals(id))).go();
      await (delete(tags)..where((t) => t.id.equals(id))).go();
    });
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

  Future<void> setTagForMediaPaths(
    List<String> paths,
    int tagId,
    bool selected,
  ) async {
    await transaction(() async {
      for (final path in paths) {
        if (selected) {
          await addTagToMedia(path, tagId);
        } else {
          await removeTagFromMedia(path, tagId);
        }
      }
    });
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
        t.id: Tag(
          id: t.id,
          name: t.name,
          color: t.color,
          parentId: t.parentId,
          isGroup: t.isGroup,
        )
    };

    for (final rel in relations) {
      final tag = tagMap[rel.tagId];
      if (tag != null) {
        result.putIfAbsent(rel.mediaPath, () => []).add(tag);
      }
    }
    return result;
  }

  Future<List<MediaItem>> getMediaItemsForTag(int tagId) async {
    final query = select(mediaItems).join([
      innerJoin(mediaTags, mediaTags.mediaPath.equalsExp(mediaItems.path)),
    ])
      ..where(mediaTags.tagId.equals(tagId))
      ..orderBy([
        OrderingTerm(expression: mediaItems.modified, mode: OrderingMode.desc)
      ]);
    final rows = await query.get();
    return rows
        .map((row) => _mediaItemFromRow(row.readTable(mediaItems)))
        .toList();
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

  /// Return cache key filenames for all media items (used by CacheManager).
  Future<Set<String>> getAllCacheFilenames() async {
    final rows = await select(mediaItems).get();
    return rows.map((row) {
      // Build the same hash as CacheManager.cacheFilename would
      final path = row.path.replaceAll('\\', '/').toLowerCase();
      final input =
          '$path|${row.size}|${DateTime.parse(row.modified).millisecondsSinceEpoch}';
      var hash = 0xcbf29ce484222325;
      for (final unit in input.codeUnits) {
        hash ^= unit;
        hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
      }
      return hash.toRadixString(16);
    }).toSet();
  }

  // ---------------------------------------------------------------------------
  // Play history DAO
  // ---------------------------------------------------------------------------

  Future<void> recordPlay(String mediaPath) async {
    await into(playHistory).insert(
      PlayHistoryCompanion.insert(
        mediaPath: mediaPath,
        playedAt: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<BookReadingState?> getBookReadingState(String mediaPath) async {
    final row = await (select(bookReadingStates)
          ..where((t) => t.mediaPath.equals(mediaPath)))
        .getSingleOrNull();
    if (row == null) return null;
    return BookReadingState(
      mediaPath: row.mediaPath,
      coverPath: row.coverPath,
      progress: row.progress,
      epubCfi: row.epubCfi,
      pdfPage: row.pdfPage,
      updatedAt: DateTime.parse(row.updatedAt),
    );
  }

  Future<void> saveBookReadingState(BookReadingState state) async {
    await into(bookReadingStates).insert(
      BookReadingStatesCompanion(
        mediaPath: Value(state.mediaPath),
        coverPath: Value(state.coverPath),
        progress: Value(state.progress.clamp(0, 1)),
        epubCfi: Value(state.epubCfi),
        pdfPage: Value(state.pdfPage),
        updatedAt: Value(state.updatedAt.toIso8601String()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<List<BookBookmark>> getBookBookmarks(String mediaPath) async {
    final rows = await (select(bookBookmarks)
          ..where((t) => t.mediaPath.equals(mediaPath))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();
    return rows
        .map((row) => BookBookmark(
              mediaPath: row.mediaPath,
              locator: row.locator,
              title: row.title,
              excerpt: row.excerpt,
              createdAt: DateTime.parse(row.createdAt),
            ))
        .toList();
  }

  Future<void> saveBookBookmark(BookBookmark bookmark) async {
    await into(bookBookmarks).insert(
      BookBookmarksCompanion(
        mediaPath: Value(bookmark.mediaPath),
        locator: Value(bookmark.locator),
        title: Value(bookmark.title),
        excerpt: Value(bookmark.excerpt),
        createdAt: Value(bookmark.createdAt.toIso8601String()),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteBookBookmark(String mediaPath, String locator) async {
    await (delete(bookBookmarks)
          ..where((t) => t.mediaPath.equals(mediaPath))
          ..where((t) => t.locator.equals(locator)))
        .go();
  }

  Future<List<MediaItem>> getPlayHistory(
      {int limit = 100, int offset = 0}) async {
    // Deduplicate by media path: each media appears at most once, positioned
    // by its most recent play time. This both fixes the symptom of the
    // historical double-recording bug (where the same media showed up two or
    // three times in a row) and gives a cleaner "recently played" list — a
    // track replayed several times only occupies one slot, at its latest
    // play time.
    //
    // GROUP BY media_path collapses all rows for the same media into one;
    // MAX(played_at) drives the ordering. Because the join is on
    // media_items.path = play_history.media_path, every row in a group
    // carries identical media_items columns, so reading the joined
    // media_items row is well-defined.
    final latestPlayed = playHistory.playedAt.max();
    final query = select(playHistory).join([
      innerJoin(mediaItems, mediaItems.path.equalsExp(playHistory.mediaPath)),
    ])
      ..addColumns([latestPlayed])
      ..groupBy([playHistory.mediaPath])
      ..orderBy(
          [OrderingTerm(expression: latestPlayed, mode: OrderingMode.desc)])
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
        fileHash: row.fileHash,
        title: row.title,
        artist: row.artist,
        album: row.album,
        durationMs: row.durationMs,
        artworkPath: row.artworkPath,
        isFavorite: row.isFavorite == 1,
        thumbnailPath: row.thumbnailPath,
      );

  /// Load metadata for a single media item lazily.
  Future<MediaMetadata?> getMediaMetadata(String path) async {
    final row = await (select(mediaItems)..where((t) => t.path.equals(path)))
        .getSingleOrNull();
    if (row == null) return null;
    return MediaMetadata(
      mediaPath: row.path,
      imageWidth: row.imageWidth,
      imageHeight: row.imageHeight,
      imageDateTaken: row.imageDateTaken,
      imageCameraMake: row.imageCameraMake,
      imageCameraModel: row.imageCameraModel,
      imageGpsLat: row.imageGpsLat,
      imageGpsLng: row.imageGpsLng,
      imageIso: row.imageIso,
      imageFocalLength: row.imageFocalLength,
      imageFNumber: row.imageFNumber,
      videoWidth: row.videoWidth,
      videoHeight: row.videoHeight,
      videoCodec: row.videoCodec,
      videoFps: row.videoFps,
    );
  }

  /// Update the metadata columns for an existing media item.
  Future<void> upsertMediaMetadata(MediaMetadata metadata) async {
    await (update(mediaItems)..where((t) => t.path.equals(metadata.mediaPath)))
        .write(
      MediaItemsCompanion(
        imageWidth: Value(metadata.imageWidth),
        imageHeight: Value(metadata.imageHeight),
        imageDateTaken: Value(metadata.imageDateTaken),
        imageCameraMake: Value(metadata.imageCameraMake),
        imageCameraModel: Value(metadata.imageCameraModel),
        imageGpsLat: Value(metadata.imageGpsLat),
        imageGpsLng: Value(metadata.imageGpsLng),
        imageIso: Value(metadata.imageIso),
        imageFocalLength: Value(metadata.imageFocalLength),
        imageFNumber: Value(metadata.imageFNumber),
        videoWidth: Value(metadata.videoWidth),
        videoHeight: Value(metadata.videoHeight),
        videoCodec: Value(metadata.videoCodec),
        videoFps: Value(metadata.videoFps),
      ),
    );
  }

  /// Batch update metadata for multiple items.
  Future<void> upsertMediaMetadataBatch(
      List<MediaMetadata> metadataList) async {
    if (metadataList.isEmpty) return;
    await batch((b) {
      for (final m in metadataList) {
        b.update(
          mediaItems,
          MediaItemsCompanion(
            imageWidth: Value(m.imageWidth),
            imageHeight: Value(m.imageHeight),
            imageDateTaken: Value(m.imageDateTaken),
            imageCameraMake: Value(m.imageCameraMake),
            imageCameraModel: Value(m.imageCameraModel),
            imageGpsLat: Value(m.imageGpsLat),
            imageGpsLng: Value(m.imageGpsLng),
            imageIso: Value(m.imageIso),
            imageFocalLength: Value(m.imageFocalLength),
            imageFNumber: Value(m.imageFNumber),
            videoWidth: Value(m.videoWidth),
            videoHeight: Value(m.videoHeight),
            videoCodec: Value(m.videoCodec),
            videoFps: Value(m.videoFps),
          ),
          where: (t) => t.path.equals(m.mediaPath),
        );
      }
    });
  }
}
