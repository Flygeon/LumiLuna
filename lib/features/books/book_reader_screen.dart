import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import 'package:epub_pro/epub_pro.dart';

import '../../models/media_item.dart';
import '../../providers/settings_provider.dart';

class BookReaderScreen extends ConsumerStatefulWidget {
  final MediaItem item;

  const BookReaderScreen({super.key, required this.item});

  @override
  ConsumerState<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends ConsumerState<BookReaderScreen> {
  PdfController? _pdfController;
  EpubBook? _epubBook;
  String? _epubError;

  @override
  void initState() {
    super.initState();
    if (widget.item.extension == 'pdf') {
      _pdfController =
          PdfController(document: PdfDocument.openFile(widget.item.path));
    } else {
      _loadEpub();
    }
  }

  Future<void> _loadEpub() async {
    try {
      final book = await EpubReader.readBook(await File(widget.item.path).readAsBytes());
      if (!mounted) return;
      setState(() => _epubBook = book);
    } catch (error) {
      if (!mounted) return;
      setState(() => _epubError = error.toString());
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
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
      body: widget.item.extension == 'pdf'
          ? PdfView(controller: _pdfController!)
          : _buildEpubView(settings),
    );
  }

  Widget _buildEpubView(AppSettings settings) {
    if (_epubError != null) return Center(child: Text('EPUB 打开失败：$_epubError'));
    final book = _epubBook;
    if (book == null) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
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
                  style: TextStyle(fontSize: settings.bookFontSize, height: 1.7)),
            ],
          ),
        );
      },
    );
  }

  String _plainText(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
