import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import 'empty_state.dart';

/// Renders an [AsyncValue] with consistent loading / error / data handling.
///
/// The loading branch is intentionally **only** taken on the very first load,
/// when there is no data to show.  During subsequent refreshes (e.g. the user
/// toggles grid/list view, the database is refreshed by the folder watcher,
/// or `rescan()` is invoked), the previous data is kept visible instead of
/// flashing back to a blank/grey screen with a centred spinner.
class AsyncView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  const AsyncView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return value.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: builder,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: l10n.loadingError,
        message: '$error',
        actionLabel: onRetry != null ? l10n.retry : null,
        onAction: onRetry,
      ),
    );
  }
}
