import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:epub_pro/epub_pro.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
    final book =
        await EpubReader.readBook(await normalizeEpub(file.readAsBytes()));
    final cover = book.coverImage;
    String? coverPath;
    if (cover != null) {
      coverPath = await _writeCover(
          file, Uint8List.fromList(img.encodeJpg(cover, quality: 85)));
    }
    return BookMetadata(
        title: book.title, author: book.author, coverPath: coverPath);
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
        if (name.toLowerCase().endsWith('.xhtml') ||
            name.toLowerCase().endsWith('.html')) {
          text = _normalizeNavigationLinks(text, name);
        }
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

  static String _normalizeNavigationLinks(String text, String filePath) {
    if (!text.contains('<nav')) return text;
    final directory = filePath.contains('/')
        ? filePath.substring(0, filePath.lastIndexOf('/'))
        : '';
    return text.replaceAllMapped(
        RegExp(r'(\bhref\s*=\s*["\'])([^"\']+)(["\'])',
            caseSensitive: false), (match) {
      final href = match.group(2)!;
      if (href.startsWith('#') || href.contains(':')) return match.group(0)!;
      final target = _epubPath(directory.isEmpty ? href : '$directory/$href');
      return '${match.group(1)}$target${match.group(3)}';
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
