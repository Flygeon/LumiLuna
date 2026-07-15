import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/media_folder.dart';

/// Thin wrapper around [SharedPreferences] for persisted settings.
class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  // ---- Theme mode ----
  ThemeMode getThemeMode() {
    final value = _prefs.getString(AppConstants.prefThemeMode);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(AppConstants.prefThemeMode, mode.name);
  }

  // ---- View mode (grid / list) ----
  bool getIsGridView() => _prefs.getBool(AppConstants.prefViewMode) ?? true;

  Future<void> setIsGridView(bool isGrid) async {
    await _prefs.setBool(AppConstants.prefViewMode, isGrid);
  }

  // ---- Scan folders ----
  List<String> getScanFolders() =>
      _prefs.getStringList(AppConstants.prefScanFolders) ?? const [];

  Future<void> setScanFolders(List<String> folders) async {
    await _prefs.setStringList(AppConstants.prefScanFolders, folders);
  }

  // ---- Group mode ----
  GroupMode getGroupMode() {
    final value = _prefs.getString(AppConstants.prefGroupMode);
    return GroupMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => GroupMode.album,
    );
  }

  Future<void> setGroupMode(GroupMode mode) async {
    await _prefs.setString(AppConstants.prefGroupMode, mode.name);
  }
}
