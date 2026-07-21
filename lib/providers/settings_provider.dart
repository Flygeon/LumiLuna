import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_folder.dart';
import '../services/settings_service.dart';

/// Provides the [SettingsService]. Overridden in main() after async init.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('settingsServiceProvider must be overridden');
});

enum MediaSortMode { modified, name, size, duration }

enum MediaLayoutDensity { standard, compact }

/// App-wide user settings (theme, view mode, scan folders, grouping).
class AppSettings {
  final ThemeMode themeMode;
  final int? themeSeed;
  final bool dynamicColor;
  final bool autoUpdate;
  final bool isGridView;
  final List<String> scanFolders;
  final GroupMode groupMode;
  final String localeTag;
  final bool onboardingCompleted;
  final MediaSortMode mediaSortMode;
  final bool mediaSortAscending;
  final MediaLayoutDensity imageLayoutDensity;
  final MediaLayoutDensity videoLayoutDensity;
  final bool musicBackgroundBlur;
  final bool lyricsBlur;
  final double lyricsFontSize;

  const AppSettings({
    required this.themeMode,
    this.themeSeed,
    this.dynamicColor = false,
    this.autoUpdate = true,
    required this.isGridView,
    required this.scanFolders,
    required this.groupMode,
    this.localeTag = '',
    this.onboardingCompleted = false,
    this.mediaSortMode = MediaSortMode.modified,
    this.mediaSortAscending = false,
    this.imageLayoutDensity = MediaLayoutDensity.standard,
    this.videoLayoutDensity = MediaLayoutDensity.standard,
    this.musicBackgroundBlur = true,
    this.lyricsBlur = true,
    this.lyricsFontSize = 16.0,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? themeSeed,
    bool? dynamicColor,
    bool? autoUpdate,
    bool? isGridView,
    List<String>? scanFolders,
    GroupMode? groupMode,
    String? localeTag,
    bool? onboardingCompleted,
    MediaSortMode? mediaSortMode,
    bool? mediaSortAscending,
    MediaLayoutDensity? imageLayoutDensity,
    MediaLayoutDensity? videoLayoutDensity,
    bool? musicBackgroundBlur,
    bool? lyricsBlur,
    double? lyricsFontSize,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      themeSeed: themeSeed ?? this.themeSeed,
      dynamicColor: dynamicColor ?? this.dynamicColor,
      autoUpdate: autoUpdate ?? this.autoUpdate,
      isGridView: isGridView ?? this.isGridView,
      scanFolders: scanFolders ?? this.scanFolders,
      groupMode: groupMode ?? this.groupMode,
      localeTag: localeTag ?? this.localeTag,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      mediaSortMode: mediaSortMode ?? this.mediaSortMode,
      mediaSortAscending: mediaSortAscending ?? this.mediaSortAscending,
      imageLayoutDensity: imageLayoutDensity ?? this.imageLayoutDensity,
      videoLayoutDensity: videoLayoutDensity ?? this.videoLayoutDensity,
      musicBackgroundBlur: musicBackgroundBlur ?? this.musicBackgroundBlur,
      lyricsBlur: lyricsBlur ?? this.lyricsBlur,
      lyricsFontSize: lyricsFontSize ?? this.lyricsFontSize,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._service)
      : super(AppSettings(
          themeMode: _service.getThemeMode(),
          themeSeed: _service.getThemeSeed(),
          dynamicColor: _service.getDynamicColor(),
          autoUpdate: _service.getAutoUpdate(),
          isGridView: _service.getIsGridView(),
          scanFolders: _service.getScanFolders(),
          groupMode: _service.getGroupMode(),
          localeTag: _service.getLocale(),
          onboardingCompleted: _service.getOnboardingCompleted(),
          mediaSortMode: MediaSortMode.values.firstWhere(
            (mode) => mode.name == _service.getMediaSort(),
            orElse: () => MediaSortMode.modified,
          ),
          mediaSortAscending: _service.getMediaSortAscending(),
          imageLayoutDensity: _layoutDensity(_service.getImageLayoutDensity()),
          videoLayoutDensity: _layoutDensity(_service.getVideoLayoutDensity()),
          musicBackgroundBlur: _service.getMusicBackgroundBlur(),
          lyricsBlur: _service.getLyricsBlur(),
          lyricsFontSize: _service.getLyricsFontSize(),
        ));

  static MediaLayoutDensity _layoutDensity(String value) =>
      MediaLayoutDensity.values.firstWhere(
        (density) => density.name == value,
        orElse: () => MediaLayoutDensity.standard,
      );

  final SettingsService _service;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _service.setThemeMode(mode);
  }

