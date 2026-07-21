import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:image/image.dart' as img;

import '../../models/media_item.dart';
import '../../providers/settings_provider.dart';
import '../../main.dart';
import '../../models/book_reading_state.dart';
import '../../services/book_metadata_service.dart';
import '../../models/epub_html_model.dart';
import 'book_reader_input.dart';

class BookReaderScreen extends ConsumerStatefulWidget {
  final MediaItem item;

  const BookReaderScreen({super.key, required this.item});

  @override
  ConsumerState<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends ConsumerState<BookReaderScreen> {
  PdfController? _pdfController;
  final ScrollController _epubScrollController = ScrollController();
  ParsedEpubBook? _epubBook;
  String? _epubError;
  int _pdfPage = 1;
  int? _pdfPageCount;
  BookReadingState? _savedState;
  int _epubChapter = 0;
  final _epubKeys = <GlobalKey>[];
  List<BookBookmark> _bookmarks = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _epubScrollController.addListener(_updateEpubChapter);
    if (widget.item.extension == 'pdf') {
      _loadPdf();
    } else {
      _loadEpub();
    }
  }

  Future<void> _loadPdf() async {
    _savedState = await ref
        .read(appDatabaseProvider)
        .getBookReadingState(widget.item.path);
    final initialPage = _savedState?.pdfPage ?? 1;
    final document = PdfDocument.openFile(widget.item.path);
    _pdfController =
        PdfController(document: document, initialPage: initialPage);
    final loaded = await document;
    await _cachePdfCover(loaded);
    if (!mounted) return;
    setState(() => _pdfPageCount = loaded.pagesCount);
  }

  Future<void> _cachePdfCover(PdfDocument document) async {
    try {
      final page = await document.getPage(1);
      final image = await page.render(
          width: 360,
          height: 520,
          format: PdfPageImageFormat.jpeg,
          quality: 85);
      await page.close();
      if (image == null) return;
      final path =
          await BookMetadataService().coverCachePath(File(widget.item.path));
      final file = File(path);
      if (!await file.exists()) {
        await file.writeAsBytes(image.bytes, flush: true);
      }
      await ref
          .read(appDatabaseProvider)
          .updateMediaThumbnail(widget.item.path, path);
    } catch (_) {}
  }

