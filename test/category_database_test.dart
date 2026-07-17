import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumiluna/models/media_item.dart';
import 'package:lumiluna/models/media_type.dart';
import 'package:lumiluna/services/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('creates a two-level category hierarchy and normalizes names', () async {
    final group = await database.createTag('  地点  ', isGroup: true);
    final tag = await database.createTag('  上海   城区 ', parentId: group.id);

    expect(group.name, '地点');
    expect(group.isGroup, isTrue);
    expect(tag.name, '上海 城区');
    expect(tag.parentId, group.id);
    expect(tag.isGroup, isFalse);
  });

  test('rejects duplicate names and deeper category nesting', () async {
    final group = await database.createTag('人物', isGroup: true);
    final tag = await database.createTag('家人', parentId: group.id);

    expect(
      () => database.createTag('人物'),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => database.createTag('错误层级', parentId: tag.id),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('applies tags transactionally and keeps media relations safe', () async {
    final item = MediaItem(
      path: 'C:/Media/photo.jpg',
      name: 'photo.jpg',
      type: MediaType.image,
      size: 1,
      modified: DateTime(2026),
    );
    await database.upsertMediaItems([item]);
    final tag = await database.createTag('旅行');

    await database.setTagForMediaPaths([item.path], tag.id!, true);
    expect(
        (await database.getMediaItemsForTag(tag.id!)).single.path, item.path);

    await database.deleteTag(tag.id!);
    expect(await database.getTagsForMediaPaths([item.path]), isEmpty);
    expect(await database.getMediaItemByPath(item.path), isNotNull);
  });

  test('deleting a category group preserves its tags as ungrouped', () async {
    final group = await database.createTag('主题', isGroup: true);
    final tag = await database.createTag('旅行', parentId: group.id);

    await database.deleteTag(group.id!);
    final remaining = await database.getAllTags();

    expect(remaining.single.id, tag.id);
    expect(remaining.single.parentId, isNull);
  });
}
