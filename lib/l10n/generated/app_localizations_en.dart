// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get homeTitle => 'Library';

  @override
  String get searchHint => 'Search files…';

  @override
  String get search => 'Search';

  @override
  String get clear => 'Clear';

  @override
  String get gridView => 'Grid view';

  @override
  String get listView => 'List view';

  @override
  String get refresh => 'Refresh';

  @override
  String get settings => 'Settings';

  @override
  String get loadingError => 'Failed to load';

  @override
  String get retry => 'Retry';

  @override
  String get typeImage => 'Images';

  @override
  String get typeVideo => 'Videos';

  @override
  String get typeMusic => 'Music';

  @override
  String get groupAlbum => 'Albums';

  @override
  String get groupFolder => 'Folders';

  @override
  String get groupDate => 'Date';

  @override
  String noItems(Object type) {
    return 'No $type files';
  }

  @override
  String noMatch(Object type) {
    return 'No matching $type';
  }

  @override
  String get emptyAddFolderHint =>
      'Open Settings from the top-right menu, add folders to scan, then pull to refresh.';

  @override
  String get tryAnotherKeyword => 'Try another keyword';

  @override
  String get noGroups => 'No groups to show';

  @override
  String get addFolderHint =>
      'Add folders to scan in Settings, then pull to refresh.';

  @override
  String itemsCount(Object count) {
    return '$count items';
  }

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get notPlaying => 'Nothing playing';

  @override
  String playModeTooltip(String mode) {
    return 'Play mode: $mode';
  }

  @override
  String get playModeSequential => 'Sequential';

  @override
  String get playModeLoop => 'Loop';

  @override
  String get playModeShuffle => 'Shuffle';

  @override
  String get playlist => 'Playlist';

  @override
  String get videoTitle => 'Video';

  @override
  String imageCounter(Object current, Object total) {
    return '$current / $total';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get defaultGridView => 'Default grid view';

  @override
  String get offListView => 'List view when turned off';

  @override
  String get mediaGrouping => 'Media grouping';

  @override
  String get scanFoldersTitle => 'Scan folders';

  @override
  String get scanFoldersDesc =>
      'The app scans the following folders recursively for images, videos and music.';

  @override
  String get noFoldersConfigured =>
      'Not configured — default Pictures / Videos / Music folders will be scanned.';

  @override
  String get addFolder => 'Add folder';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get langSystem => 'System';

  @override
  String get langChinese => '简体中文';

  @override
  String get langEnglish => 'English';

  @override
  String get cacheTitle => 'Cache';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get clearingCache => 'Clearing…';

  @override
  String cacheCleared(Object size) {
    return 'Cleared $size of cache';
  }

  @override
  String get about => 'About';

  @override
  String get aboutDesc =>
      'A Material Design media library for browsing and playing local images, videos and music.';

  @override
  String get version => 'Version';

  @override
  String get viewLicenses => 'Open source licenses';

  @override
  String get locateInExplorer => 'Locate in Explorer';

  @override
  String get favorite => 'Favorite';

  @override
  String get unfavorite => 'Unfavorite';

  @override
  String get rename => 'Rename';

  @override
  String get renameTitle => 'Rename file';

  @override
  String get renameHint => 'New filename';

  @override
  String get delete => 'Move to Trash';

  @override
  String confirmDelete(Object name) {
    return 'Move $name to trash?';
  }

  @override
  String confirmDeleteMultiple(Object count) {
    return 'Move $count items to trash?';
  }

  @override
  String confirmPermanentDelete(Object name) {
    return 'Delete $name permanently? This action cannot be undone.';
  }

  @override
  String get confirmEmptyTrash =>
      'Permanently delete all trashed files? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Move to Trash';

  @override
  String get restore => 'Restore';

  @override
  String get deleteForever => 'Delete permanently';

  @override
  String get emptyTrash => 'Empty Trash';

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String get permanentlyDeleted => 'Permanently deleted';

  @override
  String get restored => 'Restored';

  @override
  String movedToTrash(Object name) {
    return 'Moved $name to trash';
  }

  @override
  String operationFailed(Object message) {
    return 'Operation failed: $message';
  }

  @override
  String get favoritesEmpty => 'No favorites yet';

  @override
  String get favoritesEmptyHint =>
      'Right-click any file and select \"Favorite\" to add it here.';

  @override
  String get dropFilesHere => 'Release to import media files';

  @override
  String importedFiles(Object count) {
    return 'Imported $count media files';
  }

  @override
  String importSkippedDuplicates(Object duplicates, Object imported) {
    return 'Imported $imported files and skipped $duplicates duplicates';
  }

  @override
  String get playHistory => 'Play History';

  @override
  String get playHistoryEmpty => 'No play history yet';

  @override
  String get playHistoryEmptyHint => 'Media files you play will appear here.';

  @override
  String get clearHistoryConfirmTitle => 'Clear Play History';

  @override
  String get clearHistoryConfirmBody =>
      'Are you sure you want to clear all play records? This action cannot be undone.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingPrevious => 'Previous';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get onboardingWelcomeTitle => 'Welcome to LumiLuna';

  @override
  String get onboardingWelcomeBody =>
      'Browse, organize, and enjoy your photos, videos, and music in one elegant media library.';

  @override
  String get onboardingLibraryTitle => 'Automatic Media Organization';

  @override
  String get onboardingLibraryBody =>
      'The app scans your default media folders, and you can add more folders in Settings. Media is automatically sorted into photo, video, and music tabs.';

  @override
  String get onboardingPlaybackTitle => 'Immersive Playback';

  @override
  String get onboardingPlaybackBody =>
      'Open photos, play videos continuously, or manage your music queue. Play history helps you quickly find recent content.';

  @override
  String get onboardingOrganizeTitle => 'Manage Your Collection';

  @override
  String get onboardingOrganizeBody =>
      'Long-press media to select multiple items, then favorite, delete, tag, or add them to playlists.';

  @override
  String get sort => 'Sort';

  @override
  String get sortModified => 'Modified date';

  @override
  String get sortName => 'Name';

  @override
  String get sortSize => 'File size';

  @override
  String get sortDuration => 'Duration';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get playbackSpeed => 'Playback speed';
}
