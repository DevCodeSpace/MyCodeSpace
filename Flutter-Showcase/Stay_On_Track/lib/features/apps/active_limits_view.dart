import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/services/usage_service.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/app_icon_widget.dart';

class ActiveLimitsView extends StatelessWidget {
  const ActiveLimitsView({super.key});

  @override
  Widget build(BuildContext context) {
    final usageService = Get.find<UsageService>();

    return Scaffold(
      backgroundColor: GlacierColors.background,
      appBar: AppBar(
        backgroundColor: GlacierColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'Active Limits',
          style: GlacierTextStyles.titleLarge.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Obx(() {
            final limitedApps = usageService.apps.where((app) => app.limit != null).toList();

            if (limitedApps.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer_off_outlined, color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.4), size: 64),
                      const SizedBox(height: 16),
                      Text('No Active Limits', style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Configure usage limits for individual apps in the Apps section.', style: GlacierTextStyles.bodyMedium, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              physics: const BouncingScrollPhysics(),
              itemCount: limitedApps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final app = limitedApps[index];
                final isExceeded = app.isLimitExceeded;
                final indicatorColor = isExceeded ? GlacierColors.error : app.themeColor;
                final borderColor = isExceeded ? GlacierColors.error.withValues(alpha: 0.2) : app.themeColor.withValues(alpha: 0.1);

                final limitHours = app.limit!.limitMinutes ~/ 60;
                final limitMin = (app.limit!.limitMinutes % 60).toInt();
                final elapsedHours = app.elapsedMinutes ~/ 60;
                final elapsedMin = (app.elapsedMinutes % 60).toInt();

                final limitFormatted = limitHours > 0 ? '${limitHours}h ${limitMin}m' : '${limitMin}m';
                final elapsedFormatted = elapsedHours > 0 ? '${elapsedHours}h ${elapsedMin}m' : '${elapsedMin}m';

                return InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.appDetails, arguments: app);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    opacity: 0.1,
                    borderColor: borderColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(color: GlacierColors.surfaceContainerHigh.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)),
                              child: AppIconWidget(packageName: app.id, iconBytes: app.appIconBytes, iconData: app.icon, color: app.themeColor, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.name,
                                    style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                                  ),
                                  Text(app.category, style: GlacierTextStyles.bodySmall),
                                ],
                              ),
                            ),
                            Text(
                              isExceeded ? 'EXCEEDED' : '${(app.percentUsed * 100).toInt()}% Used',
                              style: GlacierTextStyles.bodySmall.copyWith(color: indicatorColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Container(
                            height: 6,
                            color: GlacierColors.surfaceContainerHigh.withValues(alpha: 0.3),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: app.percentUsed,
                                child: Container(color: indicatorColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$elapsedFormatted / $limitFormatted', style: GlacierTextStyles.labelSmall.copyWith(fontSize: 8)),
                            Row(
                              children: [
                                if (app.limit!.repeatDaily) const Icon(Icons.repeat, color: GlacierColors.onSurfaceVariant, size: 10),
                                if (app.limit!.repeatDaily) const SizedBox(width: 4),
                                if (app.limit!.notifyAt80) const Icon(Icons.notifications_active, color: GlacierColors.onSurfaceVariant, size: 10),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
