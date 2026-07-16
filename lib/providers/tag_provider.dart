import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag.dart';
import '../services/database_service.dart';

/// All tags.
final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  return DatabaseService.getTags();
});

/// Notifier to create / delete tags and manage media-tag associations.
final tagManagerProvider = Provider<TagManager>((ref) => TagManager(ref));

class TagManager {
  final Ref _ref;
  TagManager(this._ref);

  Future<Tag> create(String name, {int color = 0xFF5C5C5C}) async {
    final tag = await DatabaseService.createTag(name, color: color);
    _ref.invalidate(tagsProvider);
    return tag;
  }

  Future<void> delete(int id) async {
    await DatabaseService.deleteTag(id);
    _ref.invalidate(tagsProvider);
  }

  Future<void> addToMedia(String mediaPath, int tagId) async {
    await DatabaseService.addTagToMedia(mediaPath, tagId);
  }

  Future<void> removeFromMedia(String mediaPath, int tagId) async {
    await DatabaseService.removeTagFromMedia(mediaPath, tagId);
  }

  /// Get tags for multiple items at once.
  Future<Map<String, List<Tag>>> tagsForPaths(List<String> paths) {
    return DatabaseService.getTagsForMediaPaths(paths);
  }
}
