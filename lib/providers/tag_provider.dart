import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tag.dart';
import '../main.dart';

/// All tags.
final tagsProvider = FutureProvider<List<Tag>>((ref) async {
  final db = ref.read(appDatabaseProvider);
  return db.getAllTags();
});

/// Notifier to create / delete tags and manage media-tag associations.
final tagManagerProvider = Provider<TagManager>((ref) => TagManager(ref));

class TagManager {
  final Ref _ref;
  TagManager(this._ref);

  Future<Tag> create(
    String name, {
    int color = 0xFF5C5C5C,
    int? parentId,
    bool isGroup = false,
  }) async {
    final tag = await _ref.read(appDatabaseProvider).createTag(
          name,
          color: color,
          parentId: parentId,
          isGroup: isGroup,
        );
    _ref.invalidate(tagsProvider);
    return tag;
  }

  Future<void> delete(int id) async {
    await _ref.read(appDatabaseProvider).deleteTag(id);
    _ref.invalidate(tagsProvider);
  }

  Future<void> addToMedia(String mediaPath, int tagId) async {
    await _ref.read(appDatabaseProvider).addTagToMedia(mediaPath, tagId);
  }

  Future<void> removeFromMedia(String mediaPath, int tagId) async {
    await _ref.read(appDatabaseProvider).removeTagFromMedia(mediaPath, tagId);
  }

  Future<void> setForMedia(
    List<String> mediaPaths,
    int tagId,
    bool selected,
  ) {
    return _ref
        .read(appDatabaseProvider)
        .setTagForMediaPaths(mediaPaths, tagId, selected);
  }

  /// Get tags for multiple items at once.
  Future<Map<String, List<Tag>>> tagsForPaths(List<String> paths) {
    return _ref.read(appDatabaseProvider).getTagsForMediaPaths(paths);
  }
}
