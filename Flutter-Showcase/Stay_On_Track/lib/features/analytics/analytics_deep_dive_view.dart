import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_container.dart';

class AnalyticsDeepDiveView extends StatelessWidget {
  const AnalyticsDeepDiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlacierColors.background,
      appBar: AppBar(
        backgroundColor: GlacierColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'Analytics Deep Dive',
          style: GlacierTextStyles.titleLarge.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Cards Row
              _buildSummaryHeader(),
              const SizedBox(height: 24),

              // Line Chart Trends
              _buildLineChartTrends(),
              const SizedBox(height: 24),

              // Category Breakdown
              _buildCategoryBreakdown(),
              const SizedBox(height: 24),

              // Focus efficiency
              _buildFocusEfficiency(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AVG DAILY TIME', style: GlacierTextStyles.labelSmall.copyWith(fontSize: 8, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text(
                  '3h 42m',
                  style: GlacierTextStyles.titleLarge.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.bold),
                ),
                Text('-12% vs last week', style: GlacierTextStyles.labelSmall.copyWith(fontSize: 8, color: GlacierColors.primary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BEST FOCUS DAY', style: GlacierTextStyles.labelSmall.copyWith(fontSize: 8, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text('Wednesday', style: GlacierTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                Text('Only 1h 12m usage', style: GlacierTextStyles.labelSmall.copyWith(fontSize: 8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChartTrends() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Weekly Active Usage", style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: GlacierColors.outlineVariant.withValues(alpha: 0.1), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == 2 || value == 4 || value == 6) {
                          return Text('${value.toInt()}h', style: GlacierTextStyles.labelSmall.copyWith(fontSize: 8));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt()], style: GlacierTextStyles.labelSmall.copyWith(fontSize: 8)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 2.4), FlSpot(1, 4.1), FlSpot(2, 3.2), FlSpot(3, 5.2), FlSpot(4, 4.2), FlSpot(5, 1.2), FlSpot(6, 0.9)],
                    isCurved: true,
                    gradient: const LinearGradient(colors: [GlacierColors.primary, GlacierColors.tertiary]),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [GlacierColors.primary.withValues(alpha: 0.3), GlacierColors.primary.withValues(alpha: 0.0)],
                      ),
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

  Widget _buildCategoryBreakdown() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Category Distribution", style: GlacierTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // Stacked horizontal bar representation
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(flex: 50, child: Container(color: GlacierColors.primary)),
                  Expanded(flex: 30, child: Container(color: GlacierColors.tertiary)),
                  Expanded(flex: 20, child: Container(color: GlacierColors.secondary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryLegend(color: GlacierColors.primary, label: 'Social Media', percent: '50%'),
              _buildCategoryLegend(color: GlacierColors.tertiary, label: 'Entertainment', percent: '30%'),
              _buildCategoryLegend(color: GlacierColors.secondary, label: 'Productivity', percent: '20%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegend({required Color color, required String label, required String percent}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text('$label ($percent)', style: GlacierTextStyles.labelSmall.copyWith(fontSize: 8)),
      ],
    );
  }

  Widget _buildFocusEfficiency() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.auto_graph, color: GlacierColors.primary, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Focus Efficiency Score',
                  style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Based on your focus sessions, sleep score, and reduced usage limits.', style: GlacierTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '82%',
            style: GlacierTextStyles.display.copyWith(fontSize: 28, color: GlacierColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
