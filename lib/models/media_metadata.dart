/// EXIF / video metadata that is loaded lazily from the database.
///
/// Separated from [MediaItem] to keep the core list object small.
/// Only fetched when the user opens the image detail dialog or video player.
class MediaMetadata {
  final String mediaPath;

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

  const MediaMetadata({
    required this.mediaPath,
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

  /// Serialize this metadata to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'mediaPath': mediaPath,
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
  factory MediaMetadata.fromJson(Map<String, dynamic> json) => MediaMetadata(
        mediaPath: json['mediaPath'] as String,
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

  /// Whether this metadata contains any image-related fields.
  bool get hasImageMetadata =>
      imageWidth != null ||
      imageHeight != null ||
      imageDateTaken != null ||
      imageCameraMake != null ||
      imageCameraModel != null ||
      imageIso != null ||
      imageFocalLength != null ||
      imageFNumber != null ||
      imageGpsLat != null ||
      imageGpsLng != null;

  /// Whether this metadata contains any video-related fields.
  bool get hasVideoMetadata =>
      videoWidth != null ||
      videoHeight != null ||
      videoCodec != null ||
      videoFps != null;
}
