import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mouse_demo/controllers/device_list_controller.dart';
import 'package:mouse_demo/theme/app_colors.dart';

class ScanningWidget extends GetView<DeviceListController> {
  const ScanningWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic Colors
    final Color textColor = isDark ? AppColors.textLight : Colors.black87;
    final Color elementColor = isDark ? Colors.white : Colors.black;
    final Color borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final Color errorBgColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              width: 300,
              child: Lottie.asset(
                'assets/lottie/scanning.json',
                frameRate: const FrameRate(60),
                errorBuilder: (context, error, stackTrace) => Container(
                  color: errorBgColor,
                  child: Center(
                    child: Text("Lottie Animation Here", style: TextStyle(color: textColor)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              'Searching for desktops...',
              style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(8),
                color: elementColor.withValues(alpha: 0.02),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi, color: textColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Network: ', style: TextStyle(color: textColor, fontSize: 16)),
                  Obx(
                    () => Text(
                      controller.wifiName.value,
                      style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
