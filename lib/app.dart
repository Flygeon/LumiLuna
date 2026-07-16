import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumiluna/l10n/generated/app_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'providers/settings_provider.dart';

class MediaLibraryApp extends ConsumerWidget {
  const MediaLibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // Empty tag -> follow the system locale.
    final locale = settings.localeTag.isEmpty ? null : Locale(settings.localeTag);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
