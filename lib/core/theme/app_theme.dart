import 'package:flutter/material.dart';

/// Material 3 light & dark themes for the app.
class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF527A72);

  static ThemeData light([Color? seed]) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed ?? _seed,
      brightness: Brightness.light,
    );
    return _base(scheme);
  }

  static ThemeData dark([Color? seed]) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed ?? _seed,
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      // Bundled Simplified-Chinese font (Noto Sans SC / 思源黑体) declared
      // in pubspec.yaml. Improves Chinese rendering on Windows desktop.
      fontFamily: 'NotoSansSC',
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
