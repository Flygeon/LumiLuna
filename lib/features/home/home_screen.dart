import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/media_folder.dart';
import '../../models/media_type.dart';
import '../../providers/filter_provider.dart';
import '../../providers/media_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tab_provider.dart';
import '../folders/folders_screen.dart';
import '../media/media_type_screen.dart';
import '../settings/settings_screen.dart';
import '../trash/trash_screen.dart';

/// Root screen with a Material 3 navigation bar for switching media types,
/// plus search, grid/list toggle, refresh and a settings entry.
///
/// Tab switching is animated with a horizontal slide via [PageView] +
/// [PageController], so the content glides between media types instead of
/// snapping instantly. Visited pages stay mounted, preserving their scroll
/// position and state.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;
  bool _searching = false;
  final TextEditingController _searchController = TextEditingController();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openSearch() => setState(() => _searching = true);

  void _closeSearch() {
    setState(() => _searching = false);
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
  }

  MediaType _typeForIndex(int index) {
    switch (index) {
      case 0:
        return MediaType.image;
      case 1:
        return MediaType.video;
      case 2:
        return MediaType.audio;
      default:
        return MediaType.image; // folders / trash: placeholder
    }
  }

  /// Animate the body to [index] and keep the nav bar highlight in sync.
  ///
  /// Heavy, per-item work (video frame extraction) is paused while
  /// [tabAnimatingProvider] is true, so it never competes with the slide.
  void _onTabSelected(int index) {
    if (index == _tab) return;
    ref.read(activeTypeProvider.notifier).state = _typeForIndex(index);
    ref.read(tabAnimatingProvider.notifier).state = true;
    setState(() => _tab = index);
    _pageController
        .animateToPage(
          index,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
        )
        .then((_) {
          if (mounted) ref.read(tabAnimatingProvider.notifier).state = false;
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isGrid = ref.watch(settingsProvider.select((s) => s.isGridView));

    return Scaffold(
      appBar: AppBar(
        leading: _searching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _closeSearch,
              )
            : null,
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  border: InputBorder.none,
                ),
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
              )
            : Text(l10n.homeTitle),
        actions: [
          if (_searching)
            IconButton(
              tooltip: l10n.clear,
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            )
          else ...[
            IconButton(
              tooltip: l10n.search,
              icon: const Icon(Icons.search),
              onPressed: _openSearch,
            ),
            IconButton(
              tooltip: isGrid ? l10n.listView : l10n.gridView,
              icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
              onPressed: () => ref.read(settingsProvider.notifier).toggleView(),
            ),
            IconButton(
              tooltip: l10n.refresh,
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(mediaProvider.notifier).rescan(),
            ),
            IconButton(
              tooltip: l10n.settings,
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ],
      ),
      body: PageView(
        controller: _pageController,
        // Tap-driven animation only; the body is a vertical-scrolling media
        // list, so we disable swipe to avoid accidental page changes.
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          RepaintBoundary(child: MediaTypeScreen(type: MediaType.image)),
          RepaintBoundary(child: MediaTypeScreen(type: MediaType.video)),
          RepaintBoundary(child: MediaTypeScreen(type: MediaType.audio)),
          RepaintBoundary(child: FoldersScreen()),
          RepaintBoundary(child: TrashScreen()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _onTabSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.image_outlined),
            selectedIcon: const Icon(Icons.image),
            label: mediaTypeName(context, MediaType.image),
          ),
          NavigationDestination(
            icon: const Icon(Icons.movie_outlined),
            selectedIcon: const Icon(Icons.movie),
            label: mediaTypeName(context, MediaType.video),
          ),
          NavigationDestination(
            icon: const Icon(Icons.music_note_outlined),
            selectedIcon: const Icon(Icons.music_note),
            label: mediaTypeName(context, MediaType.audio),
          ),
          NavigationDestination(
            icon: const Icon(Icons.folder_outlined),
            selectedIcon: const Icon(Icons.folder),
            label: groupModeName(context, GroupMode.folder),
          ),
          NavigationDestination(
            icon: const Icon(Icons.delete_outline),
            selectedIcon: const Icon(Icons.delete),
            label: l10n.trashTitle,
          ),
        ],
      ),
    );
  }
}
