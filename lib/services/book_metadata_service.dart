import 'dart:io';

import 'package:epub_pro/epub_pro.dart';
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
    final book = await EpubReader.readBook(await file.readAsBytes());
    return BookMetadata(title: book.title, author: book.author);
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
