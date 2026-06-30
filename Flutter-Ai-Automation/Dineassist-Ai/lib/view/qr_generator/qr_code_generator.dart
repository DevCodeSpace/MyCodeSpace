import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:restaurant_order/routes/app_routes.dart';

class QRCodeGenerator extends StatelessWidget {
  final String tableId;

  const QRCodeGenerator({super.key, required this.tableId});

  @override
  Widget build(BuildContext context) {
    final baseUrl = kIsWeb ? Uri.base.origin : 'https://restaurant-website.com';
    final orderUrl = Uri.parse(
      '$baseUrl${AppRoutes.order}',
    ).replace(queryParameters: {'table': tableId}).toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Generate QR Code for Table $tableId')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: orderUrl,
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            ),
            SizedBox(height: 20),
            Text(
              'Scan this code at the table!',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(orderUrl, textAlign: TextAlign.center),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Get.toNamed(AppRoutes.order, parameters: {'table': tableId}),
              child: const Text('Open Order Page'),
            ),
          ],
        ),
      ),
    );
  }
}
