import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_order/controller/restaurant_controller.dart';
import 'package:restaurant_order/routes/app_routes.dart';
import 'package:restaurant_order/view/widgets/menu_item_card.dart';

class RestaurantScreen extends StatelessWidget {
  RestaurantScreen({super.key, this.tableId});

  final String? tableId;
  final RestaurantController controller = Get.find<RestaurantController>();

  @override
  Widget build(BuildContext context) {
    if (tableId != null && tableId!.isNotEmpty) {
      controller.tableId.value = tableId!;
    }
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // Background Gradient/Image effect
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFB800).withOpacity(0.1),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'DineAssist AI',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Builder(builder: (context) {
                            final displayTableId =
                                tableId ?? controller.tableId.value;
                            if (displayTableId.isEmpty) return const SizedBox();
                            return Row(
                              children: [
                                Text(
                                  'Table $displayTableId',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFFFB800),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (!GetPlatform.isWeb) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () =>
                                        Get.offNamed(AppRoutes.tableSelection),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFB800)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFFFB800)
                                                .withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        'Change',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFFFFB800),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          }),
                        ],
                      ),
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=12',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Menu Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Our Specials',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Obx(
                        () => controller.cart.isNotEmpty
                            ? TextButton(
                                onPressed: () => controller.cart.clear(),
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(color: Color(0xFFFFB800)),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 210,
                    child: Obx(
                      () => ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          MenuItemCard(
                            name: 'Burger',
                            price: '120',
                            imagePath: 'assets/images/burger.png',
                            onTap: () => controller.addToCart('Burger'),
                            quantity: controller.cart['Burger'] ?? 0,
                          ),
                          MenuItemCard(
                            name: 'Pizza',
                            price: '250',
                            imagePath: 'assets/images/pizza.png',
                            onTap: () => controller.addToCart('Pizza'),
                            quantity: controller.cart['Pizza'] ?? 0,
                          ),
                          MenuItemCard(
                            name: 'Fries',
                            price: '40',
                            imagePath: 'assets/images/fries.png',
                            onTap: () => controller.addToCart('Fries'),
                            quantity: controller.cart['Fries'] ?? 0,
                          ),
                          MenuItemCard(
                            name: 'Coke',
                            price: '40',
                            imagePath: 'assets/images/coke.png',
                            onTap: () => controller.addToCart('Coke'),
                            quantity: controller.cart['Coke'] ?? 0,
                          ),
                          MenuItemCard(
                            name: 'Pepsi',
                            price: '40',
                            imagePath: 'assets/images/pepsi.png',
                            onTap: () => controller.addToCart('Pepsi'),
                            quantity: controller.cart['Pepsi'] ?? 0,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // AI Ordering Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E1E1E),
                          const Color(0xFF1A1A1A).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB800).withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFFFFB800),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'AI Smart Order',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap items above or speak your request!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Input Field
                        TextField(
                          controller: controller.orderController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'e.g. 2 Burger and 1 Coke',
                            hintStyle: const TextStyle(color: Colors.white24),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.3),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 15,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: Obx(
                              () => IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: controller.isListening.value
                                        ? Colors.red.withOpacity(0.2)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    controller.isListening.value
                                        ? Icons.mic
                                        : Icons.mic_none,
                                    color: controller.isListening.value
                                        ? Colors.red
                                        : const Color(0xFFFFB800),
                                  ),
                                ),
                                onPressed: () async {
                                  if (controller.isListening.value) {
                                    await controller.stopListening();
                                  } else {
                                    await controller.startListening();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Place Order Button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: Obx(
                            () => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.sendOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFB800),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 10,
                                shadowColor: const Color(
                                  0xFFFFB800,
                                ).withOpacity(0.3),
                              ),
                              child: controller.isLoading.value
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            strokeWidth: 3,
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        Text(
                                          'Generating Bill...',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.shopping_bag_outlined),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Place Order',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
