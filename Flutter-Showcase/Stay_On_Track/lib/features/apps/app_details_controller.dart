import 'package:get/get.dart';
import 'package:track_app_usage/core/models/usage_model.dart';
import 'package:track_app_usage/core/services/usage_service.dart';

class AppDetailsController extends GetxController {
  final UsageService usageService = Get.find<UsageService>();

  late final AppUsageInfo app;
  final RxList<double> hourlyBreakdown = List.filled(24, 0.0).obs;
  final RxBool isLoadingHourly = false.obs;

  @override
  void onInit() {
    super.onInit();
    app = Get.arguments as AppUsageInfo;
  }

  int get hours => app.elapsedMinutes ~/ 60;
  double get minutes => app.elapsedMinutes % 60;
  String get formattedUsageTime => hours > 0 ? '${hours}h ${minutes.toInt()}m' : '${minutes.toInt()}m';

  // In your controller

  Future<void> loadHourlyBreakdown(String packageName) async {
    isLoadingHourly.value = true;
    try {
      final data = await usageService.fetchHourlyBreakdown(packageName);
      hourlyBreakdown.assignAll(data);
    } finally {
      isLoadingHourly.value = false;
    }
  }
}
