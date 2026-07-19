import 'dart:io';

import 'media_type.dart';

/// A single media file discovered on disk.
class MediaItem {
  final String path;
  final String name;
  final MediaType type;
  final int size;
  final DateTime modified;

  /// Audio metadata, filled in after scanning (null until then / for non-audio).
  final String? title;
  final String? artist;
  final String? album;
  final int? durationMs;

  /// Cached embedded cover-art image path (audio only), if artwork exists.
  final String? artworkPath;

  /// Whether the user has marked this item as a favourite.
  final bool isFavorite;

  const MediaItem({
    required this.path,
    required this.name,
    required this.type,
    required this.size,
    required this.modified,
    this.title,
    this.artist,
    this.album,
    this.durationMs,
    this.artworkPath,
    this.isFavorite = false,
  });

  /// The immediate parent directory path.
  String get folderPath {
    final normalized = path.replaceAll('\\', '/');
    final idx = normalized.lastIndexOf('/');
    return idx >= 0 ? normalized.substring(0, idx) : normalized;
  }

  /// The immediate parent directory name (used as "album" label).
  String get folderName {
    final fp = folderPath.replaceAll('\\', '/');
    final idx = fp.lastIndexOf('/');
    final n = idx >= 0 ? fp.substring(idx + 1) : fp;
    return n.isEmpty ? fp : n;
  }

  /// File extension without dot, lowercase.
  String get extension {
    final idx = name.lastIndexOf('.');
    return idx >= 0 ? name.substring(idx + 1).toLowerCase() : '';
  }

  File get file => File(path);

  /// Build a [MediaItem] from a [FileSystemEntity] path and its stat.
  /// Returns null if the extension is not a recognised media type.
  static MediaItem? fromPath(String filePath, {FileStat? stat}) {
    final normalized = filePath.replaceAll('\\', '/');
    final slash = normalized.lastIndexOf('/');
    final fileName = slash >= 0 ? normalized.substring(slash + 1) : normalized;
    final dot = fileName.lastIndexOf('.');
    if (dot < 0) return null;
    final ext = fileName.substring(dot + 1).toLowerCase();
    final type = _typeForExt(ext);
    if (type == null) return null;

    final s = stat ?? FileStat.statSync(filePath);
    return MediaItem(
      path: filePath,
      name: fileName,
      type: type,
      size: s.size < 0 ? 0 : s.size,
      modified: s.modified,
    );
  }

  /// Returns a copy with audio metadata filled in (used by the scanner).
  MediaItem copyWith({
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    String? artworkPath,
    bool? isFavorite,
    String? name,
    String? path,
  }) {
    return MediaItem(
      path: path ?? this.path,
      name: name ?? this.name,
      type: type,
      size: size,
      modified: modified,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      artworkPath: artworkPath ?? this.artworkPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  MediaItem withoutArtwork() => MediaItem(
        path: path,
        name: name,
        type: type,
        size: size,
        modified: modified,
        title: title,
        artist: artist,
        album: album,
        durationMs: durationMs,
        isFavorite: isFavorite,
      );

  static MediaType? _typeForExt(String ext) {
    const image = {
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'heic',
      'heif',
      'tiff',
      'tif',
      'ico',
    };
    const video = {
      'mp4',
      'mkv',
      'avi',
      'mov',
      'wmv',
      'flv',
      'webm',
      'm4v',
      'mpeg',
      'mpg',
      'ts',
      '3gp',
    };
    const audio = {
      'mp3',
      'flac',
      'wav',
      'aac',
      'm4a',
      'ogg',
      'wma',
      'opus',
      'aiff',
      'ape',
    };
    if (image.contains(ext)) return MediaType.image;
    if (video.contains(ext)) return MediaType.video;
    if (audio.contains(ext)) return MediaType.audio;
    return null;
  }

  /// Serialize this item to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'type': type.name,
        'size': size,
        'modified': modified.toIso8601String(),
        'title': title,
        'artist': artist,
        'album': album,
        'durationMs': durationMs,
        'artworkPath': artworkPath,
        'isFavorite': isFavorite,
      };

  /// Deserialize from a JSON map produced by [toJson].
  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        path: json['path'] as String,
        name: json['name'] as String,
        type: MediaType.values.byName(json['type'] as String),
        size: json['size'] as int,
        modified: DateTime.parse(json['modified'] as String),
        title: json['title'] as String?,
        artist: json['artist'] as String?,
        album: json['album'] as String?,
        durationMs: json['durationMs'] as int?,
        artworkPath: json['artworkPath'] as String?,
        isFavorite: (json['isFavorite'] as bool?) ?? false,
      );

  @override
  bool operator ==(Object other) => other is MediaItem && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