  Future<void> setThemeSeed(int seed) async {
    state = state.copyWith(themeSeed: seed, dynamicColor: false);
    await _service.setThemeSeed(seed);
    await _service.setDynamicColor(false);
  }

  Future<void> setDynamicColor(bool enabled) async {
    state = state.copyWith(dynamicColor: enabled);
    await _service.setDynamicColor(enabled);
  }

  Future<void> setAutoUpdate(bool enabled) async {
    state = state.copyWith(autoUpdate: enabled);
    await _service.setAutoUpdate(enabled);
  }

  Future<void> setLocale(String tag) async {
    state = state.copyWith(localeTag: tag);
    await _service.setLocale(tag);
  }

  Future<void> toggleView() async {
    final next = !state.isGridView;
    state = state.copyWith(isGridView: next);
    await _service.setIsGridView(next);
  }

  Future<void> setGridView(bool isGrid) async {
    state = state.copyWith(isGridView: isGrid);
    await _service.setIsGridView(isGrid);
  }

  Future<void> setGroupMode(GroupMode mode) async {
    state = state.copyWith(groupMode: mode);
    await _service.setGroupMode(mode);
  }

  Future<void> addFolder(String path) async {
    if (state.scanFolders.contains(path)) return;
    final next = [...state.scanFolders, path];
    state = state.copyWith(scanFolders: next);
    await _service.setScanFolders(next);
  }

  Future<void> removeFolder(String path) async {
    final next = state.scanFolders.where((f) => f != path).toList();
    state = state.copyWith(scanFolders: next);
    await _service.setScanFolders(next);
  }

  Future<void> setFolders(List<String> folders) async {
    state = state.copyWith(scanFolders: folders);
    await _service.setScanFolders(folders);
  }

  Future<void> completeOnboarding() async {
    await _service.setOnboardingCompleted(true);
    state = state.copyWith(onboardingCompleted: true);
  }

  Future<void> setMediaSortMode(MediaSortMode mode) async {
    state = state.copyWith(mediaSortMode: mode);
    await _service.setMediaSort(mode.name);
  }

  Future<void> toggleMediaSortDirection() async {
    final ascending = !state.mediaSortAscending;
    state = state.copyWith(mediaSortAscending: ascending);
    await _service.setMediaSortAscending(ascending);
  }

  Future<void> setImageLayoutDensity(MediaLayoutDensity density) async {
    state = state.copyWith(imageLayoutDensity: density);
    await _service.setImageLayoutDensity(density.name);
  }

  Future<void> setVideoLayoutDensity(MediaLayoutDensity density) async {
    state = state.copyWith(videoLayoutDensity: density);
    await _service.setVideoLayoutDensity(density.name);
  }

  Future<void> setMusicBackgroundBlur(bool enabled) async {
    state = state.copyWith(musicBackgroundBlur: enabled);
    await _service.setMusicBackgroundBlur(enabled);
  }

  Future<void> setLyricsBlur(bool enabled) async {
    state = state.copyWith(lyricsBlur: enabled);
    await _service.setLyricsBlur(enabled);
  }

  Future<void> setLyricsFontSize(double size) async {
    state = state.copyWith(lyricsFontSize: size);
    await _service.setLyricsFontSize(size);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsNotifier(service);
});
