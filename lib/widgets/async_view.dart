import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';
import 'empty_state.dart';

/// Renders an [AsyncValue] with consistent loading / error / data handling.
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
