import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tag.dart';
import '../providers/tag_provider.dart';
import '../services/database_service.dart';
import 'tag_chip.dart';

/// Dialog that lets the user manage tags for a set of media files.
class TagEditorDialog extends ConsumerStatefulWidget {
  final List<String> mediaPaths;

  const TagEditorDialog({super.key, required this.mediaPaths});

  /// Convenience method to show the dialog.
  static Future<void> show(BuildContext context, List<String> mediaPaths) {
    return showDialog(
      context: context,
      builder: (_) => TagEditorDialog(mediaPaths: mediaPaths),
    );
  }

  @override
  ConsumerState<TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends ConsumerState<TagEditorDialog> {
  final TextEditingController _newTagController = TextEditingController();
  Map<String, List<Tag>> _mediaTags = {};
  List<Tag> _allTags = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final allTags = await ref.read(tagsProvider.future);
    final mediaTags = await ref.read(tagManagerProvider).tagsForPaths(widget.mediaPaths);
    if (mounted) {
      setState(() {
        _allTags = allTags;
        _mediaTags = mediaTags;
      });
    }
  }

  /// Collect all tag ids applied to ALL selected files.
  Set<int> get _commonTagIds {
    if (widget.mediaPaths.isEmpty) return {};
    final sets = widget.mediaPaths
        .map((p) => _mediaTags[p]?.map((t) => t.id).nonNulls.toSet() ?? <int>{})
        .toList();
    return sets.reduce((a, b) => a.intersection(b));
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commonIds = _commonTagIds;

    return AlertDialog(
      title: Text('管理标签 (${widget.mediaPaths.length} 项)'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('当前标签:', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            if (_allTags.isEmpty)
              const Text('暂无标签，输入名称创建新标签')
            else
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _allTags.map((tag) {
                  final isCommon = commonIds.contains(tag.id);
                  return TagChip(
                    tag: tag,
                    selected: isCommon,
                    onTap: () => _toggleTag(tag.id!),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagController,
                    decoration: const InputDecoration(
                      hintText: '新标签名称',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _createTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _createTag,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('完成'),
        ),
      ],
    );
  }

  Future<void> _toggleTag(int tagId) async {
    final manager = ref.read(tagManagerProvider);
    final isCommon = _commonTagIds.contains(tagId);

    for (final path in widget.mediaPaths) {
      if (isCommon) {
        await manager.removeFromMedia(path, tagId);
      } else {
        await manager.addToMedia(path, tagId);
      }
    }
    _load();
  }

  Future<void> _createTag() async {
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;

    _newTagController.clear();
    final tag = await ref.read(tagManagerProvider).create(name);

    // Auto-apply to all selected files.
    for (final path in widget.mediaPaths) {
      await DatabaseService.addTagToMedia(path, tag.id!);
    }
    _load();
  }
}
