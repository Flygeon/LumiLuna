import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import '../models/media_item.dart';
import '../providers/media_provider.dart';
import '../services/trash_manager.dart';

/// Modal bottom sheet shown when the user long-presses a media item.
class MediaContextSheet {
  MediaContextSheet._();

  /// Display the sheet for [item] with actions that operate through [ref].
  static void show({
    required BuildContext context,
    required MediaItem item,
    required WidgetRef ref,
  }) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header — file name and type icon.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Icon(item.type.icon, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(ctx).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (Platform.isWindows)
                ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: Text(l10n.locateInExplorer),
                  onTap: () {
                    Navigator.pop(ctx);
                    _locateInExplorer(item);
                  },
                ),
              ListTile(
                leading: Icon(
                  item.isFavorite ? Icons.star : Icons.star_border,
                  color: item.isFavorite ? Colors.amber : null,
                ),
                title: Text(item.isFavorite ? l10n.unfavorite : l10n.favorite),
                onTap: () {
                  Navigator.pop(ctx);
                  _toggleFavorite(context, item, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.rename),
                onTap: () {
                  Navigator.pop(ctx);
                  _rename(context, item, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  l10n.delete,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _delete(context, item, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Open Windows Explorer with the file selected, or the parent folder on
  /// other platforms.
  static void _locateInExplorer(MediaItem item) {
    if (Platform.isWindows) {
      Process.run('explorer', ['/select,', item.path]);
    } else {
      Process.run('open', [item.folderPath]);
    }
  }

  /// Toggle the favourite flag and persist through the provider.
  static Future<void> _toggleFavorite(
    BuildContext context,
    MediaItem item,
    WidgetRef ref,
  ) async {
    final items = ref.read(mediaProvider).valueOrNull ?? [];
    final index = items.indexWhere((i) => i.path == item.path);
    if (index < 0) return;
    await ref.read(mediaProvider.notifier).toggleFavorite(index);
  }

  /// Show a rename dialog and apply the change on disk + in state.
  static Future<void> _rename(
    BuildContext context,
    MediaItem item,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final dot = item.name.lastIndexOf('.');
    final suggested = dot >= 0 ? item.name.substring(0, dot) : item.name;
    final controller = TextEditingController(text: suggested);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.renameHint),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.rename),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == suggested) return;

    final items = ref.read(mediaProvider).valueOrNull ?? [];
    final index = items.indexWhere((i) => i.path == item.path);
    if (index < 0) return;

    try {
      await ref.read(mediaProvider.notifier).renameItem(index, newName);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.operationFailed('$e'))),
        );
      }
    }
  }

  /// Confirm deletion then move the file to the recycle bin.
  static Future<void> _delete(
    BuildContext context,
    MediaItem item,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final entry = await TrashManager.moveToTrash(item);
    if (entry != null) {
      // Update the media list — remove the deleted item.
      final items = ref.read(mediaProvider).valueOrNull ?? [];
      final index = items.indexWhere((i) => i.path == item.path);
      if (index >= 0) {
        await ref.read(mediaProvider.notifier).removeItem(index);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.movedToTrash(item.name))),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.operationFailed(''))),
        );
      }
    }
  }
}
