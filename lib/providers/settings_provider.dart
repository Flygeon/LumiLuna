import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_folder.dart';
import '../services/settings_service.dart';

/// Provides the [SettingsService]. Overridden in main() after async init.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('settingsServiceProvider must be overridden');
});

/// App-wide user settings (theme, view mode, scan folders, grouping).
class AppSettings {
  final ThemeMode themeMode;
  final bool isGridView;
  final List<String> scanFolders;
  final GroupMode groupMode;

  const AppSettings({
    required this.themeMode,
    required this.isGridView,
    required this.scanFolders,
    required this.groupMode,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? isGridView,
    List<String>? scanFolders,
    GroupMode? groupMode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      isGridView: isGridView ?? this.isGridView,
      scanFolders: scanFolders ?? this.scanFolders,
      groupMode: groupMode ?? this.groupMode,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._service)
      : super(AppSettings(
          themeMode: _service.getThemeMode(),
          isGridView: _service.getIsGridView(),
          scanFolders: _service.getScanFolders(),
          groupMode: _service.getGroupMode(),
        ));

  final SettingsService _service;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _service.setThemeMode(mode);
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
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsNotifier(service);
});
