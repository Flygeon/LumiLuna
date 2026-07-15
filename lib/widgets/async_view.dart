import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return value.when(
      data: builder,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: '加载出错',
        message: '$error',
        actionLabel: onRetry != null ? '重试' : null,
        onAction: onRetry,
      ),
    );
  }
}
