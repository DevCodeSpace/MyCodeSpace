import 'package:flutter/foundation.dart';

// Meeting link format for create meeting dialog (path routing)
String buildCreateMeetingLink(String roomId) {
  if (kIsWeb) {
    final uri = Uri.base;
    return '${uri.origin}${uri.path}/join/$roomId';
  }
  return 'https://webrtc-demo-e307f.web.app/join/$roomId';
}

// Meeting link format for call screen (hash routing)
String buildCallMeetingLink(String roomId) {
  if (kIsWeb) {
    final uri = Uri.base;
    final path = uri.path.endsWith('/') ? uri.path.substring(0, uri.path.length - 1) : uri.path;
    return '${uri.origin}$path/#/join/$roomId';
  }
  return 'https://webrtc-demo-e307f.web.app/#/join/$roomId';
}
