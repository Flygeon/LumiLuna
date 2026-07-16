import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

/// Provider for the list of folders configured for scanning.
final scanFoldersProvider = FutureProvider<List<String>>((ref) async {
  return DatabaseService.getScanFolders();
});

/// Notifier to update scan folder configuration.
final scanFoldersManagerProvider = Provider<ScanFoldersManager>((ref) => ScanFoldersManager(ref));

class ScanFoldersManager {
  final Ref _ref;
  ScanFoldersManager(this._ref);

  Future<void> setFolders(List<String> folders) async {
    await DatabaseService.setScanFolders(folders);
    _ref.invalidate(scanFoldersProvider);
  }
}
