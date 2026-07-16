import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'providers/settings_provider.dart';
import 'services/database_service.dart';
import 'services/settings_service.dart';

/// Provider that exposes any startup error (e.g. DB init failure) to the UI.
final startupErrorProvider = Provider<String?>((ref) => null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Required by media_kit before any Player is created.
  MediaKit.ensureInitialized();

  // The bundled Noto Sans SC font is declared in pubspec.yaml and loaded
  // automatically by Flutter — no runtime initialization needed here.

  String? startupError;

  // Initialise the SQLite database.  On Windows, sqflite_common_ffi needs
  // sqlite3.dll which is bundled by sqlite3_flutter_libs.  If it ever
  // fails we still start the app (just without persistence).
  try {
    await DatabaseService.database;
  } catch (e) {
    startupError = '数据库初始化失败: $e';
    // ignore: avoid_print
    debugPrint(startupError);
  }

  final settingsService = await SettingsService.create();

  runApp(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(settingsService),
        if (startupError != null)
          startupErrorProvider.overrideWith((ref) => startupError),
      ],
      child: const MediaLibraryApp(),
    ),
  );
}
