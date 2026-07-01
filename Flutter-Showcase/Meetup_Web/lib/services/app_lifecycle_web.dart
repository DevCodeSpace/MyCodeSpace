// lib/services/app_lifecycle_web.dart
import 'dart:js_interop';

import 'package:web/web.dart' as web;

void registerWebUnloadHandler(void Function() onUnload) {
  web.window.onbeforeunload = ((web.Event event) {
    onUnload();
    return 'Are you sure you want to leave the call?'.toJS;
  }).toJS;
}
