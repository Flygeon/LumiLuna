import 'dart:io';

import 'media_type.dart';

/// A single media file discovered on disk.
class MediaItem {
  final String path;
  final String name;
  final MediaType type;
  final int size;
  final DateTime modified;
  final int? fileHash;

  /// Audio metadata, filled in after scanning (null until then / for non-audio).
  final String? title;
  final String? artist;
  final String? album;
  final int? durationMs;

  /// Cached embedded cover-art image path (audio only), if artwork exists.
  final String? artworkPath;

  /// Whether the user has marked this item as a favourite.
  final bool isFavorite;

  /// Thumbnail / preview image path (image/video).
  final String? thumbnailPath;

  /// Image dimensions (image types).
  final int? imageWidth;
  final int? imageHeight;

  /// Image EXIF date taken.
  final String? imageDateTaken;

  /// Image camera make/model (EXIF).
  final String? imageCameraMake;
  final String? imageCameraModel;

  /// Image GPS coordinates (EXIF).
  final double? imageGpsLat;
  final double? imageGpsLng;

  /// Image EXIF metadata.
  final int? imageIso;
  final double? imageFocalLength;
  final double? imageFNumber;

  /// Video resolution (video types).
  final int? videoWidth;
  final int? videoHeight;

  /// Video codec string (e.g. "h264").
  final String? videoCodec;

  /// Video framerate in frames-per-second.
  final double? videoFps;

  const MediaItem({
    required this.path,
    required this.name,
    required this.type,
    required this.size,
    required this.modified,
    this.fileHash,
    this.title,
    this.artist,
    this.album,
    this.durationMs,
    this.artworkPath,
    this.isFavorite = false,
    this.thumbnailPath,
    this.imageWidth,
    this.imageHeight,
    this.imageDateTaken,
    this.imageCameraMake,
    this.imageCameraModel,
    this.imageGpsLat,
    this.imageGpsLng,
    this.imageIso,
    this.imageFocalLength,
    this.imageFNumber,
    this.videoWidth,
    this.videoHeight,
    this.videoCodec,
    this.videoFps,
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

  /// Returns a copy with metadata filled in (used by the scanner).
  MediaItem copyWith({
    String? title,
    String? artist,
    String? album,
    int? durationMs,
    int? fileHash,
    String? artworkPath,
    bool? isFavorite,
    String? name,
    String? path,
    String? thumbnailPath,
    int? imageWidth,
    int? imageHeight,
    String? imageDateTaken,
    String? imageCameraMake,
    String? imageCameraModel,
    double? imageGpsLat,
    double? imageGpsLng,
    int? imageIso,
    double? imageFocalLength,
    double? imageFNumber,
    int? videoWidth,
    int? videoHeight,
    String? videoCodec,
    double? videoFps,
  }) {
    return MediaItem(
      path: path ?? this.path,
      name: name ?? this.name,
      type: type,
      size: size,
      modified: modified,
      fileHash: fileHash ?? this.fileHash,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      durationMs: durationMs ?? this.durationMs,
      artworkPath: artworkPath ?? this.artworkPath,
      isFavorite: isFavorite ?? this.isFavorite,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      imageDateTaken: imageDateTaken ?? this.imageDateTaken,
      imageCameraMake: imageCameraMake ?? this.imageCameraMake,
      imageCameraModel: imageCameraModel ?? this.imageCameraModel,
      imageGpsLat: imageGpsLat ?? this.imageGpsLat,
      imageGpsLng: imageGpsLng ?? this.imageGpsLng,
      imageIso: imageIso ?? this.imageIso,
      imageFocalLength: imageFocalLength ?? this.imageFocalLength,
      imageFNumber: imageFNumber ?? this.imageFNumber,
      videoWidth: videoWidth ?? this.videoWidth,
      videoHeight: videoHeight ?? this.videoHeight,
      videoCodec: videoCodec ?? this.videoCodec,
      videoFps: videoFps ?? this.videoFps,
    );
  }

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
        'fileHash': fileHash,
        'title': title,
        'artist': artist,
        'album': album,
        'durationMs': durationMs,
        'artworkPath': artworkPath,
        'isFavorite': isFavorite,
        'thumbnailPath': thumbnailPath,
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
        'imageDateTaken': imageDateTaken,
        'imageCameraMake': imageCameraMake,
        'imageCameraModel': imageCameraModel,
        'imageGpsLat': imageGpsLat,
        'imageGpsLng': imageGpsLng,
        'imageIso': imageIso,
        'imageFocalLength': imageFocalLength,
        'imageFNumber': imageFNumber,
        'videoWidth': videoWidth,
        'videoHeight': videoHeight,
        'videoCodec': videoCodec,
        'videoFps': videoFps,
      };

  /// Deserialize from a JSON map produced by [toJson].
  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        path: json['path'] as String,
        name: json['name'] as String,
        type: MediaType.values.byName(json['type'] as String),
        size: json['size'] as int,
        modified: DateTime.parse(json['modified'] as String),
        fileHash: json['fileHash'] as int?,
        title: json['title'] as String?,
        artist: json['artist'] as String?,
        album: json['album'] as String?,
        durationMs: json['durationMs'] as int?,
        artworkPath: json['artworkPath'] as String?,
        isFavorite: (json['isFavorite'] as bool?) ?? false,
        thumbnailPath: json['thumbnailPath'] as String?,
        imageWidth: json['imageWidth'] as int?,
        imageHeight: json['imageHeight'] as int?,
        imageDateTaken: json['imageDateTaken'] as String?,
        imageCameraMake: json['imageCameraMake'] as String?,
        imageCameraModel: json['imageCameraModel'] as String?,
        imageGpsLat: (json['imageGpsLat'] as num?)?.toDouble(),
        imageGpsLng: (json['imageGpsLng'] as num?)?.toDouble(),
        imageIso: json['imageIso'] as int?,
        imageFocalLength: (json['imageFocalLength'] as num?)?.toDouble(),
        imageFNumber: (json['imageFNumber'] as num?)?.toDouble(),
        videoWidth: json['videoWidth'] as int?,
        videoHeight: json['videoHeight'] as int?,
        videoCodec: json['videoCodec'] as String?,
        videoFps: (json['videoFps'] as num?)?.toDouble(),
      );

  @override
  bool operator ==(Object other) => other is MediaItem && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
