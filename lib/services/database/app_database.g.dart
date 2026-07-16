// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
      'size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _modifiedMeta =
      const VerificationMeta('modified');
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
      'modified', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
      'artist', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
      'album', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _artworkPathMeta =
      const VerificationMeta('artworkPath');
  @override
  late final GeneratedColumn<String> artworkPath = GeneratedColumn<String>(
      'artwork_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<int> isFavorite = GeneratedColumn<int>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _folderPathMeta =
      const VerificationMeta('folderPath');
  @override
  late final GeneratedColumn<String> folderPath = GeneratedColumn<String>(
      'folder_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scannedAtMeta =
      const VerificationMeta('scannedAt');
  @override
  late final GeneratedColumn<String> scannedAt = GeneratedColumn<String>(
      'scanned_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: Constant(''));
  @override
  List<GeneratedColumn> get $columns => [
        path,
        name,
        type,
        size,
        modified,
        title,
        artist,
        album,
        durationMs,
        artworkPath,
        isFavorite,
        folderPath,
        scannedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(Insertable<MediaItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    }
    if (data.containsKey('modified')) {
      context.handle(_modifiedMeta,
          modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta));
    } else if (isInserting) {
      context.missing(_modifiedMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('artist')) {
      context.handle(_artistMeta,
          artist.isAcceptableOrUnknown(data['artist']!, _artistMeta));
    }
    if (data.containsKey('album')) {
      context.handle(
          _albumMeta, album.isAcceptableOrUnknown(data['album']!, _albumMeta));
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('artwork_path')) {
      context.handle(
          _artworkPathMeta,
          artworkPath.isAcceptableOrUnknown(
              data['artwork_path']!, _artworkPathMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('folder_path')) {
      context.handle(
          _folderPathMeta,
          folderPath.isAcceptableOrUnknown(
              data['folder_path']!, _folderPathMeta));
    } else if (isInserting) {
      context.missing(_folderPathMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(_scannedAtMeta,
          scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {path};
  @override
  MediaItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItemRow(
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size'])!,
      modified: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}modified'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      artist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist']),
      album: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}album']),
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms']),
      artworkPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artwork_path']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_favorite'])!,
      folderPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_path'])!,
      scannedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scanned_at'])!,
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }
}

class MediaItemRow extends DataClass implements Insertable<MediaItemRow> {
  final String path;
  final String name;
  final String type;
  final int size;
  final String modified;
  final String? title;
  final String? artist;
  final String? album;
  final int? durationMs;
  final String? artworkPath;
  final int isFavorite;
  final String folderPath;
  final String scannedAt;
  const MediaItemRow(
      {required this.path,
      required this.name,
      required this.type,
      required this.size,
      required this.modified,
      this.title,
      this.artist,
      this.album,
      this.durationMs,
      this.artworkPath,
      required this.isFavorite,
      required this.folderPath,
      required this.scannedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['path'] = Variable<String>(path);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['size'] = Variable<int>(size);
    map['modified'] = Variable<String>(modified);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || artworkPath != null) {
      map['artwork_path'] = Variable<String>(artworkPath);
    }
    map['is_favorite'] = Variable<int>(isFavorite);
    map['folder_path'] = Variable<String>(folderPath);
    map['scanned_at'] = Variable<String>(scannedAt);
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      path: Value(path),
      name: Value(name),
      type: Value(type),
      size: Value(size),
      modified: Value(modified),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      artist:
          artist == null && nullToAbsent ? const Value.absent() : Value(artist),
      album:
          album == null && nullToAbsent ? const Value.absent() : Value(album),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      artworkPath: artworkPath == null && nullToAbsent
          ? const Value.absent()
          : Value(artworkPath),
      isFavorite: Value(isFavorite),
      folderPath: Value(folderPath),
      scannedAt: Value(scannedAt),
    );
  }

  factory MediaItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItemRow(
      path: serializer.fromJson<String>(json['path']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      size: serializer.fromJson<int>(json['size']),
      modified: serializer.fromJson<String>(json['modified']),
      title: serializer.fromJson<String?>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      artworkPath: serializer.fromJson<String?>(json['artworkPath']),
      isFavorite: serializer.fromJson<int>(json['isFavorite']),
      folderPath: serializer.fromJson<String>(json['folderPath']),
      scannedAt: serializer.fromJson<String>(json['scannedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'path': serializer.toJson<String>(path),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'size': serializer.toJson<int>(size),
      'modified': serializer.toJson<String>(modified),
      'title': serializer.toJson<String?>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'durationMs': serializer.toJson<int?>(durationMs),
      'artworkPath': serializer.toJson<String?>(artworkPath),
      'isFavorite': serializer.toJson<int>(isFavorite),
      'folderPath': serializer.toJson<String>(folderPath),
      'scannedAt': serializer.toJson<String>(scannedAt),
    };
  }

  MediaItemRow copyWith(
          {String? path,
          String? name,
          String? type,
          int? size,
          String? modified,
          Value<String?> title = const Value.absent(),
          Value<String?> artist = const Value.absent(),
          Value<String?> album = const Value.absent(),
          Value<int?> durationMs = const Value.absent(),
          Value<String?> artworkPath = const Value.absent(),
          int? isFavorite,
          String? folderPath,
          String? scannedAt}) =>
      MediaItemRow(
        path: path ?? this.path,
        name: name ?? this.name,
        type: type ?? this.type,
        size: size ?? this.size,
        modified: modified ?? this.modified,
        title: title.present ? title.value : this.title,
        artist: artist.present ? artist.value : this.artist,
        album: album.present ? album.value : this.album,
        durationMs: durationMs.present ? durationMs.value : this.durationMs,
        artworkPath: artworkPath.present ? artworkPath.value : this.artworkPath,
        isFavorite: isFavorite ?? this.isFavorite,
        folderPath: folderPath ?? this.folderPath,
        scannedAt: scannedAt ?? this.scannedAt,
      );
  MediaItemRow copyWithCompanion(MediaItemsCompanion data) {
    return MediaItemRow(
      path: data.path.present ? data.path.value : this.path,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      size: data.size.present ? data.size.value : this.size,
      modified: data.modified.present ? data.modified.value : this.modified,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      artworkPath:
          data.artworkPath.present ? data.artworkPath.value : this.artworkPath,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      folderPath:
          data.folderPath.present ? data.folderPath.value : this.folderPath,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemRow(')
          ..write('path: $path, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('size: $size, ')
          ..write('modified: $modified, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('folderPath: $folderPath, ')
          ..write('scannedAt: $scannedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      path,
      name,
      type,
      size,
      modified,
      title,
      artist,
      album,
      durationMs,
      artworkPath,
      isFavorite,
      folderPath,
      scannedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItemRow &&
          other.path == this.path &&
          other.name == this.name &&
          other.type == this.type &&
          other.size == this.size &&
          other.modified == this.modified &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.durationMs == this.durationMs &&
          other.artworkPath == this.artworkPath &&
          other.isFavorite == this.isFavorite &&
          other.folderPath == this.folderPath &&
          other.scannedAt == this.scannedAt);
}

class MediaItemsCompanion extends UpdateCompanion<MediaItemRow> {
  final Value<String> path;
  final Value<String> name;
  final Value<String> type;
  final Value<int> size;
  final Value<String> modified;
  final Value<String?> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<int?> durationMs;
  final Value<String?> artworkPath;
  final Value<int> isFavorite;
  final Value<String> folderPath;
  final Value<String> scannedAt;
  final Value<int> rowid;
  const MediaItemsCompanion({
    this.path = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.size = const Value.absent(),
    this.modified = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.folderPath = const Value.absent(),
    this.scannedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    required String path,
    required String name,
    required String type,
    this.size = const Value.absent(),
    required String modified,
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.artworkPath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required String folderPath,
    this.scannedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : path = Value(path),
        name = Value(name),
        type = Value(type),
        modified = Value(modified),
        folderPath = Value(folderPath);
  static Insertable<MediaItemRow> custom({
    Expression<String>? path,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? size,
    Expression<String>? modified,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<int>? durationMs,
    Expression<String>? artworkPath,
    Expression<int>? isFavorite,
    Expression<String>? folderPath,
    Expression<String>? scannedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (size != null) 'size': size,
      if (modified != null) 'modified': modified,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (durationMs != null) 'duration_ms': durationMs,
      if (artworkPath != null) 'artwork_path': artworkPath,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (folderPath != null) 'folder_path': folderPath,
      if (scannedAt != null) 'scanned_at': scannedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaItemsCompanion copyWith(
      {Value<String>? path,
      Value<String>? name,
      Value<String>? type,
      Value<int>? size,
      Value<String>? modified,
      Value<String?>? title,
      Value<String?>? artist,
      Value<String?>? album,
      Value<int?>? durationMs,
      Value<String?>? artworkPath,
      Value<int>? isFavorite,
      Value<String>? folderPath,
      Value<String>? scannedAt,
      Value<int>? rowid}) {
    return MediaItemsCompanion(
      path: path ?? this.path,
      name: name ?? this.name,
      type: type ?? this.type,
      size: size ?? this.size,
      modified: modified ?? this.modified,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      artworkPath: artworkPath ?? this.artworkPath,
      isFavorite: isFavorite ?? this.isFavorite,
      folderPath: folderPath ?? this.folderPath,
      scannedAt: scannedAt ?? this.scannedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (artworkPath.present) {
      map['artwork_path'] = Variable<String>(artworkPath.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<int>(isFavorite.value);
    }
    if (folderPath.present) {
      map['folder_path'] = Variable<String>(folderPath.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<String>(scannedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('path: $path, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('size: $size, ')
          ..write('modified: $modified, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('durationMs: $durationMs, ')
          ..write('artworkPath: $artworkPath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('folderPath: $folderPath, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFF5C5C5C));
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<TagRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final int id;
  final String name;
  final int color;
  const TagRow({required this.id, required this.name, required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
    );
  }

  factory TagRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
    };
  }

  TagRow copyWith({int? id, String? name, int? color}) => TagRow(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
      );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.color = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TagRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  TagsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<int>? color}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $MediaTagsTable extends MediaTags
    with TableInfo<$MediaTagsTable, MediaTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mediaPathMeta =
      const VerificationMeta('mediaPath');
  @override
  late final GeneratedColumn<String> mediaPath = GeneratedColumn<String>(
      'media_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES media_items (path) ON DELETE CASCADE'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tags (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [mediaPath, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_tags';
  @override
  VerificationContext validateIntegrity(Insertable<MediaTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('media_path')) {
      context.handle(_mediaPathMeta,
          mediaPath.isAcceptableOrUnknown(data['media_path']!, _mediaPathMeta));
    } else if (isInserting) {
      context.missing(_mediaPathMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaPath, tagId};
  @override
  MediaTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaTag(
      mediaPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_path'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $MediaTagsTable createAlias(String alias) {
    return $MediaTagsTable(attachedDatabase, alias);
  }
}

class MediaTag extends DataClass implements Insertable<MediaTag> {
  final String mediaPath;
  final int tagId;
  const MediaTag({required this.mediaPath, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['media_path'] = Variable<String>(mediaPath);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  MediaTagsCompanion toCompanion(bool nullToAbsent) {
    return MediaTagsCompanion(
      mediaPath: Value(mediaPath),
      tagId: Value(tagId),
    );
  }

  factory MediaTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaTag(
      mediaPath: serializer.fromJson<String>(json['mediaPath']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaPath': serializer.toJson<String>(mediaPath),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  MediaTag copyWith({String? mediaPath, int? tagId}) => MediaTag(
        mediaPath: mediaPath ?? this.mediaPath,
        tagId: tagId ?? this.tagId,
      );
  MediaTag copyWithCompanion(MediaTagsCompanion data) {
    return MediaTag(
      mediaPath: data.mediaPath.present ? data.mediaPath.value : this.mediaPath,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaTag(')
          ..write('mediaPath: $mediaPath, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mediaPath, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaTag &&
          other.mediaPath == this.mediaPath &&
          other.tagId == this.tagId);
}

class MediaTagsCompanion extends UpdateCompanion<MediaTag> {
  final Value<String> mediaPath;
  final Value<int> tagId;
  final Value<int> rowid;
  const MediaTagsCompanion({
    this.mediaPath = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaTagsCompanion.insert({
    required String mediaPath,
    required int tagId,
    this.rowid = const Value.absent(),
  })  : mediaPath = Value(mediaPath),
        tagId = Value(tagId);
  static Insertable<MediaTag> custom({
    Expression<String>? mediaPath,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaPath != null) 'media_path': mediaPath,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaTagsCompanion copyWith(
      {Value<String>? mediaPath, Value<int>? tagId, Value<int>? rowid}) {
    return MediaTagsCompanion(
      mediaPath: mediaPath ?? this.mediaPath,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaPath.present) {
      map['media_path'] = Variable<String>(mediaPath.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaTagsCompanion(')
          ..write('mediaPath: $mediaPath, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverPathMeta =
      const VerificationMeta('coverPath');
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
      'cover_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, coverPath, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(Insertable<CollectionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('cover_path')) {
      context.handle(_coverPathMeta,
          coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      coverPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class CollectionRow extends DataClass implements Insertable<CollectionRow> {
  final int id;
  final String name;
  final String? description;
  final String? coverPath;
  final String createdAt;
  final String updatedAt;
  const CollectionRow(
      {required this.id,
      required this.name,
      this.description,
      this.coverPath,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CollectionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'coverPath': serializer.toJson<String?>(coverPath),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  CollectionRow copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> coverPath = const Value.absent(),
          String? createdAt,
          String? updatedAt}) =>
      CollectionRow(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        coverPath: coverPath.present ? coverPath.value : this.coverPath,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CollectionRow copyWithCompanion(CollectionsCompanion data) {
    return CollectionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverPath: $coverPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, coverPath, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.coverPath == this.coverPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CollectionsCompanion extends UpdateCompanion<CollectionRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> coverPath;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.coverPath = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  })  : name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CollectionRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? coverPath,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (coverPath != null) 'cover_path': coverPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CollectionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? coverPath,
      Value<String>? createdAt,
      Value<String>? updatedAt}) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPath: coverPath ?? this.coverPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverPath: $coverPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CollectionItemsTable extends CollectionItems
    with TableInfo<$CollectionItemsTable, CollectionItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
      'collection_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES collections (id) ON DELETE CASCADE'));
  static const VerificationMeta _mediaPathMeta =
      const VerificationMeta('mediaPath');
  @override
  late final GeneratedColumn<String> mediaPath = GeneratedColumn<String>(
      'media_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES media_items (path) ON DELETE CASCADE'));
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<String> addedAt = GeneratedColumn<String>(
      'added_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: Constant(''));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [collectionId, mediaPath, addedAt, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_items';
  @override
  VerificationContext validateIntegrity(Insertable<CollectionItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('media_path')) {
      context.handle(_mediaPathMeta,
          mediaPath.isAcceptableOrUnknown(data['media_path']!, _mediaPathMeta));
    } else if (isInserting) {
      context.missing(_mediaPathMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, mediaPath};
  @override
  CollectionItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionItem(
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}collection_id'])!,
      mediaPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_path'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}added_at'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $CollectionItemsTable createAlias(String alias) {
    return $CollectionItemsTable(attachedDatabase, alias);
  }
}

class CollectionItem extends DataClass implements Insertable<CollectionItem> {
  final int collectionId;
  final String mediaPath;
  final String addedAt;
  final int sortOrder;
  const CollectionItem(
      {required this.collectionId,
      required this.mediaPath,
      required this.addedAt,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<int>(collectionId);
    map['media_path'] = Variable<String>(mediaPath);
    map['added_at'] = Variable<String>(addedAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CollectionItemsCompanion toCompanion(bool nullToAbsent) {
    return CollectionItemsCompanion(
      collectionId: Value(collectionId),
      mediaPath: Value(mediaPath),
      addedAt: Value(addedAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory CollectionItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionItem(
      collectionId: serializer.fromJson<int>(json['collectionId']),
      mediaPath: serializer.fromJson<String>(json['mediaPath']),
      addedAt: serializer.fromJson<String>(json['addedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionId': serializer.toJson<int>(collectionId),
      'mediaPath': serializer.toJson<String>(mediaPath),
      'addedAt': serializer.toJson<String>(addedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CollectionItem copyWith(
          {int? collectionId,
          String? mediaPath,
          String? addedAt,
          int? sortOrder}) =>
      CollectionItem(
        collectionId: collectionId ?? this.collectionId,
        mediaPath: mediaPath ?? this.mediaPath,
        addedAt: addedAt ?? this.addedAt,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  CollectionItem copyWithCompanion(CollectionItemsCompanion data) {
    return CollectionItem(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      mediaPath: data.mediaPath.present ? data.mediaPath.value : this.mediaPath,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionItem(')
          ..write('collectionId: $collectionId, ')
          ..write('mediaPath: $mediaPath, ')
          ..write('addedAt: $addedAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collectionId, mediaPath, addedAt, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionItem &&
          other.collectionId == this.collectionId &&
          other.mediaPath == this.mediaPath &&
          other.addedAt == this.addedAt &&
          other.sortOrder == this.sortOrder);
}

class CollectionItemsCompanion extends UpdateCompanion<CollectionItem> {
  final Value<int> collectionId;
  final Value<String> mediaPath;
  final Value<String> addedAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CollectionItemsCompanion({
    this.collectionId = const Value.absent(),
    this.mediaPath = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionItemsCompanion.insert({
    required int collectionId,
    required String mediaPath,
    this.addedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : collectionId = Value(collectionId),
        mediaPath = Value(mediaPath);
  static Insertable<CollectionItem> custom({
    Expression<int>? collectionId,
    Expression<String>? mediaPath,
    Expression<String>? addedAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (mediaPath != null) 'media_path': mediaPath,
      if (addedAt != null) 'added_at': addedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionItemsCompanion copyWith(
      {Value<int>? collectionId,
      Value<String>? mediaPath,
      Value<String>? addedAt,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return CollectionItemsCompanion(
      collectionId: collectionId ?? this.collectionId,
      mediaPath: mediaPath ?? this.mediaPath,
      addedAt: addedAt ?? this.addedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (mediaPath.present) {
      map['media_path'] = Variable<String>(mediaPath.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<String>(addedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionItemsCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('mediaPath: $mediaPath, ')
          ..write('addedAt: $addedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, PlaylistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _coverPathMeta =
      const VerificationMeta('coverPath');
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
      'cover_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, coverPath, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('cover_path')) {
      context.handle(_coverPathMeta,
          coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      coverPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }
}

class PlaylistRow extends DataClass implements Insertable<PlaylistRow> {
  final int id;
  final String name;
  final String? description;
  final String? coverPath;
  final String createdAt;
  final String updatedAt;
  const PlaylistRow(
      {required this.id,
      required this.name,
      this.description,
      this.coverPath,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaylistRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'coverPath': serializer.toJson<String?>(coverPath),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  PlaylistRow copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> coverPath = const Value.absent(),
          String? createdAt,
          String? updatedAt}) =>
      PlaylistRow(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        coverPath: coverPath.present ? coverPath.value : this.coverPath,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PlaylistRow copyWithCompanion(PlaylistsCompanion data) {
    return PlaylistRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverPath: $coverPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, coverPath, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.coverPath == this.coverPath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlaylistsCompanion extends UpdateCompanion<PlaylistRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> coverPath;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.coverPath = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  })  : name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PlaylistRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? coverPath,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (coverPath != null) 'cover_path': coverPath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? coverPath,
      Value<String>? createdAt,
      Value<String>? updatedAt}) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPath: coverPath ?? this.coverPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverPath: $coverPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlaylistItemsTable extends PlaylistItems
    with TableInfo<$PlaylistItemsTable, PlaylistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES playlists (id) ON DELETE CASCADE'));
  static const VerificationMeta _mediaPathMeta =
      const VerificationMeta('mediaPath');
  @override
  late final GeneratedColumn<String> mediaPath = GeneratedColumn<String>(
      'media_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES media_items (path) ON DELETE CASCADE'));
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<String> addedAt = GeneratedColumn<String>(
      'added_at', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: Constant(''));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [playlistId, mediaPath, addedAt, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_items';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('media_path')) {
      context.handle(_mediaPathMeta,
          mediaPath.isAcceptableOrUnknown(data['media_path']!, _mediaPathMeta));
    } else if (isInserting) {
      context.missing(_mediaPathMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, mediaPath};
  @override
  PlaylistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistItem(
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}playlist_id'])!,
      mediaPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}media_path'])!,
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}added_at'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $PlaylistItemsTable createAlias(String alias) {
    return $PlaylistItemsTable(attachedDatabase, alias);
  }
}

class PlaylistItem extends DataClass implements Insertable<PlaylistItem> {
  final int playlistId;
  final String mediaPath;
  final String addedAt;
  final int sortOrder;
  const PlaylistItem(
      {required this.playlistId,
      required this.mediaPath,
      required this.addedAt,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<int>(playlistId);
    map['media_path'] = Variable<String>(mediaPath);
    map['added_at'] = Variable<String>(addedAt);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PlaylistItemsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistItemsCompanion(
      playlistId: Value(playlistId),
      mediaPath: Value(mediaPath),
      addedAt: Value(addedAt),
      sortOrder: Value(sortOrder),
    );
  }

  factory PlaylistItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistItem(
      playlistId: serializer.fromJson<int>(json['playlistId']),
      mediaPath: serializer.fromJson<String>(json['mediaPath']),
      addedAt: serializer.fromJson<String>(json['addedAt']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<int>(playlistId),
      'mediaPath': serializer.toJson<String>(mediaPath),
      'addedAt': serializer.toJson<String>(addedAt),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PlaylistItem copyWith(
          {int? playlistId,
          String? mediaPath,
          String? addedAt,
          int? sortOrder}) =>
      PlaylistItem(
        playlistId: playlistId ?? this.playlistId,
        mediaPath: mediaPath ?? this.mediaPath,
        addedAt: addedAt ?? this.addedAt,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  PlaylistItem copyWithCompanion(PlaylistItemsCompanion data) {
    return PlaylistItem(
      playlistId:
          data.playlistId.present ? data.playlistId.value : this.playlistId,
      mediaPath: data.mediaPath.present ? data.mediaPath.value : this.mediaPath,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItem(')
          ..write('playlistId: $playlistId, ')
          ..write('mediaPath: $mediaPath, ')
          ..write('addedAt: $addedAt, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(playlistId, mediaPath, addedAt, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistItem &&
          other.playlistId == this.playlistId &&
          other.mediaPath == this.mediaPath &&
          other.addedAt == this.addedAt &&
          other.sortOrder == this.sortOrder);
}

class PlaylistItemsCompanion extends UpdateCompanion<PlaylistItem> {
  final Value<int> playlistId;
  final Value<String> mediaPath;
  final Value<String> addedAt;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PlaylistItemsCompanion({
    this.playlistId = const Value.absent(),
    this.mediaPath = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistItemsCompanion.insert({
    required int playlistId,
    required String mediaPath,
    this.addedAt = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : playlistId = Value(playlistId),
        mediaPath = Value(mediaPath);
  static Insertable<PlaylistItem> custom({
    Expression<int>? playlistId,
    Expression<String>? mediaPath,
    Expression<String>? addedAt,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (mediaPath != null) 'media_path': mediaPath,
      if (addedAt != null) 'added_at': addedAt,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistItemsCompanion copyWith(
      {Value<int>? playlistId,
      Value<String>? mediaPath,
      Value<String>? addedAt,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return PlaylistItemsCompanion(
      playlistId: playlistId ?? this.playlistId,
      mediaPath: mediaPath ?? this.mediaPath,
      addedAt: addedAt ?? this.addedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (mediaPath.present) {
      map['media_path'] = Variable<String>(mediaPath.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<String>(addedAt.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItemsCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('mediaPath: $mediaPath, ')
          ..write('addedAt: $addedAt, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScanFoldersTable extends ScanFolders
    with TableInfo<$ScanFoldersTable, ScanFolder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanFoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recursiveMeta =
      const VerificationMeta('recursive');
  @override
  late final GeneratedColumn<int> recursive = GeneratedColumn<int>(
      'recursive', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _lastScannedMeta =
      const VerificationMeta('lastScanned');
  @override
  late final GeneratedColumn<String> lastScanned = GeneratedColumn<String>(
      'last_scanned', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [path, recursive, lastScanned];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_folders';
  @override
  VerificationContext validateIntegrity(Insertable<ScanFolder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('recursive')) {
      context.handle(_recursiveMeta,
          recursive.isAcceptableOrUnknown(data['recursive']!, _recursiveMeta));
    }
    if (data.containsKey('last_scanned')) {
      context.handle(
          _lastScannedMeta,
          lastScanned.isAcceptableOrUnknown(
              data['last_scanned']!, _lastScannedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {path};
  @override
  ScanFolder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanFolder(
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
      recursive: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}recursive'])!,
      lastScanned: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_scanned']),
    );
  }

  @override
  $ScanFoldersTable createAlias(String alias) {
    return $ScanFoldersTable(attachedDatabase, alias);
  }
}

class ScanFolder extends DataClass implements Insertable<ScanFolder> {
  final String path;
  final int recursive;
  final String? lastScanned;
  const ScanFolder(
      {required this.path, required this.recursive, this.lastScanned});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['path'] = Variable<String>(path);
    map['recursive'] = Variable<int>(recursive);
    if (!nullToAbsent || lastScanned != null) {
      map['last_scanned'] = Variable<String>(lastScanned);
    }
    return map;
  }

  ScanFoldersCompanion toCompanion(bool nullToAbsent) {
    return ScanFoldersCompanion(
      path: Value(path),
      recursive: Value(recursive),
      lastScanned: lastScanned == null && nullToAbsent
          ? const Value.absent()
          : Value(lastScanned),
    );
  }

  factory ScanFolder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanFolder(
      path: serializer.fromJson<String>(json['path']),
      recursive: serializer.fromJson<int>(json['recursive']),
      lastScanned: serializer.fromJson<String?>(json['lastScanned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'path': serializer.toJson<String>(path),
      'recursive': serializer.toJson<int>(recursive),
      'lastScanned': serializer.toJson<String?>(lastScanned),
    };
  }

  ScanFolder copyWith(
          {String? path,
          int? recursive,
          Value<String?> lastScanned = const Value.absent()}) =>
      ScanFolder(
        path: path ?? this.path,
        recursive: recursive ?? this.recursive,
        lastScanned: lastScanned.present ? lastScanned.value : this.lastScanned,
      );
  ScanFolder copyWithCompanion(ScanFoldersCompanion data) {
    return ScanFolder(
      path: data.path.present ? data.path.value : this.path,
      recursive: data.recursive.present ? data.recursive.value : this.recursive,
      lastScanned:
          data.lastScanned.present ? data.lastScanned.value : this.lastScanned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanFolder(')
          ..write('path: $path, ')
          ..write('recursive: $recursive, ')
          ..write('lastScanned: $lastScanned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(path, recursive, lastScanned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanFolder &&
          other.path == this.path &&
          other.recursive == this.recursive &&
          other.lastScanned == this.lastScanned);
}

class ScanFoldersCompanion extends UpdateCompanion<ScanFolder> {
  final Value<String> path;
  final Value<int> recursive;
  final Value<String?> lastScanned;
  final Value<int> rowid;
  const ScanFoldersCompanion({
    this.path = const Value.absent(),
    this.recursive = const Value.absent(),
    this.lastScanned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScanFoldersCompanion.insert({
    required String path,
    this.recursive = const Value.absent(),
    this.lastScanned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : path = Value(path);
  static Insertable<ScanFolder> custom({
    Expression<String>? path,
    Expression<int>? recursive,
    Expression<String>? lastScanned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (recursive != null) 'recursive': recursive,
      if (lastScanned != null) 'last_scanned': lastScanned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScanFoldersCompanion copyWith(
      {Value<String>? path,
      Value<int>? recursive,
      Value<String?>? lastScanned,
      Value<int>? rowid}) {
    return ScanFoldersCompanion(
      path: path ?? this.path,
      recursive: recursive ?? this.recursive,
      lastScanned: lastScanned ?? this.lastScanned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (recursive.present) {
      map['recursive'] = Variable<int>(recursive.value);
    }
    if (lastScanned.present) {
      map['last_scanned'] = Variable<String>(lastScanned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanFoldersCompanion(')
          ..write('path: $path, ')
          ..write('recursive: $recursive, ')
          ..write('lastScanned: $lastScanned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $MediaTagsTable mediaTags = $MediaTagsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $CollectionItemsTable collectionItems =
      $CollectionItemsTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistItemsTable playlistItems = $PlaylistItemsTable(this);
  late final $ScanFoldersTable scanFolders = $ScanFoldersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        mediaItems,
        tags,
        mediaTags,
        collections,
        collectionItems,
        playlists,
        playlistItems,
        scanFolders
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('media_items',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('media_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tags',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('media_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('collections',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('collection_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('media_items',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('collection_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('playlists',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('playlist_items', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('media_items',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('playlist_items', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$MediaItemsTableCreateCompanionBuilder = MediaItemsCompanion Function({
  required String path,
  required String name,
  required String type,
  Value<int> size,
  required String modified,
  Value<String?> title,
  Value<String?> artist,
  Value<String?> album,
  Value<int?> durationMs,
  Value<String?> artworkPath,
  Value<int> isFavorite,
  required String folderPath,
  Value<String> scannedAt,
  Value<int> rowid,
});
typedef $$MediaItemsTableUpdateCompanionBuilder = MediaItemsCompanion Function({
  Value<String> path,
  Value<String> name,
  Value<String> type,
  Value<int> size,
  Value<String> modified,
  Value<String?> title,
  Value<String?> artist,
  Value<String?> album,
  Value<int?> durationMs,
  Value<String?> artworkPath,
  Value<int> isFavorite,
  Value<String> folderPath,
  Value<String> scannedAt,
  Value<int> rowid,
});

final class $$MediaItemsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItemRow> {
  $$MediaItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MediaTagsTable, List<MediaTag>>
      _mediaTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.mediaTags,
              aliasName: 'media_items__path__media_tags__media_path');

  $$MediaTagsTableProcessedTableManager get mediaTagsRefs {
    final manager = $$MediaTagsTableTableManager($_db, $_db.mediaTags).filter(
        (f) => f.mediaPath.path.sqlEquals($_itemColumn<String>('path')!));

    final cache = $_typedResult.readTableOrNull(_mediaTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CollectionItemsTable, List<CollectionItem>>
      _collectionItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.collectionItems,
              aliasName: 'media_items__path__collection_items__media_path');

  $$CollectionItemsTableProcessedTableManager get collectionItemsRefs {
    final manager =
        $$CollectionItemsTableTableManager($_db, $_db.collectionItems).filter(
            (f) => f.mediaPath.path.sqlEquals($_itemColumn<String>('path')!));

    final cache =
        $_typedResult.readTableOrNull(_collectionItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PlaylistItemsTable, List<PlaylistItem>>
      _playlistItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.playlistItems,
              aliasName: 'media_items__path__playlist_items__media_path');

  $$PlaylistItemsTableProcessedTableManager get playlistItemsRefs {
    final manager = $$PlaylistItemsTableTableManager($_db, $_db.playlistItems)
        .filter(
            (f) => f.mediaPath.path.sqlEquals($_itemColumn<String>('path')!));

    final cache = $_typedResult.readTableOrNull(_playlistItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modified => $composableBuilder(
      column: $table.modified, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artist => $composableBuilder(
      column: $table.artist, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get album => $composableBuilder(
      column: $table.album, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artworkPath => $composableBuilder(
      column: $table.artworkPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get folderPath => $composableBuilder(
      column: $table.folderPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scannedAt => $composableBuilder(
      column: $table.scannedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> mediaTagsRefs(
      Expression<bool> Function($$MediaTagsTableFilterComposer f) f) {
    final $$MediaTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.path,
        referencedTable: $db.mediaTags,
        getReferencedColumn: (t) => t.mediaPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaTagsTableFilterComposer(
              $db: $db,
              $table: $db.mediaTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> collectionItemsRefs(
      Expression<bool> Function($$CollectionItemsTableFilterComposer f) f) {
    final $$CollectionItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.path,
        referencedTable: $db.collectionItems,
        getReferencedColumn: (t) => t.mediaPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionItemsTableFilterComposer(
              $db: $db,
              $table: $db.collectionItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> playlistItemsRefs(
      Expression<bool> Function($$PlaylistItemsTableFilterComposer f) f) {
    final $$PlaylistItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.path,
        referencedTable: $db.playlistItems,
        getReferencedColumn: (t) => t.mediaPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistItemsTableFilterComposer(
              $db: $db,
              $table: $db.playlistItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get size => $composableBuilder(
      column: $table.size, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modified => $composableBuilder(
      column: $table.modified, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artist => $composableBuilder(
      column: $table.artist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get album => $composableBuilder(
      column: $table.album, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artworkPath => $composableBuilder(
      column: $table.artworkPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get folderPath => $composableBuilder(
      column: $table.folderPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scannedAt => $composableBuilder(
      column: $table.scannedAt, builder: (column) => ColumnOrderings(column));
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get artworkPath => $composableBuilder(
      column: $table.artworkPath, builder: (column) => column);

  GeneratedColumn<int> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<String> get folderPath => $composableBuilder(
      column: $table.folderPath, builder: (column) => column);

  GeneratedColumn<String> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);

  Expression<T> mediaTagsRefs<T extends Object>(
      Expression<T> Function($$MediaTagsTableAnnotationComposer a) f) {
    final $$MediaTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.path,
        referencedTable: $db.mediaTags,
        getReferencedColumn: (t) => t.mediaPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.mediaTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> collectionItemsRefs<T extends Object>(
      Expression<T> Function($$CollectionItemsTableAnnotationComposer a) f) {
    final $$CollectionItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.path,
        referencedTable: $db.collectionItems,
        getReferencedColumn: (t) => t.mediaPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.collectionItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> playlistItemsRefs<T extends Object>(
      Expression<T> Function($$PlaylistItemsTableAnnotationComposer a) f) {
    final $$PlaylistItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.path,
        referencedTable: $db.playlistItems,
        getReferencedColumn: (t) => t.mediaPath,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlistItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MediaItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MediaItemsTable,
    MediaItemRow,
    $$MediaItemsTableFilterComposer,
    $$MediaItemsTableOrderingComposer,
    $$MediaItemsTableAnnotationComposer,
    $$MediaItemsTableCreateCompanionBuilder,
    $$MediaItemsTableUpdateCompanionBuilder,
    (MediaItemRow, $$MediaItemsTableReferences),
    MediaItemRow,
    PrefetchHooks Function(
        {bool mediaTagsRefs,
        bool collectionItemsRefs,
        bool playlistItemsRefs})> {
  $$MediaItemsTableTableManager(_$AppDatabase db, $MediaItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> path = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> size = const Value.absent(),
            Value<String> modified = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String?> artist = const Value.absent(),
            Value<String?> album = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<String?> artworkPath = const Value.absent(),
            Value<int> isFavorite = const Value.absent(),
            Value<String> folderPath = const Value.absent(),
            Value<String> scannedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaItemsCompanion(
            path: path,
            name: name,
            type: type,
            size: size,
            modified: modified,
            title: title,
            artist: artist,
            album: album,
            durationMs: durationMs,
            artworkPath: artworkPath,
            isFavorite: isFavorite,
            folderPath: folderPath,
            scannedAt: scannedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String path,
            required String name,
            required String type,
            Value<int> size = const Value.absent(),
            required String modified,
            Value<String?> title = const Value.absent(),
            Value<String?> artist = const Value.absent(),
            Value<String?> album = const Value.absent(),
            Value<int?> durationMs = const Value.absent(),
            Value<String?> artworkPath = const Value.absent(),
            Value<int> isFavorite = const Value.absent(),
            required String folderPath,
            Value<String> scannedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaItemsCompanion.insert(
            path: path,
            name: name,
            type: type,
            size: size,
            modified: modified,
            title: title,
            artist: artist,
            album: album,
            durationMs: durationMs,
            artworkPath: artworkPath,
            isFavorite: isFavorite,
            folderPath: folderPath,
            scannedAt: scannedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MediaItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {mediaTagsRefs = false,
              collectionItemsRefs = false,
              playlistItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (mediaTagsRefs) db.mediaTags,
                if (collectionItemsRefs) db.collectionItems,
                if (playlistItemsRefs) db.playlistItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mediaTagsRefs)
                    await $_getPrefetchedData<MediaItemRow, $MediaItemsTable,
                            MediaTag>(
                        currentTable: table,
                        referencedTable:
                            $$MediaItemsTableReferences._mediaTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MediaItemsTableReferences(db, table, p0)
                                .mediaTagsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mediaPath == item.path),
                        typedResults: items),
                  if (collectionItemsRefs)
                    await $_getPrefetchedData<MediaItemRow, $MediaItemsTable,
                            CollectionItem>(
                        currentTable: table,
                        referencedTable: $$MediaItemsTableReferences
                            ._collectionItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MediaItemsTableReferences(db, table, p0)
                                .collectionItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mediaPath == item.path),
                        typedResults: items),
                  if (playlistItemsRefs)
                    await $_getPrefetchedData<MediaItemRow, $MediaItemsTable,
                            PlaylistItem>(
                        currentTable: table,
                        referencedTable: $$MediaItemsTableReferences
                            ._playlistItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MediaItemsTableReferences(db, table, p0)
                                .playlistItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mediaPath == item.path),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MediaItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MediaItemsTable,
    MediaItemRow,
    $$MediaItemsTableFilterComposer,
    $$MediaItemsTableOrderingComposer,
    $$MediaItemsTableAnnotationComposer,
    $$MediaItemsTableCreateCompanionBuilder,
    $$MediaItemsTableUpdateCompanionBuilder,
    (MediaItemRow, $$MediaItemsTableReferences),
    MediaItemRow,
    PrefetchHooks Function(
        {bool mediaTagsRefs,
        bool collectionItemsRefs,
        bool playlistItemsRefs})>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
  Value<int> color,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> color,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MediaTagsTable, List<MediaTag>>
      _mediaTagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.mediaTags,
              aliasName: 'tags__id__media_tags__tag_id');

  $$MediaTagsTableProcessedTableManager get mediaTagsRefs {
    final manager = $$MediaTagsTableTableManager($_db, $_db.mediaTags)
        .filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  Expression<bool> mediaTagsRefs(
      Expression<bool> Function($$MediaTagsTableFilterComposer f) f) {
    final $$MediaTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mediaTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaTagsTableFilterComposer(
              $db: $db,
              $table: $db.mediaTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> mediaTagsRefs<T extends Object>(
      Expression<T> Function($$MediaTagsTableAnnotationComposer a) f) {
    final $$MediaTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mediaTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.mediaTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    TagRow,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagRow, $$TagsTableReferences),
    TagRow,
    PrefetchHooks Function({bool mediaTagsRefs})> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> color = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            color: color,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> color = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            color: color,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({mediaTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (mediaTagsRefs) db.mediaTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mediaTagsRefs)
                    await $_getPrefetchedData<TagRow, $TagsTable, MediaTag>(
                        currentTable: table,
                        referencedTable:
                            $$TagsTableReferences._mediaTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0).mediaTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    TagRow,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (TagRow, $$TagsTableReferences),
    TagRow,
    PrefetchHooks Function({bool mediaTagsRefs})>;
typedef $$MediaTagsTableCreateCompanionBuilder = MediaTagsCompanion Function({
  required String mediaPath,
  required int tagId,
  Value<int> rowid,
});
typedef $$MediaTagsTableUpdateCompanionBuilder = MediaTagsCompanion Function({
  Value<String> mediaPath,
  Value<int> tagId,
  Value<int> rowid,
});

final class $$MediaTagsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaTagsTable, MediaTag> {
  $$MediaTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MediaItemsTable _mediaPathTable(_$AppDatabase db) =>
      db.mediaItems.createAlias('media_tags__media_path__media_items__path');

  $$MediaItemsTableProcessedTableManager get mediaPath {
    final $_column = $_itemColumn<String>('media_path')!;

    final manager = $$MediaItemsTableTableManager($_db, $_db.mediaItems)
        .filter((f) => f.path.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaPathTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('media_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MediaTagsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaTagsTable> {
  $$MediaTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MediaItemsTableFilterComposer get mediaPath {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaPath,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.path,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableFilterComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableFilterComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MediaTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaTagsTable> {
  $$MediaTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MediaItemsTableOrderingComposer get mediaPath {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaPath,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.path,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableOrderingComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableOrderingComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MediaTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaTagsTable> {
  $$MediaTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$MediaItemsTableAnnotationComposer get mediaPath {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaPath,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.path,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableAnnotationComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MediaTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MediaTagsTable,
    MediaTag,
    $$MediaTagsTableFilterComposer,
    $$MediaTagsTableOrderingComposer,
    $$MediaTagsTableAnnotationComposer,
    $$MediaTagsTableCreateCompanionBuilder,
    $$MediaTagsTableUpdateCompanionBuilder,
    (MediaTag, $$MediaTagsTableReferences),
    MediaTag,
    PrefetchHooks Function({bool mediaPath, bool tagId})> {
  $$MediaTagsTableTableManager(_$AppDatabase db, $MediaTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> mediaPath = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaTagsCompanion(
            mediaPath: mediaPath,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String mediaPath,
            required int tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaTagsCompanion.insert(
            mediaPath: mediaPath,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MediaTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mediaPath = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (mediaPath) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mediaPath,
                    referencedTable:
                        $$MediaTagsTableReferences._mediaPathTable(db),
                    referencedColumn:
                        $$MediaTagsTableReferences._mediaPathTable(db).path,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable: $$MediaTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$MediaTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MediaTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MediaTagsTable,
    MediaTag,
    $$MediaTagsTableFilterComposer,
    $$MediaTagsTableOrderingComposer,
    $$MediaTagsTableAnnotationComposer,
    $$MediaTagsTableCreateCompanionBuilder,
    $$MediaTagsTableUpdateCompanionBuilder,
    (MediaTag, $$MediaTagsTableReferences),
    MediaTag,
    PrefetchHooks Function({bool mediaPath, bool tagId})>;
typedef $$CollectionsTableCreateCompanionBuilder = CollectionsCompanion
    Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  Value<String?> coverPath,
  required String createdAt,
  required String updatedAt,
});
typedef $$CollectionsTableUpdateCompanionBuilder = CollectionsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> coverPath,
  Value<String> createdAt,
  Value<String> updatedAt,
});

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CollectionItemsTable, List<CollectionItem>>
      _collectionItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.collectionItems,
              aliasName: 'collections__id__collection_items__collection_id');

  $$CollectionItemsTableProcessedTableManager get collectionItemsRefs {
    final manager = $$CollectionItemsTableTableManager(
            $_db, $_db.collectionItems)
        .filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_collectionItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> collectionItemsRefs(
      Expression<bool> Function($$CollectionItemsTableFilterComposer f) f) {
    final $$CollectionItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.collectionItems,
        getReferencedColumn: (t) => t.collectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionItemsTableFilterComposer(
              $db: $db,
              $table: $db.collectionItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> collectionItemsRefs<T extends Object>(
      Expression<T> Function($$CollectionItemsTableAnnotationComposer a) f) {
    final $$CollectionItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.collectionItems,
        getReferencedColumn: (t) => t.collectionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.collectionItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CollectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CollectionsTable,
    CollectionRow,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (CollectionRow, $$CollectionsTableReferences),
    CollectionRow,
    PrefetchHooks Function({bool collectionItemsRefs})> {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
          }) =>
              CollectionsCompanion(
            id: id,
            name: name,
            description: description,
            coverPath: coverPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            required String createdAt,
            required String updatedAt,
          }) =>
              CollectionsCompanion.insert(
            id: id,
            name: name,
            description: description,
            coverPath: coverPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CollectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({collectionItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (collectionItemsRefs) db.collectionItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (collectionItemsRefs)
                    await $_getPrefetchedData<CollectionRow, $CollectionsTable,
                            CollectionItem>(
                        currentTable: table,
                        referencedTable: $$CollectionsTableReferences
                            ._collectionItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CollectionsTableReferences(db, table, p0)
                                .collectionItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.collectionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CollectionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CollectionsTable,
    CollectionRow,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (CollectionRow, $$CollectionsTableReferences),
    CollectionRow,
    PrefetchHooks Function({bool collectionItemsRefs})>;
typedef $$CollectionItemsTableCreateCompanionBuilder = CollectionItemsCompanion
    Function({
  required int collectionId,
  required String mediaPath,
  Value<String> addedAt,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$CollectionItemsTableUpdateCompanionBuilder = CollectionItemsCompanion
    Function({
  Value<int> collectionId,
  Value<String> mediaPath,
  Value<String> addedAt,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$CollectionItemsTableReferences extends BaseReferences<
    _$AppDatabase, $CollectionItemsTable, CollectionItem> {
  $$CollectionItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections
          .createAlias('collection_items__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $$CollectionsTableTableManager($_db, $_db.collections)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MediaItemsTable _mediaPathTable(_$AppDatabase db) => db.mediaItems
      .createAlias('collection_items__media_path__media_items__path');

  $$MediaItemsTableProcessedTableManager get mediaPath {
    final $_column = $_itemColumn<String>('media_path')!;

    final manager = $$MediaItemsTableTableManager($_db, $_db.mediaItems)
        .filter((f) => f.path.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaPathTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CollectionItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableFilterComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaItemsTableFilterComposer get mediaPath {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaPath,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.path,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableFilterComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CollectionItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableOrderingComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaItemsTableOrderingComposer get mediaPath {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaPath,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.path,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableOrderingComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CollectionItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionItemsTable> {
  $$CollectionItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaItemsTableAnnotationComposer get mediaPath {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaPath,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.path,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CollectionItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CollectionItemsTable,
    CollectionItem,
    $$CollectionItemsTableFilterComposer,
    $$CollectionItemsTableOrderingComposer,
    $$CollectionItemsTableAnnotationComposer,
    $$CollectionItemsTableCreateCompanionBuilder,
    $$CollectionItemsTableUpdateCompanionBuilder,
    (CollectionItem, $$CollectionItemsTableReferences),
    CollectionItem,
    PrefetchHooks Function({bool collectionId, bool mediaPath})> {
  $$CollectionItemsTableTableManager(
      _$AppDatabase db, $CollectionItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> collectionId = const Value.absent(),
            Value<String> mediaPath = const Value.absent(),
            Value<String> addedAt = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CollectionItemsCompanion(
            collectionId: collectionId,
            mediaPath: mediaPath,
            addedAt: addedAt,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int collectionId,
            required String mediaPath,
            Value<String> addedAt = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CollectionItemsCompanion.insert(
            collectionId: collectionId,
            mediaPath: mediaPath,
            addedAt: addedAt,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CollectionItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({collectionId = false, mediaPath = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (collectionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.collectionId,
                    referencedTable:
                        $$CollectionItemsTableReferences._collectionIdTable(db),
                    referencedColumn: $$CollectionItemsTableReferences
                        ._collectionIdTable(db)
                        .id,
                  ) as T;
                }
                if (mediaPath) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mediaPath,
                    referencedTable:
                        $$CollectionItemsTableReferences._mediaPathTable(db),
                    referencedColumn: $$CollectionItemsTableReferences
                        ._mediaPathTable(db)
                        .path,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CollectionItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CollectionItemsTable,
    CollectionItem,
    $$CollectionItemsTableFilterComposer,
    $$CollectionItemsTableOrderingComposer,
    $$CollectionItemsTableAnnotationComposer,
    $$CollectionItemsTableCreateCompanionBuilder,
    $$CollectionItemsTableUpdateCompanionBuilder,
    (CollectionItem, $$CollectionItemsTableReferences),
    CollectionItem,
    PrefetchHooks Function({bool collectionId, bool mediaPath})>;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  Value<String?> coverPath,
  required String createdAt,
  required String updatedAt,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> coverPath,
  Value<String> createdAt,
  Value<String> updatedAt,
});

final class $$PlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistsTable, PlaylistRow> {
  $$PlaylistsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistItemsTable, List<PlaylistItem>>
      _playlistItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.playlistItems,
              aliasName: 'playlists__id__playlist_items__playlist_id');

  $$PlaylistItemsTableProcessedTableManager get playlistItemsRefs {
    final manager = $$PlaylistItemsTableTableManager($_db, $_db.playlistItems)
        .filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> playlistItemsRefs(
      Expression<bool> Function($$PlaylistItemsTableFilterComposer f) f) {
    final $$PlaylistItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playlistItems,
        getReferencedColumn: (t) => t.playlistId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistItemsTableFilterComposer(
              $db: $db,
              $table: $db.playlistItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> playlistItemsRefs<T extends Object>(
      Expression<T> Function($$PlaylistItemsTableAnnotationComposer a) f) {
    final $$PlaylistItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.playlistItems,
        getReferencedColumn: (t) => t.playlistId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlistItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlaylistsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    PlaylistRow,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (PlaylistRow, $$PlaylistsTableReferences),
    PlaylistRow,
    PrefetchHooks Function({bool playlistItemsRefs})> {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
          }) =>
              PlaylistsCompanion(
            id: id,
            name: name,
            description: description,
            coverPath: coverPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            required String createdAt,
            required String updatedAt,
          }) =>
              PlaylistsCompanion.insert(
            id: id,
            name: name,
            description: description,
            coverPath: coverPath,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlaylistsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({playlistItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistItemsRefs) db.playlistItems
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistItemsRefs)
                    await $_getPrefetchedData<PlaylistRow, $PlaylistsTable,
                            PlaylistItem>(
                        currentTable: table,
                        referencedTable: $$PlaylistsTableReferences
                            ._playlistItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlaylistsTableReferences(db, table, p0)
                                .playlistItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.playlistId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlaylistsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    PlaylistRow,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (PlaylistRow, $$PlaylistsTableReferences),
    PlaylistRow,
    PrefetchHooks Function({bool playlistItemsRefs})>;
typedef $$PlaylistItemsTableCreateCompanionBuilder = PlaylistItemsCompanion
    Function({
  required int playlistId,
  required String mediaPath,
  Value<String> addedAt,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$PlaylistItemsTableUpdateCompanionBuilder = PlaylistItemsCompanion
    Function({
  Value<int> playlistId,
  Value<String> mediaPath,
  Value<String> addedAt,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$PlaylistItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PlaylistItemsTable, PlaylistItem> {
  $$PlaylistItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.playlists.createAlias('playlist_items__playlist_id__playlists__id');

  $$PlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$PlaylistsTableTableManager($_db, $_db.playlists)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MediaItemsTable _mediaPathTable(_$AppDatabase db) => db.mediaItems
      .createAlias('playlist_items__media_path__media_items__path');

  $$MediaItemsTableProcessedTableManager get mediaPath {
    final $_column = $_itemColumn<String>('media_path')!;

    final manager = $$MediaItemsTableTableManager($_db, $_db.mediaItems)
        .filter((f) => f.path.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaPathTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlaylistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$PlaylistsTableFilterComposer get playlistId {
    final $$PlaylistsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playlistId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableFilterComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaItemsTableFilterComposer get mediaPath {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaPath,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.path,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableFilterComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaylistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$PlaylistsTableOrderingComposer get playlistId {
    final $$PlaylistsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playlistId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableOrderingComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaItemsTableOrderingComposer get mediaPath {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaPath,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.path,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableOrderingComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaylistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$PlaylistsTableAnnotationComposer get playlistId {
    final $$PlaylistsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.playlistId,
        referencedTable: $db.playlists,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlaylistsTableAnnotationComposer(
              $db: $db,
              $table: $db.playlists,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$MediaItemsTableAnnotationComposer get mediaPath {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mediaPath,
        referencedTable: $db.mediaItems,
        getReferencedColumn: (t) => t.path,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MediaItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.mediaItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlaylistItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistItemsTable,
    PlaylistItem,
    $$PlaylistItemsTableFilterComposer,
    $$PlaylistItemsTableOrderingComposer,
    $$PlaylistItemsTableAnnotationComposer,
    $$PlaylistItemsTableCreateCompanionBuilder,
    $$PlaylistItemsTableUpdateCompanionBuilder,
    (PlaylistItem, $$PlaylistItemsTableReferences),
    PlaylistItem,
    PrefetchHooks Function({bool playlistId, bool mediaPath})> {
  $$PlaylistItemsTableTableManager(_$AppDatabase db, $PlaylistItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> playlistId = const Value.absent(),
            Value<String> mediaPath = const Value.absent(),
            Value<String> addedAt = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistItemsCompanion(
            playlistId: playlistId,
            mediaPath: mediaPath,
            addedAt: addedAt,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int playlistId,
            required String mediaPath,
            Value<String> addedAt = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistItemsCompanion.insert(
            playlistId: playlistId,
            mediaPath: mediaPath,
            addedAt: addedAt,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlaylistItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({playlistId = false, mediaPath = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (playlistId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.playlistId,
                    referencedTable:
                        $$PlaylistItemsTableReferences._playlistIdTable(db),
                    referencedColumn:
                        $$PlaylistItemsTableReferences._playlistIdTable(db).id,
                  ) as T;
                }
                if (mediaPath) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mediaPath,
                    referencedTable:
                        $$PlaylistItemsTableReferences._mediaPathTable(db),
                    referencedColumn:
                        $$PlaylistItemsTableReferences._mediaPathTable(db).path,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlaylistItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistItemsTable,
    PlaylistItem,
    $$PlaylistItemsTableFilterComposer,
    $$PlaylistItemsTableOrderingComposer,
    $$PlaylistItemsTableAnnotationComposer,
    $$PlaylistItemsTableCreateCompanionBuilder,
    $$PlaylistItemsTableUpdateCompanionBuilder,
    (PlaylistItem, $$PlaylistItemsTableReferences),
    PlaylistItem,
    PrefetchHooks Function({bool playlistId, bool mediaPath})>;
typedef $$ScanFoldersTableCreateCompanionBuilder = ScanFoldersCompanion
    Function({
  required String path,
  Value<int> recursive,
  Value<String?> lastScanned,
  Value<int> rowid,
});
typedef $$ScanFoldersTableUpdateCompanionBuilder = ScanFoldersCompanion
    Function({
  Value<String> path,
  Value<int> recursive,
  Value<String?> lastScanned,
  Value<int> rowid,
});

class $$ScanFoldersTableFilterComposer
    extends Composer<_$AppDatabase, $ScanFoldersTable> {
  $$ScanFoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get recursive => $composableBuilder(
      column: $table.recursive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastScanned => $composableBuilder(
      column: $table.lastScanned, builder: (column) => ColumnFilters(column));
}

class $$ScanFoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanFoldersTable> {
  $$ScanFoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get recursive => $composableBuilder(
      column: $table.recursive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastScanned => $composableBuilder(
      column: $table.lastScanned, builder: (column) => ColumnOrderings(column));
}

class $$ScanFoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanFoldersTable> {
  $$ScanFoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get recursive =>
      $composableBuilder(column: $table.recursive, builder: (column) => column);

  GeneratedColumn<String> get lastScanned => $composableBuilder(
      column: $table.lastScanned, builder: (column) => column);
}

class $$ScanFoldersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScanFoldersTable,
    ScanFolder,
    $$ScanFoldersTableFilterComposer,
    $$ScanFoldersTableOrderingComposer,
    $$ScanFoldersTableAnnotationComposer,
    $$ScanFoldersTableCreateCompanionBuilder,
    $$ScanFoldersTableUpdateCompanionBuilder,
    (ScanFolder, BaseReferences<_$AppDatabase, $ScanFoldersTable, ScanFolder>),
    ScanFolder,
    PrefetchHooks Function()> {
  $$ScanFoldersTableTableManager(_$AppDatabase db, $ScanFoldersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanFoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanFoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanFoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> path = const Value.absent(),
            Value<int> recursive = const Value.absent(),
            Value<String?> lastScanned = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScanFoldersCompanion(
            path: path,
            recursive: recursive,
            lastScanned: lastScanned,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String path,
            Value<int> recursive = const Value.absent(),
            Value<String?> lastScanned = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScanFoldersCompanion.insert(
            path: path,
            recursive: recursive,
            lastScanned: lastScanned,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ScanFoldersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScanFoldersTable,
    ScanFolder,
    $$ScanFoldersTableFilterComposer,
    $$ScanFoldersTableOrderingComposer,
    $$ScanFoldersTableAnnotationComposer,
    $$ScanFoldersTableCreateCompanionBuilder,
    $$ScanFoldersTableUpdateCompanionBuilder,
    (ScanFolder, BaseReferences<_$AppDatabase, $ScanFoldersTable, ScanFolder>),
    ScanFolder,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$MediaTagsTableTableManager get mediaTags =>
      $$MediaTagsTableTableManager(_db, _db.mediaTags);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$CollectionItemsTableTableManager get collectionItems =>
      $$CollectionItemsTableTableManager(_db, _db.collectionItems);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistItemsTableTableManager get playlistItems =>
      $$PlaylistItemsTableTableManager(_db, _db.playlistItems);
  $$ScanFoldersTableTableManager get scanFolders =>
      $$ScanFoldersTableTableManager(_db, _db.scanFolders);
}
