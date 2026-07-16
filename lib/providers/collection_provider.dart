import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collection.dart';
import '../services/database_service.dart';

/// All collections.
final collectionsProvider = FutureProvider<List<MediaCollection>>((ref) async {
  return DatabaseService.getCollections();
});

/// Notifier for collection CRUD operations.
final collectionManagerProvider = Provider<CollectionManager>((ref) => CollectionManager(ref));

class CollectionManager {
  final Ref _ref;
  CollectionManager(this._ref);

  Future<void> create(String name, {String? description}) async {
    await DatabaseService.createCollection(name, description: description);
    _ref.invalidate(collectionsProvider);
  }

  Future<void> delete(int id) async {
    await DatabaseService.deleteCollection(id);
    _ref.invalidate(collectionsProvider);
  }

  Future<void> addItems(int collectionId, List<String> mediaPaths) async {
    await DatabaseService.addToCollection(collectionId, mediaPaths);
    _ref.invalidate(collectionsProvider);
  }

  Future<void> removeItem(int collectionId, String mediaPath) async {
    await DatabaseService.removeFromCollection(collectionId, mediaPath);
    _ref.invalidate(collectionsProvider);
  }
}
