import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_app_usage/core/services/usage_service.dart';
import 'package:track_app_usage/features/apps/app_details_controller.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/models/usage_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/app_icon_widget.dart';

class AppDetailsView extends StatelessWidget {
  const AppDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject the temporary controller for this view lifecycle
    final controller = Get.put(AppDetailsController());
    final app = controller.app;

    return Scaffold(
      backgroundColor: GlacierColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: GlacierColors.onSurface, size: 20),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),

              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(boxShadow: [BoxShadow(color: app.themeColor.withValues(alpha: 0.25), blurRadius: 40, spreadRadius: 5)]),
                      child: Hero(
                        tag: 'app_icon_${app.id}',
                        child: AppIconWidget(packageName: app.id, iconBytes: app.appIconBytes, iconData: app.icon, color: app.themeColor, size: 80),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(app.name, style: GlacierTextStyles.headline.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Text(
                      app.category.toUpperCase(),
                      style: GlacierTextStyles.bodyMedium.copyWith(
                        color: GlacierColors.onSurface.withValues(alpha: 0.5),
                        letterSpacing: 1.2,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Today's usage duration Card
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("TODAY'S SCREEN TIME", style: GlacierTextStyles.labelSmall.copyWith(fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            controller.formattedUsageTime,
                            style: GlacierTextStyles.display.copyWith(fontSize: 28, color: GlacierColors.primary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                          ),
                        ],
                      ),
                    ),
                    if (app.limit != null) ...[
                      Container(width: 1, height: 50, color: GlacierColors.outlineVariant.withValues(alpha: 0.15)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ACTIVE LIMIT", style: GlacierTextStyles.labelSmall.copyWith(fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                _formatMinutes(app.limit!.limitMinutes),
                                style: GlacierTextStyles.display.copyWith(fontSize: 28, color: GlacierColors.primary, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Simulated Hourly Usage Chart
              _buildHourlyTrends(app),

              const SizedBox(height: 16),

              // Main Action Buttons
              GlassButton(
                text: app.limit == null ? 'Set Custom Limit' : 'Modify Limit',
                icon: const Icon(Icons.timer_outlined, color: GlacierColors.primary, size: 20),
                onPressed: () => Get.toNamed(AppRoutes.setLimit, arguments: app),
              ),

              if (app.limit != null) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await controller.usageService.removeLimit(app.id);
                    Get.back();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Remove Active Limit',
                    style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.error, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyTrends(AppUsageInfo app) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Hourly Breakdown", style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              Icon(Icons.bar_chart_rounded, size: 18, color: GlacierColors.onSurface.withValues(alpha: 0.4)),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<double>>(
            future: Get.find<UsageService>().fetchHourlyBreakdown(app.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 220,
                  child: Center(
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: app.themeColor)),
                  ),
                );
              }

              final hourlyData = snapshot.data ?? List.filled(24, 0.0);
              final maxMinutes = hourlyData.reduce(max);
              final peakHour = maxMinutes > 0 ? hourlyData.indexOf(maxMinutes) : -1;
              final availableData = <MapEntry<int, double>>[];

              for (int i = 0; i < hourlyData.length; i++) {
                if (hourlyData[i] > 0) {
                  availableData.add(MapEntry(i, hourlyData[i]));
                }
              }

              if (availableData.isEmpty) {
                return SizedBox(
                  height: 220,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.trending_down_rounded, size: 32, color: GlacierColors.onSurface.withValues(alpha: .2)),
                        const SizedBox(height: 8),
                        Text("No usage recorded", style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface.withValues(alpha: .4))),
                      ],
                    ),
                  ),
                );
              }

              double calculateInterval(double maxMinutes) {
                if (maxMinutes <= 60) {
                  return 15; // 15 min
                } else if (maxMinutes <= 180) {
                  return 30; // 30 min
                } else if (maxMinutes <= 360) {
                  return 60; // 1 hour
                } else if (maxMinutes <= 720) {
                  return 120; // 2 hours
                } else {
                  return 180; // 3 hours
                }
              }

              double roundUpMaxY(double value, double interval) => (value / interval).ceil() * interval;
              const double minPixelsPerInterval = 48.0;
              const double chartPaddingVertical = 16.0;

              final interval = calculateInterval(maxMinutes);
              final maxY = roundUpMaxY(maxMinutes, interval);
              final intervalCount = (maxY / interval).round();
              final chartHeight = (intervalCount * minPixelsPerInterval).clamp(150.0, double.infinity) + chartPaddingVertical;

              return Column(
                children: [
                  SizedBox(
                    height: chartHeight,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (availableData.length - 1).toDouble(),
                        minY: 0,
                        maxY: maxY,

                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: interval,
                          getDrawingHorizontalLine: (value) => FlLine(color: GlacierColors.onSurface.withValues(alpha: .08), strokeWidth: 1),
                        ),

                        borderData: FlBorderData(show: false),

                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: interval,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                if (value >= 60) {
                                  final hours = value ~/ 60;
                                  final mins = value % 60;
                                  return Text(
                                    mins == 0 ? '${hours}h' : '${hours}h ${mins.toInt()}m',
                                    style: GlacierTextStyles.labelSmall.copyWith(fontSize: 10, color: GlacierColors.onSurface.withValues(alpha: .6)),
                                  );
                                }

                                return Text('${value.toInt()}m', style: GlacierTextStyles.labelSmall.copyWith(fontSize: 10, color: GlacierColors.onSurface.withValues(alpha: .6)));
                              },
                            ),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 28,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();

                                if (index < 0 || index >= availableData.length) {
                                  return const SizedBox.shrink();
                                }

                                final hour = availableData[index].key;

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(_hourLabel(hour), style: GlacierTextStyles.labelSmall.copyWith(fontSize: 10, color: GlacierColors.onSurface.withValues(alpha: .6))),
                                );
                              },
                            ),
                          ),
                        ),

                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipRoundedRadius: 10,
                            getTooltipItems: (spots) {
                              return spots.map((spot) {
                                final hour = availableData[spot.x.toInt()].key;
                                return LineTooltipItem(
                                  "${_hourLabel(hour)}\n${_formatMinutes(spot.y)}",
                                  GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
                                );
                              }).toList();
                            },
                          ),
                        ),

                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(availableData.length, (index) => FlSpot(index.toDouble(), availableData[index].value)),
                            color: app.themeColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [app.themeColor.withValues(alpha: .35), app.themeColor.withValues(alpha: .02)],
                              ),
                            ),

                            dotData: FlDotData(
                              show: true,
                              checkToShowDot: (spot, barData) => spot.x.toInt() == peakHour,
                              getDotPainter: (spot, percent, bar, index) {
                                return FlDotCirclePainter(radius: 5, color: app.themeColor, strokeWidth: 2, strokeColor: Colors.white);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (peakHour != -1) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: app.themeColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Peak usage at ${_hourLabel(peakHour)} • ${_formatMinutes(maxMinutes)}",
                          style: GlacierTextStyles.labelSmall.copyWith(color: GlacierColors.onSurface.withValues(alpha: .6)),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  String _hourLabel(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    return hour < 12 ? '$hour AM' : '${hour - 12} PM';
  }

  String _formatMinutes(double minutes) {
    if (minutes <= 0) return '0m';
    if (minutes < 1) return '< 1m';
    final m = minutes.toInt();
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final mins = m % 60;
    return h == 0
        ? '${mins}m'
        : mins == 0
        ? '${h}h'
        : '${h}h ${mins}m';
  }
}
