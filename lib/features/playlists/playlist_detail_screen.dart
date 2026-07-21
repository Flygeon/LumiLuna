import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/media_item.dart';
import '../../models/media_type.dart';
import '../../models/playlist.dart';
import '../../providers/media_provider.dart';
import '../../providers/playlist_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/media_list_view.dart';
import '../player/music_player_screen.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  ConsumerState<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  bool _editing = false;
  late List<MediaItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.playlist.items ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final playlistId = widget.playlist.id!;

    // Refresh items when the playlist provider invalidates.
    ref.listen(playlistsProvider, (prev, next) {
      next.whenData((list) {
        final updated = list.where((p) => p.id == playlistId).firstOrNull;
        if (updated != null && mounted) {
          setState(() => _items = List.from(updated.items ?? []));
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
        actions: [
          // Play all
          if (_items.isNotEmpty && !_editing)
            IconButton(
              icon: const Icon(Icons.playlist_play),
              tooltip: '播放全部',
              onPressed: () => _playAll(),
            ),
          // Toggle edit mode
          IconButton(
            icon: Icon(_editing ? Icons.check : Icons.edit),
            tooltip: _editing ? '完成' : '编辑',
            onPressed: () => setState(() => _editing = !_editing),
          ),
        ],
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.playlist_add, size: 64, color: scheme.outline),
                  const SizedBox(height: 16),
                  const Text('播放列表为空'),
                  const SizedBox(height: 8),
                  Text('点击下方按钮添加音乐'),
                ],
              ),
            )
          : _editing
              ? _buildEditableList(playlistId, scheme)
              : MediaListView(
                  items: _items,
                  onTap: (i) => _playItem(i),
                  onSecondaryTap: (i) => _showItemMenu(context, i, playlistId),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMusic(playlistId),
        icon: const Icon(Icons.add),
        label: Text(_editing ? '添加音乐' : '添加音乐'),
      ),
    );
  }

  Widget _buildEditableList(int playlistId, ColorScheme scheme) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _items.length,
      onReorderItem: (oldIndex, newIndex) {
        setState(() {
          final item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
        _persistOrder(playlistId);
      },
      itemBuilder: (context, index) {
        final item = _items[index];
        return Dismissible(
          key: ValueKey(item.path),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: scheme.error,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            setState(() => _items.removeAt(index));
            ref.read(playlistManagerProvider).removeItem(playlistId, item.path);
            _persistOrder(playlistId);
          },
          child: ListTile(
            key: ValueKey(item.path),
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
            title: Text(item.title ?? item.name,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(item.artist ?? '',
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                setState(() => _items.removeAt(index));
                ref
                    .read(playlistManagerProvider)
                    .removeItem(playlistId, item.path);
                _persistOrder(playlistId);
              },
            ),
          ),
        );
      },
    );
  }

  void _persistOrder(int playlistId) {
    ref.read(playlistManagerProvider).reorder(
          playlistId,
          _items.map((e) => e.path).toList(),
        );
  }

  void _playAll() {
    final audioItems = _items.where((i) => i.type == MediaType.audio).toList();
    if (audioItems.isNotEmpty) {
      ref.read(playbackControllerProvider.notifier).openPlaylist(audioItems, 0);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MusicPlayerScreen()),
      );
    }
  }

  void _playItem(int index) {
    final audioItems = _items.where((i) => i.type == MediaType.audio).toList();
    final idx = audioItems.indexWhere((i) => i.path == _items[index].path);
    if (idx >= 0) {
      ref
          .read(playbackControllerProvider.notifier)
          .openPlaylist(audioItems, idx);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MusicPlayerScreen()),
      );
    }
  }

  void _addMusic(int playlistId) async {
    // Fetch all audio items that are not already in this playlist.
    final allMedia = ref.read(mediaProvider);
    final existingPaths = _items.map((e) => e.path).toSet();
    final candidates = allMedia.valueOrNull
            ?.where(
              (m) =>
                  m.type == MediaType.audio && !existingPaths.contains(m.path),
            )
            .toList() ??
        [];

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('没有更多可添加的音乐')),
      );
      return;
    }

    final selected = await showDialog<List<MediaItem>>(
      context: context,
      builder: (ctx) => _AddMusicDialog(candidates: candidates),
    );

    if (selected != null && selected.isNotEmpty) {
      ref.read(playlistManagerProvider).addItems(
            playlistId,
            selected.map((e) => e.path).toList(),
          );
      setState(() => _items.addAll(selected));
    }
  }

  void _showItemMenu(BuildContext context, int index, int playlistId) {
    final item = _items[index];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('从播放列表移除'),
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() => _items.removeAt(index));
                ref
                    .read(playlistManagerProvider)
                    .removeItem(playlistId, item.path);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog to select music tracks to add to a playlist.
class _AddMusicDialog extends StatefulWidget {
  final List<MediaItem> candidates;
  const _AddMusicDialog({required this.candidates});

  @override
  State<_AddMusicDialog> createState() => _AddMusicDialogState();
}

class _AddMusicDialogState extends State<_AddMusicDialog> {
  final _selected = <MediaItem>{};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加音乐'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: widget.candidates.length,
          itemBuilder: (context, index) {
            final item = widget.candidates[index];
            final isSelected = _selected.contains(item);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selected.add(item);
                  } else {
                    _selected.remove(item);
                  }
                });
              },
              title: Text(item.title ?? item.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: item.artist != null ? Text(item.artist!) : null,
              dense: true,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selected.toList()),
          child: Text('添加 (${_selected.length})'),
        ),
      ],
    );
  }
}
