import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format_utils.dart';
import '../../l10n/l10n.dart';
import '../../services/trash_manager.dart';

/// View all trashed / recycled files with restore and permanent-delete actions.
class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  List<TrashEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await TrashManager.listTrash();
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  Future<void> _restore(TrashEntry entry) async {
    final ok = await TrashManager.restore(entry);
    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.restored)),
        );
        _load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to restore file')),
        );
      }
    }
  }

  Future<void> _permanentlyDelete(TrashEntry entry) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmPermanentDelete(entry.fileName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.deleteForever),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await TrashManager.permanentlyDelete(entry);
    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.permanentlyDeleted)),
        );
        _load();
      }
    }
  }

  Future<void> _emptyTrash() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmEmptyTrash),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.deleteForever),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await TrashManager.emptyTrash();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.permanentlyDeleted)),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trashTitle),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              tooltip: l10n.emptyTrash,
              icon: const Icon(Icons.delete_sweep),
              onPressed: _emptyTrash,
            ),
        ],
      ),
      body: _buildBody(l10n, scheme),
    );
  }

  Widget _buildBody(dynamic l10n, ColorScheme scheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 72, color: scheme.outline),
              const SizedBox(height: 16),
              Text(
                context.l10n.trashEmpty,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final isSystemTrash = entry.trashLocation == 'recycle_bin';
        return ListTile(
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: Text(
            entry.fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${FormatUtils.fileSize(entry.size)} · ${FormatUtils.dateTime(entry.deletedAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isSystemTrash)
                IconButton(
                  tooltip: context.l10n.restore,
                  icon: const Icon(Icons.restore),
                  onPressed: () => _restore(entry),
                ),
              if (!isSystemTrash)
                IconButton(
                  tooltip: context.l10n.deleteForever,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () => _permanentlyDelete(entry),
                ),
              if (isSystemTrash)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'In system Recycle Bin',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
