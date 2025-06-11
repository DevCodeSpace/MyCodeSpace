// SPLASH CONTROLLER
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController logoController;
  late AnimationController loadingController;
  late Animation<double> logoScale;
  late Animation<double> logoRotation;
  late Animation<double> loadingProgress;

  var appName = 'FlutterApp'.obs;
  var loadingText = 'Loading...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    logoController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    loadingController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: logoController, curve: Curves.elasticOut),
    );

    logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: logoController, curve: Curves.easeInOut),
    );

    loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: loadingController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() async {
    await logoController.forward();
    loadingController.forward();

    loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Get.offNamed('/onboarding');
      }
    });
  }

  @override
  void onClose() {
    logoController.dispose();
    loadingController.dispose();
    super.onClose();
  }
}
