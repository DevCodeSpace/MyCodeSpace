// lib/services/app_lifecycle_helper.dart
import 'app_lifecycle_stub.dart'
    if (dart.library.html) 'app_lifecycle_web.dart';

class AppLifecycleHelper {
  static void registerUnloadHandler(void Function() onUnload) {
    registerWebUnloadHandler(onUnload);
  }
}
