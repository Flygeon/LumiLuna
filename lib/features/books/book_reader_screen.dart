import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:epub_pro/epub_pro.dart';
import 'package:image/image.dart' as img;

import '../../models/media_item.dart';
import '../../providers/settings_provider.dart';
import '../../main.dart';
import '../../models/book_reading_state.dart';
import '../../services/book_metadata_service.dart';
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
  EpubBook? _epubBook;
  String? _epubError;
  int _pdfPage = 1;
  int? _pdfPageCount;
  BookReadingState? _savedState;
  int _epubChapter = 0;

  @override
  void initState() {
    super.initState();
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
      if (!await file.exists())
        await file.writeAsBytes(image.bytes, flush: true);
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
      final book = await EpubReader.readBook(
          await BookMetadataService.normalizeEpub(
              File(widget.item.path).readAsBytes()));
      if (book.coverImage != null) {
        final path =
            await BookMetadataService().coverCachePath(File(widget.item.path));
        final coverFile = File(path);
        if (!await coverFile.exists()) {
          await coverFile.writeAsBytes(
              img.encodeJpg(book.coverImage!, quality: 85),
              flush: true);
        }
        await ref
            .read(appDatabaseProvider)
            .updateMediaThumbnail(widget.item.path, path);
      }
      if (!mounted) return;
      setState(() {
        _epubBook = book;
        _epubChapter = _savedState?.epubCfi?.startsWith('chapter:') == true
            ? int.tryParse(_savedState!.epubCfi!.substring(8)) ?? 0
            : 0;
      });
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
    _epubScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final background = switch (settings.bookTheme) {
      BookTheme.light => Colors.white,
      BookTheme.dark => const Color(0xff171717),
      BookTheme.sepia => const Color(0xfffff3d6),
    };
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(title: Text(widget.item.title ?? widget.item.name)),
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
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chapter.title ?? '第 ${index + 1} 章',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(_plainText(chapter.htmlContent ?? ''),
                  style:
                      TextStyle(fontSize: settings.bookFontSize, height: 1.7)),
            ],
          ),
        );
      },
    );
  }

  String _plainText(String html) => html
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
