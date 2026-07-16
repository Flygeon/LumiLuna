import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'providers/settings_provider.dart';
import 'services/database/app_database.dart';
import 'services/settings_service.dart';

/// Provider for the Drift-powered database singleton.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provider that exposes any startup error (e.g. DB init failure) to the UI.
final startupErrorProvider = Provider<String?>((ref) => null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Required by media_kit before any Player is created.
  MediaKit.ensureInitialized();

  // The bundled Noto Sans SC font is declared in pubspec.yaml and loaded
  // automatically by Flutter — no runtime initialization needed here.

  String? startupError;

  // Initialise the Drift database. On Windows it uses sqlite3 via dart:ffi.
  // If it ever fails we still start the app (just without persistence).
  try {
    final db = AppDatabase();
    await db.customStatement('SELECT 1');
    db.close();
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
