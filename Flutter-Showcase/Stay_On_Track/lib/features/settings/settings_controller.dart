import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:track_app_usage/core/services/usage_service.dart';
import 'package:track_app_usage/core/theme/colors.dart';
import 'package:track_app_usage/core/theme/text_styles.dart';
import 'package:track_app_usage/core/widgets/glass_button.dart';

class SettingsController extends GetxController {
  final RxBool notifyAlerts = true.obs;
  final RxBool focusReminder = false.obs;
  final usageService = Get.find<UsageService>();

  void showGoalPicker() {
    double currentMinutes = usageService.stats.value.totalGoalMinutes;
    RxInt selectedHours = (currentMinutes ~/ 60).obs;
    RxInt selectedMins = (((currentMinutes % 60) / 15).round() * 15).obs;
    if (selectedMins.value >= 60) {
      selectedMins.value = 45;
    }

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: GlacierColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      Container(
        height: Get.height * 0.63,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: GlacierColors.outlineVariant.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),

            // Title
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(color: GlacierColors.primary, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(width: 10),
                Text('Set Daily Goal', style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Choose your target screen time per day', style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.7))),
            const SizedBox(height: 28),

            // Picker row
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  // Hours wheel
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: selectedHours.value),
                      itemExtent: 44,
                      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: GlacierColors.primary.withValues(alpha: 0.08)),
                      onSelectedItemChanged: (i) => selectedHours.value = i,
                      children: List.generate(
                        13,
                        (i) => Center(
                          child: Text(
                            '$i h',
                            style: GlacierTextStyles.bodyLarge.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Divider
                  Container(width: 1, height: 120, color: GlacierColors.outlineVariant.withValues(alpha: 0.2)),

                  // Minutes wheel (0, 15, 30, 45)
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(initialItem: selectedMins ~/ 15),
                      itemExtent: 44,
                      selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: GlacierColors.primary.withValues(alpha: 0.08)),
                      onSelectedItemChanged: (i) => selectedMins.value = i * 15,
                      children: List.generate(
                        4,
                        (i) => Center(
                          child: Text(
                            '${i * 15} m',
                            style: GlacierTextStyles.bodyLarge.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Preview chip
            Obx(() {
              final h = selectedHours.value;
              final m = selectedMins.value;
              final label = h == 0 && m == 0
                  ? 'Not Allowed!!'
                  : h > 0 && m > 0
                  ? '${h}h ${m}m per day'
                  : h > 0
                  ? '${h}h per day'
                  : '${m}m per day';
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  key: ValueKey('$h:$m'),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: GlacierColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    label,
                    style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Save button
            Obx(() => GlassButton(text: "Save", onPressed: selectedHours.value == 0 && selectedMins.value == 0 ? null : () => saveGoal(selectedHours.value, selectedMins.value))),
          ],
        ),
      ),
    );
  }

  void saveGoal(int hours, int mins) async {
    final total = (hours * 60 + mins).clamp(5, 720).toDouble();
    if (total == usageService.stats.value.totalGoalMinutes) {
      Get.back();
      return;
    }
    await usageService.setDailyGoal(total);
    Get.back();
    Get.snackbar(
      'Goal Updated',
      'Daily goal set to ${[if (hours > 0) '$hours ${hours == 1 ? 'hour' : 'hours'}', if (mins > 0) '$mins mins'].join(' ')}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: GlacierColors.surfaceContainerHigh.withValues(alpha: 0.95),
      colorText: GlacierColors.onSurface,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
    );
  }
}
