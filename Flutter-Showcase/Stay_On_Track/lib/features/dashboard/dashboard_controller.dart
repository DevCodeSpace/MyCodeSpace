import 'package:get/get.dart';
import '../../core/services/usage_service.dart';
import '../../core/models/usage_model.dart';

class DashboardController extends GetxController {
  final UsageService usageService = Get.find<UsageService>();

  RxList<AppUsageInfo> get apps => usageService.apps;
  Rx<DeviceUsageStats> get stats => usageService.stats;
  RxList<DailyUsagePoint> get weeklyUsage => usageService.weeklyUsage;

  String get totalFormattedTime {
    final double totalMin = usageService.totalMinutes.value;
    final int hours = totalMin ~/ 60;
    final int minutes = (totalMin % 60).toInt();
    return '${hours}h ${minutes}m';
  }

  String get totalGoalTime {
    final double goalMin = stats.value.totalGoalMinutes;
    final int hours = goalMin ~/ 60;
    final int minutes = (goalMin % 60).toInt();
    return '${hours}h ${minutes}m';
  }

  double get usagePercentage {
    final double total = usageService.totalElapsedMinutes;
    final double goal = stats.value.totalGoalMinutes;
    if (goal == 0) return 0.0;
    return (total / goal).clamp(0.0, 1.0);
  }

  double get weeklyTotalMinutes {
    return weeklyUsage.fold<double>(0.0, (sum, point) => sum + point.totalMinutes);
  }

  double get weeklyAverageMinutes {
    if (weeklyUsage.isEmpty) return 0.0;
    return weeklyTotalMinutes / weeklyUsage.length;
  }

  DailyUsagePoint? get weeklyPeakDay {
    if (weeklyUsage.isEmpty) return null;
    return weeklyUsage.reduce((a, b) => a.totalMinutes >= b.totalMinutes ? a : b);
  }

  String formatMinutes(double minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes.round() % 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  void toggleFocusMode() {
    usageService.toggleFocusMode();
  }

  /// Returns the absolute percentage change between today and yesterday.
  double get todayTrendPercentage {
    if (weeklyUsage.length < 2) return 0.0;

    // Assumes last element is today, previous element is yesterday
    final double todayMins = weeklyUsage.last.totalMinutes;
    final double yesterdayMins = weeklyUsage[weeklyUsage.length - 2].totalMinutes;

    if (yesterdayMins == 0) return todayMins > 0 ? 100.0 : 0.0;

    final double difference = todayMins - yesterdayMins;
    return ((difference / yesterdayMins) * 100).abs();
  }

  /// Returns true if today's usage is less than or equal to yesterday's usage.
  bool get isScreenTimeDecreasing {
    if (weeklyUsage.length < 2) return true;
    final double todayMins = weeklyUsage.last.totalMinutes;
    final double yesterdayMins = weeklyUsage[weeklyUsage.length - 2].totalMinutes;
    return todayMins <= yesterdayMins;
  }
}
