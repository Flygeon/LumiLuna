import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/media_type.dart';
import '../../providers/filter_provider.dart';
import '../../providers/media_provider.dart';
import '../../providers/settings_provider.dart';
import '../folders/folders_screen.dart';
import '../media/media_type_screen.dart';
import '../settings/settings_screen.dart';

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

  /// Animate the body to [index] and keep the nav bar highlight in sync.
  void _onTabSelected(int index) {
    if (index == _tab) return;
    setState(() => _tab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: const InputDecoration(
                  hintText: '搜索文件名…',
                  border: InputBorder.none,
                ),
                onChanged: (v) =>
                    ref.read(searchQueryProvider.notifier).state = v,
              )
            : const Text('媒体库'),
        actions: [
          if (_searching)
            IconButton(
              tooltip: '清除',
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            )
          else ...[
            IconButton(
              tooltip: '搜索',
              icon: const Icon(Icons.search),
              onPressed: _openSearch,
            ),
            IconButton(
              tooltip: isGrid ? '列表视图' : '网格视图',
              icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
              onPressed: () => ref.read(settingsProvider.notifier).toggleView(),
            ),
            IconButton(
              tooltip: '刷新',
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(mediaProvider.notifier).rescan(),
            ),
            IconButton(
              tooltip: '设置',
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
          MediaTypeScreen(type: MediaType.image),
          MediaTypeScreen(type: MediaType.video),
          MediaTypeScreen(type: MediaType.audio),
          FoldersScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.image_outlined),
            selectedIcon: Icon(Icons.image),
            label: '图片',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: '视频',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            selectedIcon: Icon(Icons.music_note),
            label: '音乐',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: '文件夹',
          ),
        ],
      ),
    );
  }
}
