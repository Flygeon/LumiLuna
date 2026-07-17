import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'media_provider.dart';
import '../services/folder_watcher_service.dart';

/// Singleton instance of [FolderWatcherService] managed as a Riverpod provider.
final folderWatcherProvider = Provider<FolderWatcherService>((ref) {
  final service = FolderWatcherService(
    database: ref.watch(appDatabaseProvider),
    onChanged: () => ref.read(mediaProvider.notifier).reloadFromDatabase(),
  );
  ref.onDispose(() => service.stop());
  return service;
});
