import 'package:get/get.dart';
import 'package:restaurant_order/controller/restaurant_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestaurantController>(() => RestaurantController());
  }
}
