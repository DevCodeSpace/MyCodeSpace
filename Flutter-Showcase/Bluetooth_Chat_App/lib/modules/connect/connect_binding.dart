import 'package:get/get.dart';
import 'connect_controller.dart';

class ConnectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectController>(() => ConnectController());
  }
}
