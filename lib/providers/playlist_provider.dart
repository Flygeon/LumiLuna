import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/playlist.dart';
import '../services/database_service.dart';

/// All playlists.
final playlistsProvider = FutureProvider<List<Playlist>>((ref) async {
  return DatabaseService.getPlaylists();
});

/// Notifier for playlist CRUD operations.
final playlistManagerProvider = Provider<PlaylistManager>((ref) => PlaylistManager(ref));

class PlaylistManager {
  final Ref _ref;
  PlaylistManager(this._ref);

  Future<void> create(String name, {String? description}) async {
    await DatabaseService.createPlaylist(name, description: description);
    _ref.invalidate(playlistsProvider);
  }

  Future<void> delete(int id) async {
    await DatabaseService.deletePlaylist(id);
    _ref.invalidate(playlistsProvider);
  }

  Future<void> addItems(int playlistId, List<String> mediaPaths) async {
    await DatabaseService.addToPlaylist(playlistId, mediaPaths);
    _ref.invalidate(playlistsProvider);
  }

  Future<void> removeItem(int playlistId, String mediaPath) async {
    await DatabaseService.removeFromPlaylist(playlistId, mediaPath);
    _ref.invalidate(playlistsProvider);
  }

  Future<void> reorder(int playlistId, List<String> orderedPaths) async {
    await DatabaseService.reorderPlaylist(playlistId, orderedPaths);
    _ref.invalidate(playlistsProvider);
  }
}
