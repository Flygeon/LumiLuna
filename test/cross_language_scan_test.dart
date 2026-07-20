import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiluna/models/media_item.dart';
import 'package:lumiluna/services/media_scanner_service.dart';
import 'package:lumiluna/services/rust_scanner_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Rust and Dart scanners return the same media paths', () async {
    final root = await Directory.systemTemp.createTemp('lumiluna-cross-language-');
    addTearDown(() => root.delete(recursive: true));
    await File('${root.path}${Platform.pathSeparator}photo.jpg').writeAsBytes([1]);
    await File('${root.path}${Platform.pathSeparator}notes.txt').writeAsBytes([1]);

    MediaScannerService.useRustScanning = false;
    final dartItems = await MediaScannerService.scan([root.path]);
    MediaScannerService.useRustScanning = true;

    List<MediaItem> rustItems;
    try {
      rustItems = await RustScannerService().scanMedia([root.path]);
    } on Object catch (error) {
      expect(error.toString(), anyOf(contains('dynamic library'), contains('Unsupported')));
      return;
    }

    expect(
      rustItems.map((item) => item.path).toSet(),
      dartItems.map((item) => item.path).toSet(),
    );
  });
}
