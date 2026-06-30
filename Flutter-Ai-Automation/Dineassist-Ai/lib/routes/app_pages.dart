import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_order/routes/app_bindings.dart';
import 'package:restaurant_order/routes/app_routes.dart';
import 'package:restaurant_order/view/qr_generator/qr_code_generator.dart';
import 'package:restaurant_order/view/restaurant_screen.dart';
import 'package:restaurant_order/view/splash_screen.dart';
import 'package:restaurant_order/view/table_selection_screen.dart';

class AppPages {
  static final unknownRoute = GetPage(
    name: AppRoutes.notFound,
    page: () => const _NotFoundPage(),
  );

  static final routes = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.tableSelection,
      page: () => const TableSelectionScreen(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.order,
      page: () => RestaurantScreen(tableId: Get.parameters['table']),
      binding: OrderBinding(),
    ),
    GetPage(
      name: '${AppRoutes.qr}/:tableId',
      page: () => QRCodeGenerator(tableId: Get.parameters['tableId'] ?? '1'),
    ),
  ];
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('The page you requested does not exist.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
