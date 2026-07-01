import 'package:get/get.dart';
import '../../controllers/receiver_controller.dart';

// ReceiverBinding registers ReceiverController with GetX when the receiver
// route is loaded. lazyPut delays instantiation until the controller is first
// accessed, so the service only starts when the Mac receiver screen actually opens.
class ReceiverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReceiverController>(() => ReceiverController());
  }
}
