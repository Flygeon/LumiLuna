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

  int? getThemeSeed() => _prefs.getInt(AppConstants.prefThemeSeed);

  Future<void> setThemeSeed(int? seed) async {
    if (seed == null) {
      await _prefs.remove(AppConstants.prefThemeSeed);
    } else {
      await _prefs.setInt(AppConstants.prefThemeSeed, seed);
    }
  }

  bool getDynamicColor() =>
      _prefs.getBool(AppConstants.prefDynamicColor) ?? false;

  Future<void> setDynamicColor(bool enabled) async {
    await _prefs.setBool(AppConstants.prefDynamicColor, enabled);
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

  // ---- UI language (empty string = follow system) ----
  String getLocale() => _prefs.getString(AppConstants.prefLocale) ?? '';

  Future<void> setLocale(String tag) async {
    await _prefs.setString(AppConstants.prefLocale, tag);
  }

  bool getOnboardingCompleted() =>
      _prefs.getBool(AppConstants.prefOnboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(AppConstants.prefOnboardingCompleted, completed);
  }

  String getMediaSort() =>
      _prefs.getString(AppConstants.prefMediaSort) ?? 'modified';

  Future<void> setMediaSort(String sort) async {
    await _prefs.setString(AppConstants.prefMediaSort, sort);
  }

  bool getMediaSortAscending() =>
      _prefs.getBool(AppConstants.prefMediaSortAscending) ?? false;

  Future<void> setMediaSortAscending(bool ascending) async {
    await _prefs.setBool(AppConstants.prefMediaSortAscending, ascending);
  }

  String getImageLayoutDensity() =>
      _prefs.getString(AppConstants.prefImageLayoutDensity) ?? 'standard';

  Future<void> setImageLayoutDensity(String density) async {
    await _prefs.setString(AppConstants.prefImageLayoutDensity, density);
  }

  String getVideoLayoutDensity() =>
      _prefs.getString(AppConstants.prefVideoLayoutDensity) ?? 'standard';

  Future<void> setVideoLayoutDensity(String density) async {
    await _prefs.setString(AppConstants.prefVideoLayoutDensity, density);
  }

  bool getMusicBackgroundBlur() =>
      _prefs.getBool(AppConstants.prefMusicBackgroundBlur) ?? true;

  Future<void> setMusicBackgroundBlur(bool enabled) async {
    await _prefs.setBool(AppConstants.prefMusicBackgroundBlur, enabled);
  }

  bool getMusicDynamicBackground() =>
      _prefs.getBool(AppConstants.prefMusicDynamicBackground) ?? true;

  Future<void> setMusicDynamicBackground(bool enabled) async =>
      _prefs.setBool(AppConstants.prefMusicDynamicBackground, enabled);

  double getMusicAnimationIntensity() =>
      _prefs.getDouble(AppConstants.prefMusicAnimationIntensity) ?? 1;

  Future<void> setMusicAnimationIntensity(double value) async =>
      _prefs.setDouble(AppConstants.prefMusicAnimationIntensity, value);

  double getMusicLyricsFontSize() =>
      _prefs.getDouble(AppConstants.prefMusicLyricsFontSize) ?? 22;

  Future<void> setMusicLyricsFontSize(double value) async =>
      _prefs.setDouble(AppConstants.prefMusicLyricsFontSize, value);

  int getMusicLyricsOffset() =>
      _prefs.getInt(AppConstants.prefMusicLyricsOffset) ?? 0;

  Future<void> setMusicLyricsOffset(int value) async =>
      _prefs.setInt(AppConstants.prefMusicLyricsOffset, value);

  double getMusicDefaultVolume() =>
      _prefs.getDouble(AppConstants.prefMusicDefaultVolume) ?? 100;

  Future<void> setMusicDefaultVolume(double value) async =>
      _prefs.setDouble(AppConstants.prefMusicDefaultVolume, value);

  double getMusicDefaultRate() =>
      _prefs.getDouble(AppConstants.prefMusicDefaultRate) ?? 1;

  Future<void> setMusicDefaultRate(double value) async =>
      _prefs.setDouble(AppConstants.prefMusicDefaultRate, value);

  bool getMusicAutoPlay() =>
      _prefs.getBool(AppConstants.prefMusicAutoPlay) ?? true;

  Future<void> setMusicAutoPlay(bool enabled) async =>
      _prefs.setBool(AppConstants.prefMusicAutoPlay, enabled);
}
