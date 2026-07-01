import 'package:get/get.dart';
import '../../controllers/casting_controller.dart';

class CastingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CastingController>(() => CastingController());
  }
}
