import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/collection.dart';
import '../models/media_item.dart';
import '../models/media_type.dart';
import '../models/playlist.dart';
import '../models/tag.dart';

/// SQLite-backed persistence for all media data, tags, collections and playlists.
///
/// Uses `sqflite_common_ffi` (no native plugin needed on desktop). The database
/// file lives in the application support directory alongside the app.
class DatabaseService {
  static Database? _db;

  /// Whether the database was successfully initialised.
  static bool get isAvailable => _db != null;

  /// Obtain (or create) the singleton database connection.
  ///
  /// Throws when the underlying SQLite library cannot be loaded (e.g. missing
  /// `sqlite3.dll` on Windows). Callers — especially [main()] — should catch
  /// and degrade gracefully.
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  static Future<Database> _initDatabase() async {
    // Initialize FFI bindings for SQLite on desktop.
    sqfliteFfiInit();

    final dir = await getApplicationSupportDirectory();
    final dbPath = p.join(dir.path, 'lumiluna.db');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS media_items (
        path TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        size INTEGER NOT NULL DEFAULT 0,
        modified TEXT NOT NULL,
        title TEXT,
        artist TEXT,
        album TEXT,
        duration_ms INTEGER,
        artwork_path TEXT,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        folder_path TEXT NOT NULL,
        scanned_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color INTEGER NOT NULL DEFAULT 4283181612
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS media_tags (
        media_path TEXT NOT NULL REFERENCES media_items(path) ON DELETE CASCADE,
        tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
        PRIMARY KEY (media_path, tag_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        cover_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS collection_items (
        collection_id INTEGER NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
        media_path TEXT NOT NULL REFERENCES media_items(path) ON DELETE CASCADE,
        added_at TEXT NOT NULL DEFAULT (datetime('now')),
        sort_order INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (collection_id, media_path)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        cover_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS playlist_items (
        playlist_id INTEGER NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
        media_path TEXT NOT NULL REFERENCES media_items(path) ON DELETE CASCADE,
        added_at TEXT NOT NULL DEFAULT (datetime('now')),
        sort_order INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (playlist_id, media_path)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS scan_folders (
        path TEXT PRIMARY KEY,
        recursive INTEGER NOT NULL DEFAULT 1,
        last_scanned TEXT
      )
    ''');

    // Indices for common queries.
    await db.execute('CREATE INDEX IF NOT EXISTS idx_media_type ON media_items(type)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_media_favorite ON media_items(is_favorite)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_media_folder ON media_items(folder_path)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here.
  }

  /// Close the database connection (e.g. on app exit).
  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // ---------------------------------------------------------------------------
  // Media items
  // ---------------------------------------------------------------------------

  /// Insert or replace a batch of media items (used after scanning).
  static Future<void> upsertMediaItems(List<MediaItem> items) async {
    final db = await database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert(
        'media_items',
        {
          'path': item.path,
          'name': item.name,
          'type': item.type.name,
          'size': item.size,
          'modified': item.modified.toIso8601String(),
          'title': item.title,
          'artist': item.artist,
          'album': item.album,
          'duration_ms': item.durationMs,
          'artwork_path': item.artworkPath,
          'is_favorite': item.isFavorite ? 1 : 0,
          'folder_path': item.folderPath,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Get all media items, optionally filtered by type and search.
  static Future<List<MediaItem>> getMediaItems({
    MediaType? type,
    String? searchQuery,
    bool? favoritesOnly,
    String? folderPath,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final params = <dynamic>[];

    if (type != null) {
      conditions.add('type = ?');
      params.add(type.name);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      conditions.add('(name LIKE ? OR title LIKE ? OR artist LIKE ? OR album LIKE ?)');
      final q = '%$searchQuery%';
      params.addAll([q, q, q, q]);
    }
    if (favoritesOnly == true) {
      conditions.add('is_favorite = 1');
    }
    if (folderPath != null) {
      conditions.add('folder_path = ?');
      params.add(folderPath);
    }

    final where = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';
    final orderBy = 'ORDER BY modified DESC';
    final limitClause = limit != null ? 'LIMIT ?' : '';
    if (limit != null) params.add(limit);
    if (offset != null) params.add(offset);
    final offsetClause = offset != null ? 'OFFSET ?' : '';

    final rows = await db.rawQuery(
      'SELECT * FROM media_items $where $orderBy $limitClause $offsetClause',
      params,
    );
    return rows.map(_mediaItemFromRow).toList();
  }

  /// Get a single media item by path.
  static Future<MediaItem?> getMediaItem(String path) async {
    final db = await database;
    final rows = await db.query('media_items', where: 'path = ?', whereArgs: [path]);
    if (rows.isEmpty) return null;
    return _mediaItemFromRow(rows.first);
  }

  /// Get all distinct folder paths.
  static Future<List<String>> getFolderPaths() async {
    final db = await database;
    final rows = await db.rawQuery('SELECT DISTINCT folder_path FROM media_items ORDER BY folder_path');
    return rows.map((r) => r['folder_path'] as String).toList();
  }

  /// Count items, optionally by type.
  static Future<Map<MediaType, int>> getMediaCounts() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT type, COUNT(*) as cnt FROM media_items GROUP BY type',
    );
    final counts = {for (final t in MediaType.values) t: 0};
    for (final row in rows) {
      final type = MediaType.values.firstWhere(
        (t) => t.name == row['type'],
        orElse: () => MediaType.image,
      );
      counts[type] = (row['cnt'] as int);
    }
    return counts;
  }

  /// Update the favorite flag for a media item.
  static Future<void> setFavorite(String path, bool isFavorite) async {
    final db = await database;
    await db.update(
      'media_items',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'path = ?',
      whereArgs: [path],
    );
  }

  /// Update a media item's path (after rename).
  static Future<void> updatePath(String oldPath, String newPath, String newName) async {
    final db = await database;
    final folderPath = () {
      final normalized = newPath.replaceAll('\\', '/');
      final idx = normalized.lastIndexOf('/');
      return idx >= 0 ? normalized.substring(0, idx) : normalized;
    }();
    await db.update(
      'media_items',
      {'path': newPath, 'name': newName, 'folder_path': folderPath},
      where: 'path = ?',
      whereArgs: [oldPath],
    );
    // Update references in other tables.
    for (final table in ['media_tags', 'collection_items', 'playlist_items']) {
      await db.update(
        table,
        {'media_path': newPath},
        where: 'media_path = ?',
        whereArgs: [oldPath],
      );
    }
  }

  /// Remove items by path.
  static Future<void> removeMediaItems(List<String> paths) async {
    final db = await database;
    final batch = db.batch();
    for (final path in paths) {
      batch.delete('media_items', where: 'path = ?', whereArgs: [path]);
    }
    await batch.commit(noResult: true);
  }

  /// Clear all media items (before a full rescan).
  static Future<void> clearMediaItems() async {
    final db = await database;
    await db.delete('media_items');
  }

  /// Total number of media items.
  static Future<int> getMediaCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM media_items');
    return (result.first['cnt'] as int?) ?? 0;
  }

  static MediaItem _mediaItemFromRow(Map<String, dynamic> row) => MediaItem(
        path: row['path'] as String,
        name: row['name'] as String,
        type: MediaType.values.firstWhere((t) => t.name == row['type']),
        size: (row['size'] as int?) ?? 0,
        modified: DateTime.parse(row['modified'] as String),
        title: row['title'] as String?,
        artist: row['artist'] as String?,
        album: row['album'] as String?,
        durationMs: row['duration_ms'] as int?,
        artworkPath: row['artwork_path'] as String?,
        isFavorite: (row['is_favorite'] as int?) == 1,
      );

  // ---------------------------------------------------------------------------
  // Tags
  // ---------------------------------------------------------------------------

  static Future<List<Tag>> getTags({int? mediaPath}) async {
    final db = await database;
    if (mediaPath != null) {
      final rows = await db.rawQuery(
        'SELECT t.* FROM tags t INNER JOIN media_tags mt ON t.id = mt.tag_id WHERE mt.media_path = ?',
        [mediaPath],
      );
      return rows.map((r) => Tag.fromJson(r)).toList();
    }
    final rows = await db.query('tags', orderBy: 'name');
    return rows.map((r) => Tag.fromJson(r)).toList();
  }

  static Future<Tag> createTag(String name, {int color = 0xFF5C5C5C}) async {
    final db = await database;
    final id = await db.insert('tags', {'name': name, 'color': color});
    return Tag(id: id, name: name, color: color);
  }

  static Future<void> deleteTag(int id) async {
    final db = await database;
    await db.delete('tags', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> addTagToMedia(String mediaPath, int tagId) async {
    final db = await database;
    await db.insert('media_tags', {'media_path': mediaPath, 'tag_id': tagId},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> removeTagFromMedia(String mediaPath, int tagId) async {
    final db = await database;
    await db.delete('media_tags',
        where: 'media_path = ? AND tag_id = ?', whereArgs: [mediaPath, tagId]);
  }

  static Future<List<String>> getMediaPathsForTag(int tagId) async {
    final db = await database;
    final rows = await db.query('media_tags',
        where: 'tag_id = ?', whereArgs: [tagId]);
    return rows.map((r) => r['media_path'] as String).toList();
  }

  /// Get a map of media path -> list of tags for many items at once.
  static Future<Map<String, List<Tag>>> getTagsForMediaPaths(List<String> paths) async {
    if (paths.isEmpty) return {};
    final db = await database;
    final placeholders = paths.map((_) => '?').join(',');
    final rows = await db.rawQuery('''
      SELECT mt.media_path, t.id, t.name, t.color
      FROM media_tags mt
      INNER JOIN tags t ON t.id = mt.tag_id
      WHERE mt.media_path IN ($placeholders)
    ''', paths);
    final result = <String, List<Tag>>{};
    for (final row in rows) {
      final path = row['media_path'] as String;
      result.putIfAbsent(path, () => []).add(Tag(
        id: row['id'] as int,
        name: row['name'] as String,
        color: (row['color'] as int?) ?? 0xFF5C5C5C,
      ));
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Collections
  // ---------------------------------------------------------------------------

  static Future<List<MediaCollection>> getCollections() async {
    final db = await database;
    final rows = await db.query('collections', orderBy: 'updated_at DESC');
    final collections = <MediaCollection>[];
    for (final row in rows) {
      final id = row['id'] as int;
      final itemRows = await db.rawQuery('''
        SELECT mi.* FROM media_items mi
        INNER JOIN collection_items ci ON ci.media_path = mi.path
        WHERE ci.collection_id = ?
        ORDER BY ci.sort_order
      ''', [id]);
      collections.add(MediaCollection(
        id: id,
        name: row['name'] as String,
        description: row['description'] as String?,
        coverPath: row['cover_path'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
        items: itemRows.map(_mediaItemFromRow).toList(),
      ));
    }
    return collections;
  }

  static Future<MediaCollection> createCollection(String name, {String? description}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final id = await db.insert('collections', {
      'name': name,
      'description': description,
      'created_at': now,
      'updated_at': now,
    });
    return MediaCollection(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  static Future<void> deleteCollection(int id) async {
    final db = await database;
    await db.delete('collections', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> addToCollection(int collectionId, List<String> mediaPaths) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (var i = 0; i < mediaPaths.length; i++) {
      batch.insert('collection_items', {
        'collection_id': collectionId,
        'media_path': mediaPaths[i],
        'added_at': now,
        'sort_order': i,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
    await db.update('collections', {'updated_at': now},
        where: 'id = ?', whereArgs: [collectionId]);
  }

  static Future<void> removeFromCollection(int collectionId, String mediaPath) async {
    final db = await database;
    await db.delete('collection_items',
        where: 'collection_id = ? AND media_path = ?',
        whereArgs: [collectionId, mediaPath]);
  }

  // ---------------------------------------------------------------------------
  // Playlists
  // ---------------------------------------------------------------------------

  static Future<List<Playlist>> getPlaylists() async {
    final db = await database;
    final rows = await db.query('playlists', orderBy: 'updated_at DESC');
    final playlists = <Playlist>[];
    for (final row in rows) {
      final id = row['id'] as int;
      final itemRows = await db.rawQuery('''
        SELECT mi.* FROM media_items mi
        INNER JOIN playlist_items pi ON pi.media_path = mi.path
        WHERE pi.playlist_id = ?
        ORDER BY pi.sort_order
      ''', [id]);
      playlists.add(Playlist(
        id: id,
        name: row['name'] as String,
        description: row['description'] as String?,
        coverPath: row['cover_path'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
        items: itemRows.map(_mediaItemFromRow).toList(),
      ));
    }
    return playlists;
  }

  static Future<Playlist> createPlaylist(String name, {String? description}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final id = await db.insert('playlists', {
      'name': name,
      'description': description,
      'created_at': now,
      'updated_at': now,
    });
    return Playlist(
      id: id,
      name: name,
      description: description,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  static Future<void> deletePlaylist(int id) async {
    final db = await database;
    await db.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> addToPlaylist(int playlistId, List<String> mediaPaths) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    // Get current max sort_order.
    final maxOrder = await db.rawQuery(
      'SELECT COALESCE(MAX(sort_order), -1) as mx FROM playlist_items WHERE playlist_id = ?',
      [playlistId],
    );
    final startOrder = ((maxOrder.first['mx'] as int?) ?? -1) + 1;
    final batch = db.batch();
    for (var i = 0; i < mediaPaths.length; i++) {
      batch.insert('playlist_items', {
        'playlist_id': playlistId,
        'media_path': mediaPaths[i],
        'added_at': now,
        'sort_order': startOrder + i,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
    await db.update('playlists', {'updated_at': now},
        where: 'id = ?', whereArgs: [playlistId]);
  }

  static Future<void> removeFromPlaylist(int playlistId, String mediaPath) async {
    final db = await database;
    await db.delete('playlist_items',
        where: 'playlist_id = ? AND media_path = ?',
        whereArgs: [playlistId, mediaPath]);
  }

  static Future<void> reorderPlaylist(int playlistId, List<String> orderedPaths) async {
    final db = await database;
    final batch = db.batch();
    for (var i = 0; i < orderedPaths.length; i++) {
      batch.update('playlist_items', {'sort_order': i},
          where: 'playlist_id = ? AND media_path = ?',
          whereArgs: [playlistId, orderedPaths[i]]);
    }
    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------------------
  // Scan folders
  // ---------------------------------------------------------------------------

  static Future<List<String>> getScanFolders() async {
    final db = await database;
    final rows = await db.query('scan_folders');
    return rows.map((r) => r['path'] as String).toList();
  }

  static Future<void> setScanFolders(List<String> folders) async {
    final db = await database;
    await db.delete('scan_folders');
    final batch = db.batch();
    for (final folder in folders) {
      batch.insert('scan_folders', {'path': folder, 'recursive': 1});
    }
    await batch.commit(noResult: true);
  }

  static Future<void> updateLastScanned(String folderPath) async {
    final db = await database;
    await db.update('scan_folders', {'last_scanned': DateTime.now().toIso8601String()},
        where: 'path = ?', whereArgs: [folderPath]);
  }
}
