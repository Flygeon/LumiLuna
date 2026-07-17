import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';

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

/// Append a crash record to `crash_log.txt` in the app support directory so
/// the user can inspect it after a release-mode crash (where there is no
/// console attached to see stderr).
Future<void> _writeCrashLog(String kind, Object error, StackTrace? stack) async {
  try {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}crash_log.txt');
    final entry = '\n==== $kind @ ${DateTime.now().toIso8601String()} ====\n'
        'ERROR: $error\n'
        'STACK: ${stack ?? "(no stack)"}\n';
    await file.writeAsString(entry, mode: FileMode.append);
  } catch (_) {
    // Best-effort — never let logging itself throw.
  }
}

void main() {
  // ── Crash visibility ─────────────────────────────────────────────────────
  // Run the entire app inside a guarded zone so that *every* unhandled
  // exception — synchronous widget build errors, async Future rejections,
  // microtask errors — gets logged to a file (crash_log.txt in the app
  // support dir) and to stderr.  Combined with the ErrorWidget.builder below,
  // this turns the mysterious "grey screen after sort" into a concrete error
  // message + stack trace that can be inspected even in release mode.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Pipe framework-level errors (widget build, layout, paint) into the
      // same crash log so they aren't lost in release mode.
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        // ignore: avoid_print
        print('FlutterError: ${details.exception}\n${details.stack}');
        _writeCrashLog('FlutterError', details.exception, details.stack);
      };

      // Required by media_kit before any Player is created.
      MediaKit.ensureInitialized();

      // Release builds silently replace any widget whose build() throws with
      // a grey screen (ErrorWidget's default).  Replace it with a red screen
      // that prints the exception + stack trace so the root cause is visible
      // instead of a mysterious blank UI.
      ErrorWidget.builder = (FlutterErrorDetails details) {
        _writeCrashLog('ErrorWidget', details.exception, details.stack);
        return Material(
          color: const Color(0xFFB71C1C),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Widget build error',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    '${details.exception}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    '${details.stack ?? ""}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      };

      String? startupError;

      // Initialise the Drift database. On Windows it uses sqlite3 via dart:ffi.
      try {
        final db = AppDatabase();
        await db.customStatement('SELECT 1');
        db.close();
      } catch (e) {
        startupError = '数据库初始化失败: $e';
        // ignore: avoid_print
        print(startupError);
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
    },
    (error, stack) {
      // Catch-all for anything that escaped Flutter's normal error handling
      // (async callbacks, isolate messages, etc.).  Without this the
      // grey-screen bug is invisible — the exception is dropped on the floor.
      // ignore: avoid_print
      print('Uncaught: $error\n$stack');
      _writeCrashLog('Uncaught', error, stack);
    },
  );
}
