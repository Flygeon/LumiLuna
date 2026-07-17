import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tag.dart';
import '../providers/tag_provider.dart';
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
  bool _loading = true;
  bool _saving = false;
  int? _parentId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final allTags = await ref.read(tagsProvider.future);
    final mediaTags =
        await ref.read(tagManagerProvider).tagsForPaths(widget.mediaPaths);
    if (mounted) {
      setState(() {
        _allTags = allTags;
        _mediaTags = mediaTags;
        _loading = false;
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

  Set<int> get _partialTagIds {
    final counts = <int, int>{};
    for (final path in widget.mediaPaths) {
      for (final tag in _mediaTags[path] ?? const <Tag>[]) {
        if (tag.id != null) {
          counts.update(tag.id!, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }
    return counts.entries
        .where((entry) =>
            entry.value > 0 && entry.value < widget.mediaPaths.length)
        .map((entry) => entry.key)
        .toSet();
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commonIds = _commonTagIds;
    final partialIds = _partialTagIds;
    final groups = _allTags.where((tag) => tag.isGroup).toList();
    final ungrouped =
        _allTags.where((tag) => !tag.isGroup && tag.parentId == null).toList();

    return AlertDialog(
      title: Text('管理标签 (${widget.mediaPaths.length} 项)'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('按分类选择标签',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_allTags.where((tag) => !tag.isGroup).isEmpty)
              const Text('暂无标签，输入名称创建新标签')
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final group in groups) ...[
                        Text(group.name,
                            style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 4),
                        _tagWrap(
                            _allTags.where((tag) => tag.parentId == group.id),
                            commonIds,
                            partialIds),
                        const SizedBox(height: 10),
                      ],
                      if (ungrouped.isNotEmpty) ...[
                        const Text('未分类'),
                        const SizedBox(height: 4),
                        _tagWrap(ungrouped, commonIds, partialIds),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              initialValue: _parentId,
              decoration:
                  const InputDecoration(labelText: '所属分类', isDense: true),
              items: [
                const DropdownMenuItem(value: null, child: Text('未分类')),
                ...groups.map((group) =>
                    DropdownMenuItem(value: group.id, child: Text(group.name))),
              ],
              onChanged:
                  _saving ? null : (value) => setState(() => _parentId = value),
            ),
            const SizedBox(height: 8),
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
                  onPressed: _saving ? null : _createTag,
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

  Widget _tagWrap(Iterable<Tag> tags, Set<int> commonIds, Set<int> partialIds) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags.map((tag) {
        final partial = partialIds.contains(tag.id);
        return TagChip(
          tag: tag,
          selected: commonIds.contains(tag.id),
          onTap: _saving ? null : () => _toggleTag(tag.id!),
          prefix: partial ? const Icon(Icons.remove, size: 14) : null,
        );
      }).toList(),
    );
  }

  Future<void> _toggleTag(int tagId) async {
    final manager = ref.read(tagManagerProvider);
    final isCommon = _commonTagIds.contains(tagId);
    setState(() => _saving = true);
    await manager.setForMedia(widget.mediaPaths, tagId, !isCommon);
    await _load();
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _createTag() async {
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final tag =
          await ref.read(tagManagerProvider).create(name, parentId: _parentId);
      await ref
          .read(tagManagerProvider)
          .setForMedia(widget.mediaPaths, tag.id!, true);
      _newTagController.clear();
      await _load();
    } on ArgumentError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
    if (mounted) setState(() => _saving = false);
  }
}
