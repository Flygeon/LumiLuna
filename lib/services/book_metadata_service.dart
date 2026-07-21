import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:yaepub/yaepub.dart';

class ParsedEpubChapter {
  final String title;
  final String href;
  final String html;

  const ParsedEpubChapter({
    required this.title,
    required this.href,
    required this.html,
  });
}

class ParsedEpubBook {
  final String title;
  final String author;
  final img.Image? cover;
  final List<ParsedEpubChapter> chapters;

  const ParsedEpubBook({
    required this.title,
    required this.author,
    required this.cover,
    required this.chapters,
  });
}

class BookMetadata {
  final String? title;
  final String? author;
  final String? coverPath;

  const BookMetadata({this.title, this.author, this.coverPath});
}

class BookMetadataService {
  Future<BookMetadata> read(File file) async {
    if (p.extension(file.path).toLowerCase() != '.epub') {
      return const BookMetadata();
    }
    final book = await readEpub(file);
    final cover = book.cover;
    String? coverPath;
    if (cover != null) {
      coverPath = await _writeCover(
          file, Uint8List.fromList(img.encodeJpg(cover, quality: 85)));
    }
    return BookMetadata(
        title: book.title, author: book.author, coverPath: coverPath);
  }

  Future<ParsedEpubBook> readEpub(File file) async {
    final book = Book.from(
      bytes: Uint8List.fromList(await normalizeEpub(file.readAsBytes())),
    );
    final navigation = book.navigation.flatten(level: 99);
    final chapters = book.spine
        .where((item) => item.linear.toLowerCase() != 'no')
        .map((item) {
      final href = item.href;
      final nav = navigation.cast<Xnav?>().firstWhere(
            (item) => item!.href.split('#').first == href,
            orElse: () => null,
          );
      return ParsedEpubChapter(
        title: nav?.label ?? '第 ${book.spine.indexOf(item) + 1} 章',
        href: href,
        html: item.file.asText,
      );
    }).toList();
    final cover =
        book.cover == null ? null : img.decodeImage(book.cover!.content);
    return ParsedEpubBook(
      title: book.title,
      author: book.author,
      cover: cover,
      chapters: chapters,
    );
  }

  Future<String?> _writeCover(File file, Uint8List bytes) async {
    try {
      final path = await coverCachePath(file);
      final output = File(path);
      if (!await output.exists()) await output.writeAsBytes(bytes, flush: true);
      return path;
    } catch (_) {
      return null;
    }
  }

  static Future<List<int>> normalizeEpub(Future<List<int>> source) async {
    final archive = ZipDecoder().decodeBytes(await source);
    final entryNames = archive.map((entry) => _epubPath(entry.name)).toSet();
    final normalized = Archive();
    for (final entry in archive) {
      final name = _epubPath(entry.name);
      List<int> bytes = entry.readBytes() ?? Uint8List(0);
      if (name.toLowerCase().endsWith('.opf') ||
          name.toLowerCase().endsWith('.ncx') ||
          name.toLowerCase().endsWith('.xhtml') ||
          name.toLowerCase().endsWith('.html') ||
          name.toLowerCase().endsWith('.css')) {
        var text = utf8.decode(bytes, allowMalformed: true);
        text = _normalizeNavigationLinks(text, name, entryNames);
        bytes = utf8.encode(text.replaceAll('\\', '/'));
      }
      normalized.addFile(ArchiveFile.bytes(name, bytes));
    }
    return ZipEncoder().encodeBytes(normalized);
  }

  static String _epubPath(String value) {
    final parts = <String>[];
    for (final part in Uri.decodeFull(value.replaceAll('\\', '/')).split('/')) {
      if (part.isEmpty || part == '.') continue;
      if (part == '..') {
        if (parts.isNotEmpty) parts.removeLast();
      } else {
        parts.add(part);
      }
    }
    return parts.join('/');
  }

  static String _normalizeNavigationLinks(
      String text, String filePath, Set<String> entryNames) {
    if (!text.contains('href')) return text;
    final directory = filePath.contains('/')
        ? filePath.substring(0, filePath.lastIndexOf('/'))
        : '';
    final navigationPattern =
        RegExp(r'<(navPoint|li)\b[^>]*>[\s\S]*?</\1\s*>', caseSensitive: false);
    return text.replaceAllMapped(navigationPattern, (match) {
      final block = match.group(0)!;
      final href =
          RegExp(r'''\bhref\s*=\s*["']([^"']+)["']''', caseSensitive: false)
              .firstMatch(block)
              ?.group(1);
      if (href == null || href.startsWith('#') || href.contains(':')) {
        return block;
      }
      final target = _epubPath(
          directory.isEmpty ? href.split('#').first : '$directory/$href');
      final hrefPath = _epubPath(href.split('#').first);
      if (!entryNames.contains(target) &&
          !entryNames.any((name) => name.endsWith('/$hrefPath'))) {
        return '';
      }
      return block.replaceFirstMapped(
        RegExp(r'''(\bhref\s*=\s*["'])[^"']+(["'])''', caseSensitive: false),
        (hrefMatch) => '${hrefMatch.group(1)}$hrefPath${hrefMatch.group(2)}',
      );
    });
  }

  Future<String> coverCachePath(File file) async {
    final dir = await getApplicationSupportDirectory();
    final cache = Directory(p.join(dir.path, 'lumiluna_books'));
    await cache.create(recursive: true);
    final stat = await file.stat();
    final key =
        '${file.path}|${stat.size}|${stat.modified.millisecondsSinceEpoch}'
            .codeUnits
            .fold<int>(17, (value, unit) => value * 31 + unit)
            .abs();
    return p.join(cache.path, '$key.jpg');
  }
}
