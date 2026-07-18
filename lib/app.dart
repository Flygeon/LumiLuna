import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumiluna/l10n/generated/app_localizations.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'main.dart';
import 'providers/settings_provider.dart';
import 'services/dynamic_color_service.dart';
import 'widgets/esc_back_scope.dart';
import 'widgets/media_key_shortcuts.dart';

class MediaLibraryApp extends ConsumerWidget {
  const MediaLibraryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // Empty tag -> follow the system locale.
    final locale =
        settings.localeTag.isEmpty ? null : Locale(settings.localeTag);
    final startupError = ref.watch(startupErrorProvider);
    final dynamicColor = ref.watch(dynamicColorProvider).valueOrNull;
    final seed = settings.dynamicColor && dynamicColor != null
        ? Color(dynamicColor)
        : settings.themeSeed == null
            ? null
            : Color(settings.themeSeed!);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(seed),
      darkTheme: AppTheme.dark(seed),
      themeMode: settings.themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: SplashScreen(startupError: startupError),
      // Wrap the whole navigator in an ESC-aware scope. ESC pops the current
      // route (dialog / sub-page / player) exactly like the back button; at
      // the root it shows a short "already at the top level" hint. Local
      // widgets (search bar, lyrics overlay) can intercept ESC themselves by
      // returning `KeyEventResult.handled` from their own Focus handler.
      //
      // `MediaKeyShortcuts` (inner) captures Space / mediaPlayPause to toggle
      // play/pause globally — covers the music player, video player and Home
      // mini-player. EscBackScope is the outermost handler (ESC semantics);
      // non-ESC events pass through it (returns `ignored`) to MediaKeyShortcuts.
      builder: (context, child) => EscBackScope(
        child: MediaKeyShortcuts(child: child!),
      ),
    );
  }
}

final dynamicColorProvider = FutureProvider<int?>(
  (ref) => DynamicColorService.getSeedColor(),
);
