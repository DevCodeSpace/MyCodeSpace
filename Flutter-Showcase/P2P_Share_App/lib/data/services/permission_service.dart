import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> ensureTransferPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final permissions = <Permission>[
      Permission.storage,
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ];

    final statuses = await permissions.request();
    return statuses.values.any((status) => status.isGranted) ||
        statuses.values.every((status) => !status.isDenied);
  }
}
