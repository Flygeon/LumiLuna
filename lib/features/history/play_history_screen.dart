import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../main.dart';
import '../../models/media_item.dart';
import '../../providers/play_history_provider.dart';
import '../../widgets/async_view.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_grid_view.dart';
import '../../widgets/media_list_view.dart';
import '../../providers/settings_provider.dart';
import '../media/media_type_screen.dart';

class PlayHistoryScreen extends ConsumerWidget {
  const PlayHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(playHistoryProvider);
    final isGrid = ref.watch(settingsProvider.select((s) => s.isGridView));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.playHistory),
        actions: [
          IconButton(
            tooltip: context.l10n.clear,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(context.l10n.clearHistoryConfirmTitle),
                  content: Text(context.l10n.clearHistoryConfirmBody),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text(
                            MaterialLocalizations.of(ctx).cancelButtonLabel)),
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child:
                            Text(MaterialLocalizations.of(ctx).okButtonLabel)),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(appDatabaseProvider).clearPlayHistory();
                ref.invalidate(playHistoryProvider);
              }
            },
          ),
        ],
      ),
      body: AsyncView<List<MediaItem>>(
        value: async,
        onRetry: () => ref.invalidate(playHistoryProvider),
        builder: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.history,
              title: context.l10n.playHistoryEmpty,
              message: context.l10n.playHistoryEmptyHint,
            );
          }
          return isGrid
              ? MediaGridView(
                  items: items,
                  onTap: (i) => openMedia(context, ref, items, i),
                )
              : MediaListView(
                  items: items,
                  onTap: (i) => openMedia(context, ref, items, i),
                );
        },
      ),
    );
  }
}
