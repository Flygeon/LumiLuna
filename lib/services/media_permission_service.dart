import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class MediaPermissionService {
  static Future<bool> requestForScanning() async {
    if (!Platform.isAndroid) return true;

    final permissions = <Permission>[
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ];
    final statuses = await permissions.request();
    return statuses.values.any(
      (status) => status.isGranted || status.isLimited,
    );
  }
}
