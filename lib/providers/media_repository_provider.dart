import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/media_repository.dart';

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository();
});
