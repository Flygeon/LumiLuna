import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/folder_watcher_service.dart';

/// Singleton instance of [FolderWatcherService] managed as a Riverpod provider.
final folderWatcherProvider = Provider<FolderWatcherService>((ref) {
  final service = FolderWatcherService();
  ref.onDispose(() => service.stop());
  return service;
});
