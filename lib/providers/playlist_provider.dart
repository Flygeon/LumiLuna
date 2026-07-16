import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import '../main.dart';


/// All playlists.
final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.getAllPlaylists();
});

/// Notifier for playlist CRUD operations.
final playlistManagerProvider = Provider<PlaylistManager>((ref) => PlaylistManager(ref));

class PlaylistManager {
  final Ref _ref;
  PlaylistManager(this._ref);

  Future<void> create(String name, {String? description}) async {
    await _ref.read(appDatabaseProvider).createPlaylist(name, description: description);
    _ref.invalidate(playlistsProvider);
  }

  Future<void> delete(int id) async {
    await _ref.read(appDatabaseProvider).deletePlaylist(id);
    _ref.invalidate(playlistsProvider);
  }

  Future<void> addItems(int playlistId, List<String> mediaPaths) async {
    await _ref.read(appDatabaseProvider).addToPlaylist(playlistId, mediaPaths);
    _ref.invalidate(playlistsProvider);
  }

  Future<void> removeItem(int playlistId, String mediaPath) async {
    await _ref.read(appDatabaseProvider).removeFromPlaylist(playlistId, mediaPath);
    _ref.invalidate(playlistsProvider);
  }

  Future<void> reorder(int playlistId, List<String> orderedPaths) async {
    await _ref.read(appDatabaseProvider).reorderPlaylist(playlistId, orderedPaths);
    _ref.invalidate(playlistsProvider);
  }
}
