import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get homeTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search files…'**
  String get searchHint;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get gridView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get listView;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @loadingError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get loadingError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @typeImage.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get typeImage;

  /// No description provided for @typeVideo.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get typeVideo;

  /// No description provided for @typeMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get typeMusic;

  /// No description provided for @groupAlbum.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get groupAlbum;

  /// No description provided for @groupFolder.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get groupFolder;

  /// No description provided for @groupDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get groupDate;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No {type} files'**
  String noItems(Object type);

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching {type}'**
  String noMatch(Object type);

  /// No description provided for @emptyAddFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Open Settings from the top-right menu, add folders to scan, then pull to refresh.'**
  String get emptyAddFolderHint;

  /// No description provided for @tryAnotherKeyword.
  ///
  /// In en, this message translates to:
  /// **'Try another keyword'**
  String get tryAnotherKeyword;

  /// No description provided for @noGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups to show'**
  String get noGroups;

  /// No description provided for @addFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Add folders to scan in Settings, then pull to refresh.'**
  String get addFolderHint;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(Object count);

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @notPlaying.
  ///
  /// In en, this message translates to:
  /// **'Nothing playing'**
  String get notPlaying;

  /// No description provided for @playModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Play mode: {mode}'**
  String playModeTooltip(String mode);

  /// No description provided for @playModeSequential.
  ///
  /// In en, this message translates to:
  /// **'Sequential'**
  String get playModeSequential;

  /// No description provided for @playModeLoop.
  ///
  /// In en, this message translates to:
  /// **'Loop'**
  String get playModeLoop;

  /// No description provided for @playModeShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get playModeShuffle;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'Playlist'**
  String get playlist;

  /// No description provided for @videoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoTitle;

  /// No description provided for @imageCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String imageCounter(Object current, Object total);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @defaultGridView.
  ///
  /// In en, this message translates to:
  /// **'Default grid view'**
  String get defaultGridView;

  /// No description provided for @offListView.
  ///
  /// In en, this message translates to:
  /// **'List view when turned off'**
  String get offListView;

  /// No description provided for @mediaGrouping.
  ///
  /// In en, this message translates to:
  /// **'Media grouping'**
  String get mediaGrouping;

  /// No description provided for @scanFoldersTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan folders'**
  String get scanFoldersTitle;

  /// No description provided for @scanFoldersDesc.
  ///
  /// In en, this message translates to:
  /// **'The app scans the following folders recursively for images, videos and music.'**
  String get scanFoldersDesc;

  /// No description provided for @noFoldersConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured — default Pictures / Videos / Music folders will be scanned.'**
  String get noFoldersConfigured;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addFolder;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @langSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get langSystem;

  /// No description provided for @langChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get langChinese;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @cacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cacheTitle;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @clearingCache.
  ///
  /// In en, this message translates to:
  /// **'Clearing…'**
  String get clearingCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared {size} of cache'**
  String cacheCleared(Object size);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'A Material Design media library for browsing and playing local images, videos and music.'**
  String get aboutDesc;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @viewLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get viewLicenses;

  /// No description provided for @locateInExplorer.
  ///
  /// In en, this message translates to:
  /// **'Locate in Explorer'**
  String get locateInExplorer;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @unfavorite.
  ///
  /// In en, this message translates to:
  /// **'Unfavorite'**
  String get unfavorite;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename file'**
  String get renameTitle;

  /// No description provided for @renameHint.
  ///
  /// In en, this message translates to:
  /// **'New filename'**
  String get renameHint;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get delete;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Move {name} to trash?'**
  String confirmDelete(Object name);

  /// No description provided for @confirmDeleteMultiple.
  ///
  /// In en, this message translates to:
  /// **'Move {count} items to trash?'**
  String confirmDeleteMultiple(Object count);

  /// No description provided for @confirmPermanentDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} permanently? This action cannot be undone.'**
  String confirmPermanentDelete(Object name);

  /// No description provided for @confirmEmptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete all trashed files? This action cannot be undone.'**
  String get confirmEmptyTrash;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get confirm;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteForever;

  /// No description provided for @emptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash'**
  String get emptyTrash;

  /// No description provided for @trashTitle.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trashTitle;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashEmpty;

  /// No description provided for @permanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Permanently deleted'**
  String get permanentlyDeleted;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get restored;

  /// No description provided for @movedToTrash.
  ///
  /// In en, this message translates to:
  /// **'Moved {name} to trash'**
  String movedToTrash(Object name);

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed: {message}'**
  String operationFailed(Object message);

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Right-click any file and select \"Favorite\" to add it here.'**
  String get favoritesEmptyHint;

  /// No description provided for @dropFilesHere.
  ///
  /// In en, this message translates to:
  /// **'Release to import media files'**
  String get dropFilesHere;

  /// No description provided for @importedFiles.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} media files'**
  String importedFiles(Object count);

  /// No description provided for @importSkippedDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Imported {imported} files and skipped {duplicates} duplicates'**
  String importSkippedDuplicates(Object duplicates, Object imported);

  /// No description provided for @playHistory.
  ///
  /// In en, this message translates to:
  /// **'Play History'**
  String get playHistory;

  /// No description provided for @playHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No play history yet'**
  String get playHistoryEmpty;

  /// No description provided for @playHistoryEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Media files you play will appear here.'**
  String get playHistoryEmptyHint;

  /// No description provided for @clearHistoryConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Play History'**
  String get clearHistoryConfirmTitle;

  /// No description provided for @clearHistoryConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all play records? This action cannot be undone.'**
  String get clearHistoryConfirmBody;

  /// No description provided for @alreadyAtTopLevel.
  ///
  /// In en, this message translates to:
  /// **'Already at the top level'**
  String get alreadyAtTopLevel;

  /// No description provided for @escBackHint.
  ///
  /// In en, this message translates to:
  /// **'Press ESC to go back'**
  String get escBackHint;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get onboardingPrevious;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingStart;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to LumiLuna'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Browse, organize, and enjoy your photos, videos, and music in one elegant media library.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic Media Organization'**
  String get onboardingLibraryTitle;

  /// No description provided for @onboardingLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'The app scans your default media folders, and you can add more folders in Settings. Media is automatically sorted into photo, video, and music tabs.'**
  String get onboardingLibraryBody;

  /// No description provided for @onboardingPlaybackTitle.
  ///
  /// In en, this message translates to:
  /// **'Immersive Playback'**
  String get onboardingPlaybackTitle;

  /// No description provided for @onboardingPlaybackBody.
  ///
  /// In en, this message translates to:
  /// **'Open photos, play videos continuously, or manage your music queue. Play history helps you quickly find recent content.'**
  String get onboardingPlaybackBody;

  /// No description provided for @onboardingOrganizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Your Collection'**
  String get onboardingOrganizeTitle;

  /// No description provided for @onboardingOrganizeBody.
  ///
  /// In en, this message translates to:
  /// **'Long-press media to select multiple items, then favorite, delete, tag, or add them to playlists.'**
  String get onboardingOrganizeBody;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortModified.
  ///
  /// In en, this message translates to:
  /// **'Modified date'**
  String get sortModified;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortSize.
  ///
  /// In en, this message translates to:
  /// **'File size'**
  String get sortSize;

  /// No description provided for @sortDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get sortDuration;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDescending;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get playbackSpeed;

  /// No description provided for @imageDetails.
  ///
  /// In en, this message translates to:
  /// **'Image Details'**
  String get imageDetails;

  /// No description provided for @fileInfo.
  ///
  /// In en, this message translates to:
  /// **'File Info'**
  String get fileInfo;

  /// No description provided for @exifMetadata.
  ///
  /// In en, this message translates to:
  /// **'EXIF Metadata'**
  String get exifMetadata;

  /// No description provided for @noExifData.
  ///
  /// In en, this message translates to:
  /// **'No EXIF data available'**
  String get noExifData;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @cameraModel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraModel;

  /// No description provided for @focalLength.
  ///
  /// In en, this message translates to:
  /// **'Focal Length'**
  String get focalLength;

  /// No description provided for @aperture.
  ///
  /// In en, this message translates to:
  /// **'Aperture'**
  String get aperture;

  /// No description provided for @gpsCoordinates.
  ///
  /// In en, this message translates to:
  /// **'GPS Coordinates'**
  String get gpsCoordinates;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @detailsHint.
  ///
  /// In en, this message translates to:
  /// **'View file info and EXIF metadata'**
  String get detailsHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
