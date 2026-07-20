import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumiluna/services/rust_scanner_service.dart';

void main() {
  setUp(RustScannerService.reset);

  test('Rust ping returns pong when native library is available', () async {
    try {
      expect(await RustScannerService().ping(), 'pong');
    } on Object catch (error) {
      expect(error.toString(), anyOf(contains('dynamic library'), contains('Unsupported')));
    }
  });

  test('stable hash is deterministic when native library is available', () async {
    try {
      final service = RustScannerService();
      final first = await service.stableHash('same-path');
      final second = await service.stableHash('same-path');
      expect(first, second);
    } on Object catch (error) {
      expect(error.toString(), anyOf(contains('dynamic library'), contains('Unsupported')));
    }
  });
}
