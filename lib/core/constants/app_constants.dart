import '../../models/media_type.dart';

/// Central place for supported file extensions and layout defaults.
class AppConstants {
  AppConstants._();

  static const String appName = 'LumiLuna';

  /// Supported image file extensions (lowercase, no dot).
  static const Set<String> imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    'heic',
    'heif',
    'tiff',
    'tif',
    'ico',
  };

  /// Supported video file extensions.
  static const Set<String> videoExtensions = {
    'mp4',
    'mkv',
    'avi',
    'mov',
    'wmv',
    'flv',
    'webm',
    'm4v',
    'mpeg',
    'mpg',
    'ts',
    '3gp',
  };

  /// Supported audio file extensions.
  static const Set<String> audioExtensions = {
    'mp3',
    'flac',
    'wav',
    'aac',
    'm4a',
    'ogg',
    'wma',
    'opus',
    'aiff',
    'ape',
  };

  /// Resolve a media type from a file extension (lowercase, no dot).
  /// Returns null when the extension is not a recognised media file.
  static MediaType? typeForExtension(String ext) {
    final e = ext.toLowerCase();
    if (imageExtensions.contains(e)) return MediaType.image;
    if (videoExtensions.contains(e)) return MediaType.video;
    if (audioExtensions.contains(e)) return MediaType.audio;
    return null;
  }

  /// All recognised extensions combined.
  static Set<String> get allExtensions =>
      {...imageExtensions, ...videoExtensions, ...audioExtensions};

  // Grid layout: target tile width used to compute responsive column count.
  static const double gridTargetTileWidth = 180;
  static const double gridMinColumns = 2;
  static const double gridMaxColumns = 8;

  // Thumbnail decode cache width (px) to limit memory usage for large images.
  static const int thumbnailCacheWidth = 300;

  // Max recursion depth when scanning folders (guards against huge trees).
  static const int maxScanDepth = 8;

  // SharedPreferences keys.
  static const String prefThemeMode = 'pref_theme_mode';
  static const String prefThemeSeed = 'pref_theme_seed';
  static const String prefDynamicColor = 'pref_dynamic_color';
  static const String prefViewMode = 'pref_view_mode';
  static const String prefScanFolders = 'pref_scan_folders';
  static const String prefGroupMode = 'pref_group_mode';
  static const String prefLocale = 'pref_locale';
  static const String prefOnboardingCompleted = 'pref_onboarding_completed';
  static const String prefMediaSort = 'pref_media_sort';
  static const String prefMediaSortAscending = 'pref_media_sort_ascending';
  static const String prefImageLayoutDensity = 'pref_image_layout_density';
  static const String prefVideoLayoutDensity = 'pref_video_layout_density';
  static const String prefMusicBackgroundBlur = 'pref_music_background_blur';
  static const String prefLyricsBlur = 'pref_lyrics_blur';
  static const String prefLyricsFontSize = 'pref_lyrics_font_size';

  // Scan cache file name (stored in application support directory).
  static const String cacheFileName = 'lumiluna_cache.json';

  // Max age of a valid cache before a full rescan is triggered (hours).
  static const int cacheMaxAgeHours = 24;

  // Cache directory constants
  static const String cacheRootName = 'lumiluna_cache';
  static const String cacheThumbnailsDir = 'thumbnails';
  static const String cacheVideoThumbsDir = 'video_thumbs';
  static const String cacheArtworkDir = 'artwork';

  // Trash / recycle bin.
  static const String trashManifestName = 'lumiluna_trash.json';
  static const String trashDirName = 'lumiluna_trash';
}
