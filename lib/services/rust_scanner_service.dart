import '../src/rust/api.dart' as rust_core_api;
import '../src/rust/api/media_scan.dart' as rust_api;
import '../src/rust/frb_generated.dart';
import '../models/media_item.dart';
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

  Future<List<MediaItem>> scanMedia(List<String> folders, {int maxDepth = 8}) async {
    try {
      await _ensureInitialized();
      final rustItems = await rust_api.scanMedia(
        folders: folders,
        maxDepth: maxDepth,
      );
      return rustItems.map(_toMediaItem).toList();
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
    );
  }

  static bool get hasInstance => _instance != null;

  static void reset() {
    _instance = null;
    _isRustAvailable = true;
  }
}
