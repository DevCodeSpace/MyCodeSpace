// ONBOARDING CONTROLLER
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soothly/Model/common_model.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  var currentPage = 0.obs;

  final pages = <OnboardingPageModel>[
    OnboardingPageModel(
      title: 'Welcome to FlutterApp',
      description: 'Experience amazing features with beautiful animations',
      icon: Icons.waving_hand,
      color: Colors.blue,
    ),
    OnboardingPageModel(
      title: 'Smooth Animations',
      description: 'Every interaction is designed to delight and engage',
      icon: Icons.animation,
      color: Colors.purple,
    ),
    OnboardingPageModel(
      title: 'Get Started',
      description: 'Ready to explore? Let\'s begin your journey!',
      icon: Icons.rocket_launch,
      color: Colors.green,
    ),
  ].obs;

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      navigateToDashboard();
    }
  }

  void skipOnboarding() {
    navigateToDashboard();
  }

  void navigateToDashboard() {
    Get.offNamed('/dashboard');
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  String get buttonText =>
      currentPage.value < pages.length - 1 ? 'Next' : 'Get Started';

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
