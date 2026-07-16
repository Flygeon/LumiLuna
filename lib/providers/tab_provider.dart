import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_type.dart';

/// The media type currently shown in the body. Drives which tab's heavy,
/// per-item work (e.g. video frame extraction) is allowed to run.
final activeTypeProvider = StateProvider<MediaType>((ref) => MediaType.image);

/// True only while the tab-switch slide animation is in flight. Heavy work is
/// deferred until this is false, so it never competes with the transition
/// frames.
final tabAnimatingProvider = StateProvider<bool>((ref) => false);
