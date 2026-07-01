import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  late PageController pageController;

  final List<OnboardingStepData> steps = [
    OnboardingStepData(
      title: 'Track App Usage',
      description: 'Gain absolute clarity on your digital habits. StayOnTrack visualizes your screentime with ethereal precision, helping you reclaim focus.',
      stepNumber: 1,
    ),
    OnboardingStepData(
      title: 'Set Smart Limits',
      description: 'Take charge by configuring daily limits for addictive apps. StayOnTrack gently alerts you at 80% usage to help prevent fatigue.',
      stepNumber: 2,
    ),
    OnboardingStepData(
      title: 'Cultivate Deep Focus',
      description: 'Trigger Focus Sessions that silence distracting notification spikes, keeping you firmly aligned with your goals.',
      stepNumber: 3,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value < steps.length - 1) {
      currentPage.value++;
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    Get.offAllNamed(AppRoutes.dashboard);
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }
}

class OnboardingStepData {
  final String title;
  final String description;
  final int stepNumber;

  OnboardingStepData({required this.title, required this.description, required this.stepNumber});
}
