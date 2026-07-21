import 'package:flutter/widgets.dart';
import 'package:lumiluna/l10n/generated/app_localizations.dart';

import '../models/media_folder.dart';
import '../models/media_type.dart';

/// Ergonomic accessor for the generated [AppLocalizations].
///
/// Usage: `context.l10n.homeTitle` instead of the verbose
/// `AppLocalizations.of(context)!.homeTitle`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Localized label for a [MediaType] (used in nav bar, empty states, etc.).
String mediaTypeName(BuildContext context, MediaType type) {
  final l = AppLocalizations.of(context)!;
  switch (type) {
    case MediaType.image:
      return l.typeImage;
    case MediaType.video:
      return l.typeVideo;
    case MediaType.audio:
      return l.typeMusic;
    case MediaType.book:
      return '图书';
  }
}

/// Localized label for a [GroupMode].
String groupModeName(BuildContext context, GroupMode mode) {
  final l = AppLocalizations.of(context)!;
  switch (mode) {
    case GroupMode.album:
      return l.groupAlbum;
    case GroupMode.folder:
      return l.groupFolder;
    case GroupMode.date:
      return l.groupDate;
  }
}
