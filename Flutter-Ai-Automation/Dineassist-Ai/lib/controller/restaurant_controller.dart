import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_order/configuration/rest_service.dart';
import 'package:restaurant_order/controller/printer_controller.dart';
import 'package:restaurant_order/model/order_model.dart';
import 'package:restaurant_order/view/widgets/bill_receipt.dart';
import 'package:speech_to_text/speech_to_text.dart';

class RestaurantController extends GetxController {
  final RestaurantApiService api = RestaurantApiService();
  final PrinterController printerController = Get.put(PrinterController());

  final SpeechToText speech = SpeechToText();

  TextEditingController orderController = TextEditingController();

  RxBool isListening = false.obs;

  RxBool isLoading = false.obs;

  Rxn<RestaurantOrderModel> orderResult = Rxn<RestaurantOrderModel>();
  RxString tableId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initSpeech();
  }

  Future<void> initSpeech() async {
    await speech.initialize();
  }

  Future<void> startListening() async {
    isListening.value = true;

    await speech.listen(
      onResult: (result) {
        orderController.text = result.recognizedWords;
      },
    );
  }

  Future<void> stopListening() async {
    await speech.stop();

    isListening.value = false;
  }

  RxMap<String, int> cart = <String, int>{}.obs;

  void addToCart(String itemName) {
    if (cart.containsKey(itemName)) {
      cart[itemName] = cart[itemName]! + 1;
    } else {
      cart[itemName] = 1;
    }
    updateOrderTextFromCart();
  }

  void removeFromCart(String itemName) {
    if (cart.containsKey(itemName)) {
      if (cart[itemName] == 1) {
        cart.remove(itemName);
      } else {
        cart[itemName] = cart[itemName]! - 1;
      }
      updateOrderTextFromCart();
    }
  }

  void updateOrderTextFromCart() {
    if (cart.isEmpty) {
      orderController.text = '';
      return;
    }
    String orderStr = cart.entries.map((e) => '${e.value} ${e.key}').join(', ');
    orderController.text = orderStr;
  }

  Future<void> sendOrder() async {
    if (orderController.text.isEmpty && cart.isEmpty) {
      Get.snackbar('Empty Order', 'Please select some items or speak your order.');
      return;
    }

    isLoading.value = true;

    try {
      final response = await api.sendOrder(orderController.text, tableId: tableId.value);
      orderResult.value = RestaurantOrderModel.fromJson(response);

      // Clear cart after successful order
      cart.clear();

      // Show animated receipt popup
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BillReceipt(order: orderResult.value!),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Close Button
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 20),
                  // Print Button
                  ElevatedButton.icon(
                    onPressed: () => printerController.printOrder(orderResult.value!, tableId.value),
                    icon: const Icon(Icons.print_rounded),
                    label: const Text("Print Receipt"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB800),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        transitionCurve: Curves.easeOutBack,
        transitionDuration: const Duration(milliseconds: 600),
      );
    } catch (e) {
      print(e.toString());
      Get.snackbar('Error', e.toString());
    }

    isLoading.value = false;
  }
}
