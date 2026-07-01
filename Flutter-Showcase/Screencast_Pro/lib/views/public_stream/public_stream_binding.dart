import 'package:get/get.dart';

import '../../controllers/public_stream_controller.dart';

/// Registers the browser-casting controller for the public stream route.
class PublicStreamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PublicStreamController>(() => PublicStreamController());
  }
}
