import '../src/rust/api.dart' as rust_core_api;
import '../src/rust/api/media_scan.dart' as rust_api;
import '../src/rust/frb_generated.dart';
import '../models/media_item.dart';
import '../models/media_metadata.dart';
import '../models/media_type.dart';

class RustScannerService {
  static RustScannerService? _instance;

  factory RustScannerService() {
    _instance ??= RustScannerService._();
    return _instance!;
  }

  RustScannerService._();

  static bool _isRustAvailable = true;
  Future<void>? _initTask;

  static bool get isRustAvailable => _isRustAvailable;

  Future<String> ping() async {
    try {
      await _ensureInitialized();
      return await rust_api.ping();
    } catch (_) {
      _isRustAvailable = false;
      rethrow;
    }
  }

  Future<int> stableHash(String path) async {
    try {
      await _ensureInitialized();
      final result = await rust_api.stableHash(path: path);
      return result.toInt();
    } catch (_) {
      _isRustAvailable = false;
      rethrow;
    }
  }

  Future<int> stableFileHash(String path, int size, int modifiedMs) async {
    try {
      await _ensureInitialized();
      final result = await rust_api.stableFileHash(
        path: path,
        size: size,
        modifiedMs: modifiedMs,
      );
      return result.toInt();
    } catch (_) {
      _isRustAvailable = false;
      rethrow;
    }
  }

  Future<bool> extractAudioCover(String path, String outputPath) async {
    try {
      await _ensureInitialized();
      return await rust_api.extractAudioCover(
          path: path, outputPath: outputPath);
    } catch (_) {
      _isRustAvailable = false;
      return false;
    }
  }

  Future<bool> extractVideoCover(String path, String outputPath,
      {int timeMs = 0}) async {
    try {
      await _ensureInitialized();
      return await rust_api.extractVideoCover(
        path: path,
        outputPath: outputPath,
        timeMs: timeMs,
      );
    } catch (_) {
      _isRustAvailable = false;
      return false;
    }
  }

  Future<List<MediaItem>> scanMediaBatch(
    List<String> folders, {
    int maxDepth = 8,
    required String cacheDir,
    int offset = 0,
    int limit = 500,
  }) async {
    try {
      await _ensureInitialized();
      final rustItems = await rust_api.scanMediaBatch(
        folders: folders,
        maxDepth: maxDepth,
        cacheDir: cacheDir,
        existingHashesJson: '{}',
        offset: offset,
        limit: limit,
      );
      return rustItems.map(_toMediaItem).toList();
    } catch (_) {
      _isRustAvailable = false;
      rethrow;
    }
  }

  Future<List<MediaItem>> scanMediaBatches(
    List<String> folders, {
    int maxDepth = 8,
    required String cacheDir,
    int batchSize = 500,
  }) async {
    try {
      await _ensureInitialized();
      final batches = await rust_api.scanMediaBatches(
        folders: folders,
        maxDepth: maxDepth,
        cacheDir: cacheDir,
        existingHashesJson: '{}',
        batchSize: batchSize,
      );
      return [for (final batch in batches) ...batch.map(_toMediaItem)];
    } catch (_) {
      _isRustAvailable = false;
      rethrow;
    }
  }

  Future<List<MediaItem>> scanMedia(List<String> folders,
      {int maxDepth = 8, required String cacheDir}) async {
    try {
      await _ensureInitialized();
      final rustItems = await rust_api.scanMedia(
        folders: folders,
        maxDepth: maxDepth,
        cacheDir: cacheDir,
        existingHashesJson: '{}',
      );
      return rustItems.map(_toMediaItem).toList();
    } catch (_) {
      _isRustAvailable = false;
      rethrow;
    }
  }

  Future<ScanResult> scanMediaWithMetadata(List<String> folders,
      {int maxDepth = 8, required String cacheDir, String existingHashesJson = '{}'}) async {
    try {
      await _ensureInitialized();
      final rustItems = await rust_api.scanMedia(
        folders: folders,
        maxDepth: maxDepth,
        cacheDir: cacheDir,
        existingHashesJson: existingHashesJson,
      );
      return ScanResult(
        rustItems.map(_toMediaItem).toList(),
        rustItems.map(_toMetadata).toList(),
      );
    } catch (_) {
      _isRustAvailable = false;
      rethrow;
    }
  }

  Future<void> _ensureInitialized() {
    final task = _initTask;
    if (task != null) return task;
    final newTask = RustLib.init().then((_) => rust_core_api.initApp());
    _initTask = newTask;
    return newTask;
  }

  MediaItem _toMediaItem(rust_api.RustMediaItem rustItem) {
    final type = switch (rustItem.mediaType) {
      'image' => MediaType.image,
      'video' => MediaType.video,
      'audio' => MediaType.audio,
      _ => MediaType.image,
    };
    return MediaItem(
      path: rustItem.path,
      name: rustItem.name,
      type: type,
      size: rustItem.size,
      modified: DateTime.fromMillisecondsSinceEpoch(rustItem.modifiedMs),
      fileHash: rustItem.fileHash.toInt(),
      title: rustItem.title,
      artist: rustItem.artist,
      album: rustItem.album,
      durationMs: rustItem.durationMs?.toInt(),
      artworkPath: rustItem.artworkPath,
      thumbnailPath: rustItem.thumbnailPath,
    );
  }

  MediaMetadata _toMetadata(rust_api.RustMediaItem rustItem) {
    return MediaMetadata(
      mediaPath: rustItem.path,
      imageWidth: rustItem.imageWidth,
      imageHeight: rustItem.imageHeight,
      imageDateTaken: rustItem.imageDateTaken,
      imageCameraMake: rustItem.imageCameraMake,
      imageCameraModel: rustItem.imageCameraModel,
      imageGpsLat: rustItem.imageGpsLat,
      imageGpsLng: rustItem.imageGpsLng,
      imageIso: rustItem.imageIso,
      imageFocalLength: rustItem.imageFocalLength,
      imageFNumber: rustItem.imageFNumber,
      videoWidth: rustItem.videoWidth,
      videoHeight: rustItem.videoHeight,
      videoCodec: rustItem.videoCodec,
      videoFps: rustItem.videoFps,
    );
  }

  static bool get hasInstance => _instance != null;

  static void reset() {
    _instance = null;
    _isRustAvailable = true;
  }
}

class ScanResult {
  final List<MediaItem> items;
  final List<MediaMetadata> metadata;
  const ScanResult(this.items, this.metadata);
}
