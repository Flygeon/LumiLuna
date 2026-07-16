import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'providers/settings_provider.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Required by media_kit before any Player is created.
  MediaKit.ensureInitialized();

  // Initialise the metadata_god Rust backend so audio tags can be read.
  await MetadataGod.initialize();

  // The bundled Noto Sans SC font is declared in pubspec.yaml and loaded
  // automatically by Flutter — no runtime initialization needed here.

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
