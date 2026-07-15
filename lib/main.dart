import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'providers/settings_provider.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Required by media_kit before any Player is created.
  MediaKit.ensureInitialized();

  final settingsService = await SettingsService.create();

  runApp(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const MediaLibraryApp(),
    ),
  );
}
