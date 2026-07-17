import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages multi-selection state within media lists.
///
/// [T] is typically the path String of [MediaItem], stored in a [Set] to
/// guarantee O(1) contains-check and to prevent duplicates.
class SelectionState {
  final Set<String> selected;
  final bool isSelecting;

  const SelectionState({
    this.selected = const {},
    this.isSelecting = false,
  });

  int get count => selected.length;
  bool get isEmpty => selected.isEmpty;

  SelectionState copyWith({Set<String>? selected, bool? isSelecting}) =>
      SelectionState(
        selected: selected ?? this.selected,
        isSelecting: isSelecting ?? this.isSelecting,
      );
}

class SelectionNotifier extends StateNotifier<SelectionState> {
  SelectionNotifier() : super(const SelectionState());

  /// Enter selection mode, optionally with pre-selected items.
  void startSelection([Set<String>? initial]) {
    state = SelectionState(
      selected: initial ?? {},
      isSelecting: true,
    );
  }

  /// Exit selection mode and clear.
  void endSelection() {
    state = const SelectionState();
  }

  /// Toggle one item. When the last item is unchecked, the selection mode
  /// exits automatically so the UI returns to its normal tap-to-open flow.
  void toggle(String path) {
    final next = Set<String>.from(state.selected);
    if (next.contains(path)) {
      next.remove(path);
    } else {
      next.add(path);
    }
    if (next.isEmpty) {
      // All selections cleared — drop selection mode entirely.
      endSelection();
      return;
    }
    state = state.copyWith(selected: next);
  }

  /// Select all [paths].
  void selectAll(Set<String> paths) {
    state = state.copyWith(selected: Set.from(paths));
  }

  /// Clear selection. Exits selection mode so the next tap opens the item.
  void clearSelection() {
    endSelection();
  }
}

/// A provider family to scope selection state per screen.
///
/// Usage: `ref.watch(selectionProvider('media_tab_image'))`
final selectionProvider =
    StateNotifierProvider.family<SelectionNotifier, SelectionState, String>(
  (ref, id) => SelectionNotifier(),
);
