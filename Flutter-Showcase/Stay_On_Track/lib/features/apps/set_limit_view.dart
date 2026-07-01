import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/models/usage_model.dart';
import '../../core/services/usage_service.dart';
import '../../core/widgets/app_icon_widget.dart';

class SetLimitController extends GetxController {
  final UsageService usageService = Get.find<UsageService>();
  final AppUsageInfo app;

  final RxDouble limitMinutes = 30.0.obs;
  final RxBool repeatDaily = true.obs;
  final RxBool notifyAt80 = true.obs;

  SetLimitController(this.app) {
    if (app.limit != null) {
      limitMinutes.value = app.limit!.limitMinutes;
      repeatDaily.value = app.limit!.repeatDaily;
      notifyAt80.value = app.limit!.notifyAt80;
    }
  }

  void selectPreset(double minutes) {
    limitMinutes.value = minutes;
  }

  Future<void> saveLimit() async {
    await usageService.setLimit(app.id, limitMinutes.value, repeatDaily.value, notifyAt80.value);
    Get.back();
    Get.snackbar(
      'Limit Configured',
      '${app.name} limit set to ${limitMinutes.value.toInt()} minutes.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: GlacierColors.surfaceContainerHigh.withValues(alpha: 0.8),
      colorText: GlacierColors.primary,
    );
  }
}

class SetLimitView extends StatelessWidget {
  const SetLimitView({super.key});

  @override
  Widget build(BuildContext context) {
    final usageService = Get.find<UsageService>();
    final AppUsageInfo app = Get.arguments as AppUsageInfo? ?? usageService.apps.first;
    final controller = Get.put(SetLimitController(app));

    return Scaffold(
      backgroundColor: GlacierColors.background,
      appBar: AppBar(
        backgroundColor: GlacierColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'Set Limit',
          style: GlacierTextStyles.titleLarge.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Card Header
            Center(
              child: Column(
                children: [
                  AppIconWidget(packageName: app.id, iconBytes: app.appIconBytes, iconData: app.icon, color: app.themeColor, size: 72),
                  const SizedBox(height: 12),
                  Text(app.name, style: GlacierTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                  Text(app.category, style: GlacierTextStyles.bodySmall),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Duration Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Usage Limit', style: GlacierTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Obx(() {
                  return Text(
                    '${controller.limitMinutes.value.toInt()}m',
                    style: GlacierTextStyles.headline.copyWith(
                      color: GlacierColors.primary,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: GlacierColors.primary.withValues(alpha: 0.3), blurRadius: 10)],
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 16),

            // Quick preset chips
            Obx(() {
              final current = controller.limitMinutes.value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPresetChip(controller, '15m', 15.0, current == 15.0),
                  _buildPresetChip(controller, '30m', 30.0, current == 30.0),
                  _buildPresetChip(controller, '1h', 60.0, current == 60.0),
                  _buildPresetChip(controller, '2h', 120.0, current == 120.0),
                ],
              );
            }),

            const SizedBox(height: 24),

            // Visual Slider container
            GlassContainer(
              opacity: 0.1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() {
                      return SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: GlacierColors.primary,
                          inactiveTrackColor: GlacierColors.outlineVariant.withValues(alpha: 0.3),
                          thumbColor: GlacierColors.primary,
                          overlayColor: GlacierColors.primary.withValues(alpha: 0.1),
                          valueIndicatorColor: GlacierColors.primary,
                          activeTickMarkColor: Colors.transparent,
                          inactiveTickMarkColor: Colors.transparent,
                        ),
                        child: Slider(
                          value: controller.limitMinutes.value,
                          min: 5,
                          max: 240,
                          divisions: 47, // 5m intervals
                          onChanged: (val) {
                            controller.limitMinutes.value = val;
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('5m', style: GlacierTextStyles.labelSmall),
                        Text('120m', style: GlacierTextStyles.labelSmall),
                        Text('240m', style: GlacierTextStyles.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Repeating and warn toggles
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Daily Repeat
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Repeat',
                              style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                            ),
                            Text('Reset limit every midnight', style: GlacierTextStyles.bodySmall),
                          ],
                        ),
                        Transform.scale(
                          scale: 0.8,
                          alignment: Alignment.centerRight,
                          child: CupertinoSwitch(
                            value: controller.repeatDaily.value,
                            activeTrackColor: GlacierColors.primaryContainer,
                            inactiveTrackColor: GlacierColors.surfaceContainerHigh,
                            onChanged: (val) {
                              controller.repeatDaily.value = val;
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                  const Divider(height: 24, color: Color(0x0F7DD3FC)),
                  // Notify at 80%
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notify at 80%',
                              style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                            ),
                            Text('Alert before limit is reached', style: GlacierTextStyles.bodySmall),
                          ],
                        ),
                        Transform.scale(
                          scale: 0.8,
                          alignment: Alignment.centerRight,
                          child: CupertinoSwitch(
                            value: controller.repeatDaily.value,
                            activeTrackColor: GlacierColors.primaryContainer,
                            inactiveTrackColor: GlacierColors.surfaceContainerHigh,
                            onChanged: (val) {
                              controller.notifyAt80.value = val;
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const Spacer(),

            // Save limit action
            GlassButton(
              text: 'Save Limit',
              icon: const Icon(Icons.check_circle_outline, color: GlacierColors.primary, size: 20),
              onPressed: () async => await controller.saveLimit(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(SetLimitController controller, String label, double value, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.selectPreset(value),
      child: GlassContainer(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderRadius: 12,
        opacity: isSelected ? 0.2 : 0.05,
        borderColor: isSelected ? GlacierColors.primary.withValues(alpha: 0.4) : GlacierColors.outlineVariant.withValues(alpha: 0.1),
        child: Center(
          child: Text(
            label,
            style: GlacierTextStyles.bodySmall.copyWith(
              color: isSelected ? GlacierColors.primary : GlacierColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
