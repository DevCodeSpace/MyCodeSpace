import 'dart:io' show Platform;
import 'dart:math' show min, cos, sin;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/navigation_scaffold.dart';
import '../../core/widgets/app_icon_widget.dart';
import '../../core/services/usage_service.dart';
import 'dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: GlacierColors.background,
      appBar: AppBar(
        backgroundColor: GlacierColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'StayOnTrack',
          style: GlacierTextStyles.titleLarge.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Greeting Section
              _buildGreeting(controller),
              const SizedBox(height: 16),
              Obx(() {
                final service = Get.find<UsageService>();
                if (Platform.isAndroid && !service.isPermissionGranted.value) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      borderColor: GlacierColors.primary.withValues(alpha: 0.2),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, color: GlacierColors.primary, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Real-time Tracking Disabled',
                                      style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text('Grant usage tracking access to monitor real app usage time.', style: GlacierTextStyles.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => service.requestUsagePermission(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GlacierColors.primary.withValues(alpha: 0.15),
                                foregroundColor: GlacierColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Enable Permission'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              // Responsive layout structure (Grid style)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildUsageRingCard(controller)),
                        const SizedBox(width: 16),
                        Expanded(flex: 7, child: Column(children: [_buildWeeklyTrendsCard(controller), const SizedBox(height: 16), _buildQuickStats(controller)])),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildUsageRingCard(controller),
                        const SizedBox(height: 16),
                        _buildWeeklyTrendsCard(controller),
                        const SizedBox(height: 16),
                        _buildQuickStats(controller),
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              // Apps & Limits
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: _buildMostUsedAppsSection(controller)),
                        const SizedBox(width: 16),
                        Expanded(flex: 5, child: _buildActiveLimitsSection(controller)),
                      ],
                    );
                  } else {
                    return Column(children: [_buildMostUsedAppsSection(controller), const SizedBox(height: 16), _buildActiveLimitsSection(controller)]);
                  }
                },
              ),
              const SizedBox(height: 90), // bottom safe margin
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(DashboardController controller) {
    final now = DateTime.now();
    String greetingText = (now.hour < 12)
        ? 'Good Morning'
        : (now.hour < 17)
        ? 'Good Afternoon'
        : 'Good Evening';

    return Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greetingText,
                  style: GlacierTextStyles.headline.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                ),
                Obx(() {
                  // Gracefully handle situations where data hasn't fully loaded yet
                  if (controller.weeklyUsage.length < 2) {
                    return const SizedBox.shrink();
                  }

                  final bool decreasing = controller.isScreenTimeDecreasing;
                  final String trendText = "${controller.todayTrendPercentage.toStringAsFixed(0)}%";

                  return Row(
                    children: [
                      Icon(decreasing ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: decreasing ? GlacierColors.primary : GlacierColors.error, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        trendText,
                        style: GlacierTextStyles.bodyMedium.copyWith(color: decreasing ? GlacierColors.primary : GlacierColors.error, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        decreasing ? "less screen time today" : "more screen time today",
                        style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.6)),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          Obx(() {
            final focusOn = controller.stats.value.isFocusModeOn;
            return FocusModeCapsule(focusOn: focusOn, onTap: controller.toggleFocusMode);
          }),
        ],
      ),
    );
  }

  Widget _buildUsageRingCard(DashboardController controller) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      elevated: true,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Usage", style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              Obx(() {
                final pct = (controller.usagePercentage * 100).toInt();
                return Text(
                  '$pct% of Goal',
                  style: GlacierTextStyles.labelMedium.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.bold),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final percentage = controller.usagePercentage;
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: percentage),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, val, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: UsageGaugePainter(progress: val, primaryColor: GlacierColors.primary, secondaryColor: GlacierColors.tertiary),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(controller.totalFormattedTime, style: GlacierTextStyles.display.copyWith(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                        const SizedBox(height: 4),
                        Text(
                          'LIMIT: ${controller.totalGoalTime}',
                          style: GlacierTextStyles.labelSmall.copyWith(
                            color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.6),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }),
          // Stats Row
          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.touch_app, color: GlacierColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text('${controller.stats.value.pickups}', style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('PICKUPS', style: GlacierTextStyles.labelSmall.copyWith(letterSpacing: 1.0)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_active_outlined, color: GlacierColors.tertiary, size: 16),
                      const SizedBox(width: 4),
                      Text('${controller.stats.value.notifications}', style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('ALERTS', style: GlacierTextStyles.labelSmall.copyWith(letterSpacing: 1.0)),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrendsCard(DashboardController controller) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Weekly Trends", style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Obx(() {
            final points = controller.weeklyUsage;
            final hasData = points.any((point) => point.totalMinutes > 0);
            if (points.isEmpty || !hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'Weekly history will appear once the app has collected real usage data.',
                  style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.6)),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final maxMinutes = points.fold<double>(0.0, (maxValue, point) {
              return point.totalMinutes > maxValue ? point.totalMinutes : maxValue;
            });
            final totalMinutes = controller.weeklyTotalMinutes;
            final averageMinutes = controller.weeklyAverageMinutes;
            final peakDay = controller.weeklyPeakDay;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildTrendMetricChip('TOTAL', controller.formatMinutes(totalMinutes), GlacierColors.primary)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTrendMetricChip('AVERAGE', controller.formatMinutes(averageMinutes), GlacierColors.tertiary)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTrendMetricChip('PEAK', peakDay == null || peakDay.totalMinutes == 0 ? 'No data' : peakDay.shortDayLabel, GlacierColors.secondary)),
                  ],
                ),
                const SizedBox(height: 28),
                UsageLineChart(points: points, peakDay: peakDay, maxMinutes: maxMinutes),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrendMetricChip(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GlacierColors.surfaceContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.07), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GlacierTextStyles.labelSmall.copyWith(
                  fontSize: 8,
                  color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GlacierTextStyles.bodyLarge.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.w800, fontSize: 14, height: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DashboardController controller) {
    return Row(
      children: [
        // Sleep Impact
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: GlacierColors.tertiary.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 4,
                  children: [
                    const Icon(Icons.bedtime_outlined, color: GlacierColors.tertiary, size: 16),
                    Text('Sleep Impact', style: GlacierTextStyles.bodySmall.copyWith(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Optimal',
                  style: GlacierTextStyles.titleMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Focus Sessions
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: GlacierColors.secondary.withValues(alpha: 0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 4,
                  children: [
                    const Icon(Icons.bolt_outlined, color: GlacierColors.secondary, size: 16),
                    Text('Focus Sessions', style: GlacierTextStyles.bodySmall.copyWith(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '3 / 5 Done',
                  style: GlacierTextStyles.titleMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMostUsedAppsSection(DashboardController controller) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Most Used Apps", style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 6), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                onPressed: () {
                  final nav = Get.find<NavigationController>();
                  nav.changePage(1);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.chevron_right, color: GlacierColors.primary, size: 16),
                  ],
                ),
              ),
            ],
          ),
          // const SizedBox(height: 8),
          Obx(() {
            final apps = controller.apps.where((app) => app.elapsedMinutes > 1).toList()..sort((a, b) => b.elapsedMinutes.compareTo(a.elapsedMinutes));
            final topApps = apps.take(5).toList();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topApps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final app = topApps[index];
                final hours = app.elapsedMinutes ~/ 60;
                final minutes = (app.elapsedMinutes % 60).toInt();
                final formattedTime = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

                return InkWell(
                  onTap: () => Get.toNamed(AppRoutes.appDetails, arguments: app),
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: AppIconWidget(packageName: app.id, iconBytes: app.appIconBytes, iconData: app.icon, color: app.themeColor, size: 22),
                      ),
                      const SizedBox(width: 8),
                      // App Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.name,
                              style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                            ),
                            // const SizedBox(height: 2),
                            Text(app.category, style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                      // App Usage stats progress
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formattedTime,
                            style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(app.percentUsed * 100).toInt()}% of limit',
                            style: GlacierTextStyles.labelSmall.copyWith(
                              fontSize: 9,
                              color: app.percentUsed >= 0.8 ? GlacierColors.error : GlacierColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      // const SizedBox(width: 8),
                      // Icon(Icons.chevron_right, color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.3), size: 18),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActiveLimitsSection(DashboardController controller) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Active Limits", style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                style: TextButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 6), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                icon: const Icon(Icons.keyboard_arrow_right, color: GlacierColors.onSurfaceVariant),
                onPressed: () => Get.toNamed(AppRoutes.activeLimits),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Limit items
          Obx(() {
            final limitedApps = controller.apps.where((app) => app.limit != null).toList();

            if (limitedApps.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  children: [
                    Icon(Icons.timer_outlined, color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.3), size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'No limits set for today',
                      style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.6)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: limitedApps.map((app) {
                final isExceeded = app.isLimitExceeded;
                final isWarning = !isExceeded && app.percentUsed >= 0.8;

                final indicatorColor = isExceeded
                    ? GlacierColors.error
                    : isWarning
                    ? GlacierColors.tertiary
                    : app.themeColor;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Center(
                            child: AppIconWidget(packageName: app.id, iconBytes: app.appIconBytes, iconData: app.icon, color: app.themeColor, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              app.name,
                              style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '${(app.percentUsed * 100).toInt()}%',
                            style: GlacierTextStyles.labelSmall.copyWith(color: indicatorColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 6,
                          color: GlacierColors.surfaceContainerHigh.withValues(alpha: 0.5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: app.percentUsed,
                              child: Container(
                                decoration: BoxDecoration(gradient: LinearGradient(colors: [indicatorColor, indicatorColor.withValues(alpha: 0.6)])),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 10),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     Text(
                      //       '$elapsedFormatted used of $limitFormatted limit',
                      //       style: GlacierTextStyles.labelSmall.copyWith(fontSize: 9, color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.7)),
                      //     ),
                      //     Text(
                      //       '${(app.percentUsed * 100).toInt()}%',
                      //       style: GlacierTextStyles.labelSmall.copyWith(fontSize: 9, color: indicatorColor, fontWeight: FontWeight.bold),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class FocusModeCapsule extends StatefulWidget {
  final bool focusOn;
  final VoidCallback onTap;

  const FocusModeCapsule({super.key, required this.focusOn, required this.onTap});

  @override
  State<FocusModeCapsule> createState() => _FocusModeCapsuleState();
}

class _FocusModeCapsuleState extends State<FocusModeCapsule> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    if (widget.focusOn) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(FocusModeCapsule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusOn && !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (!widget.focusOn && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: widget.focusOn ? GlacierColors.primary.withValues(alpha: 0.12) : GlacierColors.surfaceContainerHigh.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (widget.focusOn)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: GlacierColors.primary.withValues(alpha: 0.4 * (1 - _pulseController.value)),
                            width: 3 * _pulseController.value,
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.focusOn ? GlacierColors.primary : GlacierColors.onSurfaceVariant.withValues(alpha: 0.5),
                    boxShadow: widget.focusOn ? [const BoxShadow(color: GlacierColors.primary, blurRadius: 4, spreadRadius: 1)] : null,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Text(
              widget.focusOn ? 'FOCUS ON' : 'FOCUS OFF',
              style: GlacierTextStyles.labelSmall.copyWith(
                color: widget.focusOn ? GlacierColors.primary : GlacierColors.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UsageGaugePainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color primaryColor;
  final Color secondaryColor;

  UsageGaugePainter({required this.progress, required this.primaryColor, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;

    const startAngle = 135 * 3.141592653589793 / 180;
    const sweepAngle = 270 * 3.141592653589793 / 180;

    final trackPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.08)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, trackPaint);

    if (progress > 0) {
      final progressSweep = sweepAngle * progress;

      final glowPaint = Paint()
        ..shader = SweepGradient(
          colors: [primaryColor.withValues(alpha: 0.3), secondaryColor.withValues(alpha: 0.3)],
          startAngle: 0.0,
          endAngle: sweepAngle,
          transform: GradientRotation(startAngle),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 24
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, progressSweep, false, glowPaint);

      final progressPaint = Paint()
        ..shader = SweepGradient(
          colors: [primaryColor, secondaryColor],
          startAngle: 0.0,
          endAngle: sweepAngle,
          transform: GradientRotation(startAngle),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, progressSweep, false, progressPaint);

      final endAngle = startAngle + progressSweep;
      final dotCenter = Offset(center.dx + radius * cos(endAngle), center.dy + radius * sin(endAngle));

      final dotGlowPaint = Paint()
        ..color = secondaryColor.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(dotCenter, 12, dotGlowPaint);

      final dotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(dotCenter, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant UsageGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.primaryColor != primaryColor || oldDelegate.secondaryColor != secondaryColor;
  }
}

class UsageLineChart extends StatefulWidget {
  final List<dynamic> points; // your existing DailyUsagePoint list
  final dynamic peakDay; // nullable DailyUsagePoint
  final double maxMinutes;

  const UsageLineChart({super.key, required this.points, required this.peakDay, required this.maxMinutes});

  @override
  State<UsageLineChart> createState() => _UsageLineChartState();
}

class _UsageLineChartState extends State<UsageLineChart> with SingleTickerProviderStateMixin {
  int? _touchedIndex;
  late AnimationController _animController;
  late Animation<double> _drawAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _drawAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<FlSpot> get _spots => List.generate(widget.points.length, (i) => FlSpot(i.toDouble(), widget.points[i].totalMinutes.toDouble()));

  int get _peakIndex {
    if (widget.peakDay == null) return -1;
    return widget.points.indexWhere((p) => p.date.year == widget.peakDay.date.year && p.date.month == widget.peakDay.date.month && p.date.day == widget.peakDay.date.day);
  }

  @override
  Widget build(BuildContext context) {
    final spots = _spots;
    final peakIdx = _peakIndex;
    final lastIdx = widget.points.length - 1;
    final maxY = widget.maxMinutes == 0 ? 60.0 : widget.maxMinutes * 1.25;

    return SizedBox(
      height: 190,
      child: AnimatedBuilder(
        animation: _drawAnim,
        builder: (context, _) {
          return LineChart(
            duration: Duration(milliseconds: 500), // we handle animation ourselves
            LineChartData(
              minX: 0,
              maxX: (widget.points.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,

              // ── Touch / tooltip ─────────────────────────────────────
              lineTouchData: LineTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  setState(() {
                    if (event is FlTapUpEvent || event is FlPanEndEvent || response == null || response.lineBarSpots == null) {
                      _touchedIndex = null;
                    } else {
                      _touchedIndex = response.lineBarSpots!.first.spotIndex;
                    }
                  });
                },
                getTouchedSpotIndicator: (barData, spotIndexes) => spotIndexes.map((i) {
                  return TouchedSpotIndicatorData(
                    FlLine(color: GlacierColors.primary.withValues(alpha: 0.25), strokeWidth: 1.5, dashArray: [4, 4]),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(radius: 5, color: GlacierColors.primary, strokeWidth: 2, strokeColor: Colors.white.withValues(alpha: 0.9)),
                    ),
                  );
                }).toList(),
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: GlacierColors.surfaceContainerHigh,
                  tooltipRoundedRadius: 10,
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  tooltipBorder: BorderSide(color: GlacierColors.primary.withValues(alpha: 0.25)),
                  getTooltipItems: (spots) => spots.map((s) {
                    final idx = s.spotIndex;
                    final point = widget.points[idx];
                    final h = point.totalMinutes ~/ 60;
                    final m = (point.totalMinutes % 60).toInt();
                    final label = h > 0 ? '${h}h ${m}m' : '${m}m';
                    return LineTooltipItem(
                      '${point.shortDayLabel}\n',
                      GlacierTextStyles.labelSmall.copyWith(fontSize: 9, color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.6), height: 1.4),
                      children: [
                        TextSpan(
                          text: label,
                          style: GlacierTextStyles.bodyMedium.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: GlacierColors.primary),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // ── Grid ────────────────────────────────────────────────
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 3,
                getDrawingHorizontalLine: (_) => FlLine(color: GlacierColors.outlineVariant.withValues(alpha: 0.12), strokeWidth: 1),
              ),

              // ── Borders ─────────────────────────────────────────────
              borderData: FlBorderData(show: false),

              // ── Axis titles ─────────────────────────────────────────
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= widget.points.length) {
                        return const SizedBox.shrink();
                      }
                      final isLast = idx == lastIdx;
                      final isPeak = idx == peakIdx;
                      final label = widget.points[idx].shortDayLabel.toUpperCase();
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          label,
                          style: GlacierTextStyles.labelSmall.copyWith(
                            fontSize: 8,
                            fontWeight: isLast || isPeak ? FontWeight.w700 : FontWeight.normal,
                            color: isLast
                                ? GlacierColors.primary
                                : isPeak
                                ? GlacierColors.tertiary
                                : GlacierColors.onSurfaceVariant.withValues(alpha: 0.55),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── Line data ───────────────────────────────────────────
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  // preventCurveOverShooting: true,

                  // Animate draw by cutting spots via lerp
                  show: true,

                  // Gradient line stroke
                  gradient: LinearGradient(
                    colors: [GlacierColors.primary.withValues(alpha: 0.4), GlacierColors.primary, GlacierColors.tertiary.withValues(alpha: 0.7)],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  isStrokeJoinRound: true,

                  // Gradient fill under the curve
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [GlacierColors.primary.withValues(alpha: 0.18), GlacierColors.primary.withValues(alpha: 0.0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),

                  // Dots: only show on peak + last, hide rest
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) {
                      if (index == _touchedIndex) {
                        return FlDotCirclePainter(radius: 0, color: Colors.transparent, strokeWidth: 0, strokeColor: Colors.transparent);
                      }
                      if (index == lastIdx) {
                        return FlDotCirclePainter(radius: 5, color: GlacierColors.primary, strokeWidth: 2.5, strokeColor: Colors.white.withValues(alpha: 0.85));
                      }
                      if (index == peakIdx) {
                        return FlDotCirclePainter(radius: 4, color: GlacierColors.tertiary, strokeWidth: 2, strokeColor: Colors.white.withValues(alpha: 0.85));
                      }
                      // Hide all other dots
                      return FlDotCirclePainter(radius: 0, color: Colors.transparent, strokeWidth: 0, strokeColor: Colors.transparent);
                    },
                  ),
                ),
              ],

              // ── Extra lines: vertical markers for peak & last ───────
              extraLinesData: ExtraLinesData(
                verticalLines: [
                  if (peakIdx >= 0) VerticalLine(x: peakIdx.toDouble(), color: GlacierColors.tertiary.withValues(alpha: 0.2), strokeWidth: 1, dashArray: [3, 4]),
                  VerticalLine(x: lastIdx.toDouble(), color: GlacierColors.primary.withValues(alpha: 0.2), strokeWidth: 1, dashArray: [3, 4]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
