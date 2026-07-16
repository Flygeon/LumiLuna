import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collection.dart';
import '../main.dart';


/// All collections.
final collectionsProvider = FutureProvider<List<MediaCollection>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.getAllCollections();
});

/// Notifier for collection CRUD operations.
final collectionManagerProvider = Provider<CollectionManager>((ref) => CollectionManager(ref));

class CollectionManager {
  final Ref _ref;
  CollectionManager(this._ref);

  Future<void> create(String name, {String? description}) async {
    await _ref.read(appDatabaseProvider).createCollection(name, description: description);
    _ref.invalidate(collectionsProvider);
  }

  Future<void> delete(int id) async {
    await _ref.read(appDatabaseProvider).deleteCollection(id);
    _ref.invalidate(collectionsProvider);
  }

  Future<void> addItems(int collectionId, List<String> mediaPaths) async {
    await _ref.read(appDatabaseProvider).addToCollection(collectionId, mediaPaths);
    _ref.invalidate(collectionsProvider);
  }

  Future<void> removeItem(int collectionId, String mediaPath) async {
    await _ref.read(appDatabaseProvider).removeFromCollection(collectionId, mediaPath);
    _ref.invalidate(collectionsProvider);
  }
}
