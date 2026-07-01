import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/models/usage_model.dart';
import '../../core/services/usage_service.dart';
import '../../core/widgets/app_icon_widget.dart';

class LimitReachedAlertView extends StatelessWidget {
  const LimitReachedAlertView({super.key});

  @override
  Widget build(BuildContext context) {
    final usageService = Get.find<UsageService>();
    final AppUsageInfo app = Get.arguments as AppUsageInfo? ?? usageService.apps.first;

    final limitHours = app.limit?.limitMinutes ?? 0 ~/ 60;
    final limitMin = (app.limit?.limitMinutes ?? 0 % 60).toInt();
    final limitFormatted = limitHours > 0 ? '${limitHours}h ${limitMin}m' : '${limitMin}m';

    return Scaffold(
      backgroundColor: GlacierColors.background,
      body: Stack(
        children: [
          // Background Atmospheric Mesh
          Positioned.fill(
            child: Container(decoration: const BoxDecoration(gradient: GlacierColors.bgMeshGradient)),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: GlacierColors.error.withValues(alpha: 0.08)),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Exceeded Logo Ring
                  Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Pulsing Red Ring
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: GlacierColors.error.withValues(alpha: 0.3), width: 2),
                              boxShadow: [BoxShadow(color: GlacierColors.error.withValues(alpha: 0.1), blurRadius: 30, spreadRadius: 5)],
                            ),
                          ),
                          // Inner Alert circle
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: GlacierColors.errorContainer.withValues(alpha: 0.1)),
                            child: const Center(child: Icon(Icons.warning_amber_rounded, color: GlacierColors.error, size: 56)),
                          ),
                          // Floating App Icon
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GlassContainer(
                              width: 44,
                              height: 44,
                              borderRadius: 12,
                              opacity: 0.2,
                              borderColor: app.themeColor.withValues(alpha: 0.3),
                              child: AppIconWidget(packageName: app.id, iconBytes: app.appIconBytes, iconData: app.icon, color: app.themeColor, size: 22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Title app block
                  Text(
                    '${app.name} Limit Reached',
                    style: GlacierTextStyles.headline.copyWith(color: GlacierColors.onSurface, fontSize: 28),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Refine your digital focus. You\'ve reached your configured daily limit.',
                    style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.8)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Tagline Card
                  Center(
                    child: GlassContainer(
                      borderRadius: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      opacity: 0.1,
                      borderColor: GlacierColors.error.withValues(alpha: 0.1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: GlacierColors.error, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            'Limit: $limitFormatted',
                            style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.error, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Actions
                  // Close App Button
                  GlassButton(
                    text: 'Close App',
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Snooze 15m
                  GestureDetector(
                    onTap: () {
                      if (app.limit != null) {
                        app.limit!.limitMinutes += 15;
                        usageService.apps.refresh();
                      }
                      Get.back();
                      Get.snackbar(
                        'Limit Extended',
                        'Snoozed for 15 minutes.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: GlacierColors.surfaceContainerHigh.withValues(alpha: 0.8),
                        colorText: GlacierColors.primary,
                      );
                    },
                    child: GlassContainer(
                      height: 56,
                      borderRadius: 16,
                      opacity: 0.1,
                      borderColor: GlacierColors.outlineVariant.withValues(alpha: 0.2),
                      child: Center(
                        child: Text(
                          'Snooze 15 minutes',
                          style: GlacierTextStyles.bodyLarge.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Ignore for today
                  TextButton(
                    onPressed: () {
                      if (app.limit != null) {
                        app.limit!.isActive = false;
                        usageService.apps.refresh();
                      }
                      Get.back();
                    },
                    child: Text(
                      'Ignore Limit for Today',
                      style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurfaceVariant, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
