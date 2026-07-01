import 'package:get/get.dart';

import '../../controllers/tv_cast_controller.dart';

/// Registers [TvCastController] with GetX when the '/tv-cast' route is opened.
/// GetX automatically disposes the controller when the user navigates away.
class TvCastBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TvCastController>(() => TvCastController());
  }
}
