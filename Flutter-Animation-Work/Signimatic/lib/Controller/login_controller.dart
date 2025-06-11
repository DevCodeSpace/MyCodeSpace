// GetX Controller for Login Screen
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController with GetTickerProviderStateMixin {
  // Animation Controllers for managing different UI animations
  late AnimationController backgroundController;
  late AnimationController cardController;
  late AnimationController fieldController;
  late AnimationController buttonController;
  late AnimationController particleController;

  // Animations
  late Animation<double> backgroundAnimation;
  late Animation<double> cardSlideAnimation;
  late Animation<double> cardScaleAnimation;
  late Animation<double> fieldFadeAnimation;
  late Animation<double> fieldSlideAnimation;
  late Animation<double> buttonScaleAnimation;
  late Animation<double> buttonGlowAnimation;
  late Animation<double> particleAnimation;

  // Observable variables to update UI reactively
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  // Text Controllers for email and password fields
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initializeAnimationControllers(); // Initialize animation controllers
    _setupAnimations();                // Setup the animation values and curves
    _startAnimations();                // Start the animations
  }

  // Initializes all animation controllers with appropriate durations
  void _initializeAnimationControllers() {
    backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    fieldController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    buttonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
  }

  // Defines how each animation behaves using Tweens and CurvedAnimations
  void _setupAnimations() {
    backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: backgroundController, curve: Curves.linear),
    );

    cardSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: cardController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    cardScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: cardController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    fieldFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: fieldController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    fieldSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: fieldController,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: buttonController,
        curve: const Interval(0.0, 0.5, curve: Curves.bounceOut),
      ),
    );

    buttonGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: buttonController, curve: Curves.easeInOut),
    );

    particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: particleController, curve: Curves.linear),
    );
  }

  // Starts all animations with optional delays for sequencing
  void _startAnimations() {
    backgroundController.repeat(); // Looping background animation
    cardController.forward();      // Slide in and scale card animation

    // Delay field fade-in and slide-up
    Future.delayed(const Duration(milliseconds: 400), () {
      fieldController.forward();
    });

    // Delay button scaling and glow animation
    Future.delayed(const Duration(milliseconds: 800), () {
      buttonController.forward();
    });

    // Loop particle animation
    particleController.repeat();
  }

  // Toggle the password visibility icon and text field state
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Handle login logic and validations
  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please fill in all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;

    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 2));

    isLoading.value = false;

    // Show login success snackbar
    Get.snackbar(
      'Success',
      'Login Successful!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF667eea),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  // Show snackbar for forgot password
  void handleForgotPassword() {
    Get.snackbar(
      'Forgot Password',
      'Reset password link sent to your email',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.8),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  // Handle social login tap (not implemented yet)
  void handleSocialLogin(String provider) {
    Get.snackbar(
      'Social Login',
      'Login with $provider coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.withValues(alpha: 0.8),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  // Navigate to Sign Up screen (currently just shows a snackbar)
  void navigateToSignUp() {
    Get.snackbar(
      'Sign Up',
      'Sign up functionality coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF667eea),
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
    );
  }

  // Dispose all controllers when the controller is destroyed
  @override
  void onClose() {
    backgroundController.dispose();
    cardController.dispose();
    fieldController.dispose();
    buttonController.dispose();
    particleController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
