import 'dart:io';

import 'package:flutter/services.dart';

class DynamicColorService {
  DynamicColorService._();

  static const _channel = MethodChannel('lumiluna/system_theme');

  static Future<int?> getSeedColor() async {
    if (!Platform.isAndroid) return null;
    return _channel.invokeMethod<int>('getSeedColor');
  }
}
