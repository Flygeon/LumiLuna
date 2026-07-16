import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';


/// Provider for the list of folders configured for scanning.
final scanFoldersProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.getScanFolders();
});

/// Notifier to update scan folder configuration.
final scanFoldersManagerProvider = Provider<ScanFoldersManager>((ref) => ScanFoldersManager(ref));

class ScanFoldersManager {
  final Ref _ref;
  ScanFoldersManager(this._ref);

  Future<void> setFolders(List<String> folders) async {
    await _ref.read(appDatabaseProvider).setScanFolders(folders);
    _ref.invalidate(scanFoldersProvider);
  }
}