  Future<void> _saveProgress({int? page}) async {
    final current = page ?? _pdfPage;
    await ref.read(appDatabaseProvider).saveBookReadingState(
          BookReadingState(
            mediaPath: widget.item.path,
            progress: _pdfPageCount == null ? 0 : current / _pdfPageCount!,
            pdfPage: current,
            epubCfi: _savedState?.epubCfi,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> _loadEpub() async {
    try {
      _savedState = await ref
          .read(appDatabaseProvider)
          .getBookReadingState(widget.item.path);
      final book = await BookMetadataService().readEpub(File(widget.item.path));
      if (book.cover != null) {
        final path =
            await BookMetadataService().coverCachePath(File(widget.item.path));
        final coverFile = File(path);
        if (!await coverFile.exists()) {
          await coverFile.writeAsBytes(img.encodeJpg(book.cover!, quality: 85),
              flush: true);
        }
        await ref
            .read(appDatabaseProvider)
            .updateMediaThumbnail(widget.item.path, path);
      }
      if (!mounted) return;
      setState(() {
        _epubBook = book;
        _epubKeys
          ..clear()
          ..addAll(List.generate(book.chapters.length, (_) => GlobalKey()));
        _epubChapter = _savedState?.epubCfi?.startsWith('chapter:') == true
            ? int.tryParse(_savedState!.epubCfi!.substring(8)) ?? 0
            : 0;
      });
      _loadBookmarks();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_epubScrollController.hasClients && _savedState?.progress != null) {
          _epubScrollController.jumpTo(
            _epubScrollController.position.maxScrollExtent *
                _savedState!.progress.clamp(0, 1),
          );
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _epubError = error.toString());
    }
  }

  @override
  void dispose() {
    if (widget.item.extension == 'pdf') {
      _saveProgress();
    } else if (_epubScrollController.hasClients) {
      final max = _epubScrollController.position.maxScrollExtent;
      ref.read(appDatabaseProvider).saveBookReadingState(
            BookReadingState(
              mediaPath: widget.item.path,
              progress: max == 0 ? 0 : _epubScrollController.offset / max,
              epubCfi: 'chapter:$_epubChapter',
              updatedAt: DateTime.now(),
            ),
          );
    }
    _pdfController?.dispose();
    _epubScrollController.removeListener(_updateEpubChapter);
    _epubScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final bookmarks =
        await ref.read(appDatabaseProvider).getBookBookmarks(widget.item.path);
    if (mounted) setState(() => _bookmarks = bookmarks);
  }

  void _updateEpubChapter() {
    final book = _epubBook;
    if (book == null || !_epubScrollController.hasClients) return;
    final max = _epubScrollController.position.maxScrollExtent;
    if (max <= 0 || book.chapters.isEmpty) return;
    final chapter = (_epubScrollController.offset / max * book.chapters.length)
        .floor()
        .clamp(0, book.chapters.length - 1);
    if (chapter != _epubChapter && mounted) {
      setState(() => _epubChapter = chapter);
    }
  }

  Future<void> _toggleBookmark() async {
    if (_epubBook == null) return;
    final locator = 'chapter:$_epubChapter';
    final existing = _bookmarks.where((item) => item.locator == locator);
    if (existing.isEmpty) {
      final chapter = _epubBook!.chapters[_epubChapter];
      await ref.read(appDatabaseProvider).saveBookBookmark(BookBookmark(
            mediaPath: widget.item.path,
            locator: locator,
            title: chapter.title,
            excerpt: chapter.searchText
                .substring(0, chapter.searchText.length.clamp(0, 120)),
            createdAt: DateTime.now(),
          ));
    } else {
      await ref
          .read(appDatabaseProvider)
          .deleteBookBookmark(widget.item.path, locator);
    }
    await _loadBookmarks();
  }

  void _jumpToChapter(int index) {
    if (index < 0 || index >= _epubKeys.length) return;
    setState(() => _epubChapter = index);
    final target = _epubKeys[index].currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    } else if (_epubScrollController.hasClients) {
      final max = _epubScrollController.position.maxScrollExtent;
      _epubScrollController.animateTo(
        max * index / _epubKeys.length,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _showBookmarks() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: _bookmarks.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('暂无书签')),
              )
            : ListView.builder(
                itemCount: _bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = _bookmarks[index];
                  final chapter = int.tryParse(
                          bookmark.locator.replaceFirst('chapter:', '')) ??
                      0;
                  return ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: Text(bookmark.title ?? '第 ${chapter + 1} 章'),
                    subtitle: Text(bookmark.excerpt ?? ''),
                    onTap: () {
                      Navigator.pop(context);
                      _jumpToChapter(chapter);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await ref.read(appDatabaseProvider).deleteBookBookmark(
                            widget.item.path, bookmark.locator);
                        await _loadBookmarks();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showToc() async {
    final book = _epubBook;
    if (book == null) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView.builder(
          itemCount: book.chapters.length,
          itemBuilder: (context, index) => ListTile(
            contentPadding: EdgeInsets.only(
                left: 16.0 + book.chapters[index].depth * 18.0, right: 16),
            title: Text(book.chapters[index].title),
            selected: index == _epubChapter,
            onTap: () {
              Navigator.pop(context);
              _jumpToChapter(index);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showSearchDialog() async {
    _searchController.clear();
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final query = _searchController.text.trim();
          final results = _epubBook?.chapters
                  .asMap()
                  .entries
                  .where((entry) =>
                      query.isNotEmpty &&
                      entry.value.searchText
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                  .toList() ??
              [];
          return AlertDialog(
            title: const Text('搜索正文'),
            content: SizedBox(
              width: 480,
              height: 360,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: const InputDecoration(
                        hintText: '输入关键词', prefixIcon: Icon(Icons.search)),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final entry = results[index];
                        final match = entry.value.document.search(query).first;
                        return ListTile(
                          title: Text(entry.value.title),
                          subtitle: Text(match.preview, maxLines: 2),
                          onTap: () {
                            Navigator.pop(context);
                            _jumpToChapter(entry.key);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final background = switch (settings.bookTheme) {
      BookTheme.light => Colors.white,
      BookTheme.dark => const Color(0xff171717),
      BookTheme.sepia => const Color(0xfffff3d6),
    };
    final isEpub = widget.item.extension != 'pdf';
    final hasBookmark =
        _bookmarks.any((item) => item.locator == 'chapter:$_epubChapter');
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text(widget.item.title ?? widget.item.name),
        actions: [
          if (isEpub) ...[
            IconButton(onPressed: _showToc, icon: const Icon(Icons.list_alt)),
            IconButton(
                onPressed: _showSearchDialog, icon: const Icon(Icons.search)),
            IconButton(
                onPressed: _toggleBookmark,
                icon:
                    Icon(hasBookmark ? Icons.bookmark : Icons.bookmark_border)),
            IconButton(
                onPressed: _showBookmarks,
                icon: const Icon(Icons.bookmarks_outlined)),
          ],
          if (isEpub)
            IconButton(
              onPressed: () => _showReaderSettings(settings),
              icon: const Icon(Icons.text_format),
            ),
        ],
      ),
      body: BookReaderInput(
        axis: settings.bookPageMode == BookPageMode.horizontal
            ? Axis.horizontal
            : Axis.vertical,
        onPrevious: _previous,
        onNext: _next,
        onScroll: _scroll,
        child: widget.item.extension == 'pdf'
            ? (_pdfController == null
                ? const Center(child: CircularProgressIndicator())
                : PdfView(
                    controller: _pdfController!,
                    scrollDirection:
                        settings.bookPageMode == BookPageMode.horizontal
                            ? Axis.horizontal
                            : Axis.vertical,
                    onPageChanged: (page) {
                      _pdfPage = page;
                      _saveProgress(page: page);
                    },
                  ))
            : _buildEpubView(settings),
      ),
    );
  }

  void _previous() {
    if (widget.item.extension == 'pdf') {
      _pdfController?.previousPage(
          duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    } else if (_epubBook != null) {
      _epubScrollController.animateTo(
        (_epubScrollController.offset - MediaQuery.sizeOf(context).height * .8)
            .clamp(0, _epubScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  void _next() {
    if (widget.item.extension == 'pdf') {
      _pdfController?.nextPage(
          duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    } else if (_epubBook != null) {
      _epubScrollController.animateTo(
        (_epubScrollController.offset + MediaQuery.sizeOf(context).height * .8)
            .clamp(0, _epubScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _scroll(double delta) async {
    if (widget.item.extension == 'pdf') {
      if (delta > 0) _next();
      if (delta < 0) _previous();
    } else if (delta > 0) {
      _next();
    } else if (delta < 0) {
      _previous();
    }
  }

  Future<void> _showReaderSettings(AppSettings settings) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final current = ref.watch(settingsProvider);
          final notifier = ref.read(settingsProvider.notifier);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SegmentedButton<BookTheme>(
                  segments: const [
                    ButtonSegment(value: BookTheme.light, label: Text('浅色')),
                    ButtonSegment(value: BookTheme.sepia, label: Text('护眼')),
                    ButtonSegment(value: BookTheme.dark, label: Text('深色')),
                  ],
                  selected: {current.bookTheme},
                  onSelectionChanged: (value) =>
                      notifier.setBookTheme(value.first),
                ),
                Row(children: [
                  const Icon(Icons.text_decrease),
                  Expanded(
                    child: Slider(
                      min: 12,
                      max: 28,
                      divisions: 8,
                      value: current.bookFontSize,
                      label: current.bookFontSize.toInt().toString(),
                      onChanged: notifier.setBookFontSize,
                    ),
                  ),
                  const Icon(Icons.text_increase),
                ]),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEpubView(AppSettings settings) {
    if (_epubError != null) return Center(child: Text('EPUB 打开失败：$_epubError'));
    final book = _epubBook;
    if (book == null) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      controller: _epubScrollController,
      padding: const EdgeInsets.all(24),
      itemCount: book.chapters.length,
      itemBuilder: (context, index) {
        final chapter = book.chapters[index];
        return Padding(
          key: _epubKeys[index],
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chapter.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: settings.bookFontSize + 4,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...chapter.document.blocks.map((block) {
                if (block.isBreak) return const SizedBox(height: 8);
                final isHeading = block.type == EpubHtmlBlockType.heading;
                final prefix = block.type == EpubHtmlBlockType.listItem
                    ? (block.ordered ? '${block.index}. ' : '• ')
                    : '';
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isHeading ? 10 : 8,
                    left: block.type == EpubHtmlBlockType.listItem ? 16 : 0,
                  ),
                  child: Text(
                    '$prefix${block.text}',
                    style: TextStyle(
                      fontSize: isHeading
                          ? settings.bookFontSize + 2
                          : settings.bookFontSize,
                      height: 1.7,
                      fontWeight: isHeading ? FontWeight.w700 : FontWeight.w400,
                      color: backgroundColorFor(settings.bookTheme),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Color backgroundColorFor(BookTheme theme) => switch (theme) {
        BookTheme.light => Colors.black87,
        BookTheme.dark => Colors.white70,
        BookTheme.sepia => const Color(0xff5a4630),
      };
}
