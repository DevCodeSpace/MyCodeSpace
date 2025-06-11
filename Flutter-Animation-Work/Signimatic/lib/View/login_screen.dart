// Login Screen View
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signimatic/Controller/login_controller.dart';

// Main LoginScreen widget using GetX architecture
class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(), // Dynamic gradient background
          _buildFloatingParticles(), // Floating particle animation
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildLoginCard(), // Login form card
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Creates animated gradient background using sine/cosine wave functions
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: controller.backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.3, 0.6, 1.0],
              colors: [
                Color.lerp(
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                  math.sin(controller.backgroundAnimation.value * math.pi * 2) *
                          0.5 +
                      0.5,
                )!,
                Color.lerp(
                  const Color(0xFF0F3460),
                  const Color(0xFF533483),
                  math.cos(controller.backgroundAnimation.value * math.pi * 2) *
                          0.5 +
                      0.5,
                )!,
                Color.lerp(
                  const Color(0xFFE94560),
                  const Color(0xFF7209B7),
                  math.sin(
                            controller.backgroundAnimation.value * math.pi * 2 +
                                1,
                          ) *
                          0.5 +
                      0.5,
                )!,
                Color.lerp(
                  const Color(0xFF2D1B69),
                  const Color(0xFF11998E),
                  math.cos(
                            controller.backgroundAnimation.value * math.pi * 2 +
                                1,
                          ) *
                          0.5 +
                      0.5,
                )!,
              ],
            ),
          ),
        );
      },
    );
  }

  // Creates floating particles on the background for aesthetic animation
  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: controller.particleAnimation,
      builder: (context, child) {
        return Stack(
          children: List.generate(20, (index) {
            final random = math.Random(index);
            final x = random.nextDouble() * Get.width;
            final y = random.nextDouble() * Get.height;
            final size = random.nextDouble() * 6 + 2;
            final speed = random.nextDouble() * 2 + 1;

            return Positioned(
              left: x,
              top:
                  y -
                  (controller.particleAnimation.value * speed * 100) %
                      (Get.height + 100),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.05),
                      blurRadius: size,
                      spreadRadius: size / 2,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Builds the main login card with animation
  Widget _buildLoginCard() {
    return AnimatedBuilder(
      animation: controller.cardController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, controller.cardSlideAnimation.value),
          child: Transform.scale(
            scale: controller.cardScaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(), // App icon + title text
                  const SizedBox(height: 40),
                  _buildForm(), // Email & password fields
                  const SizedBox(height: 32),
                  _buildLoginButton(), // Login button
                  const SizedBox(height: 24),
                  _buildFooter(), // Social login & signup prompt
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Builds the circular icon and welcome text
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.fingerprint, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to your account',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  // Builds the form with animated appearance
  Widget _buildForm() {
    return AnimatedBuilder(
      animation: controller.fieldController,
      builder: (context, child) {
        return Opacity(
          opacity: controller.fieldFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, controller.fieldSlideAnimation.value),
            child: Column(
              children: [
                _buildGlassTextField(
                  controller: controller.emailController,
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                Obx(
                  () => _buildGlassTextField(
                    controller: controller.passwordController,
                    icon: Icons.lock_outline,
                    label: 'Password',
                    isPassword: true,
                    isVisible: controller.isPasswordVisible.value,
                    onVisibilityToggle: controller.togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: controller.handleForgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Custom glass-like text field with icon, password toggle, and border
  Widget _buildGlassTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword && !isVisible,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    onPressed: onVisibilityToggle,
                  )
                  : null,
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // Animated login button with loading spinner
  Widget _buildLoginButton() {
    return AnimatedBuilder(
      animation: controller.buttonController,
      builder: (context, child) {
        return Transform.scale(
          scale: controller.buttonScaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withValues(
                    alpha: 0.3 + (controller.buttonGlowAnimation.value * 0.3),
                  ),
                  blurRadius: 20 + (controller.buttonGlowAnimation.value * 10),
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child:
                    controller.isLoading.value
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Footer section with social buttons and signup prompt
  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.white.withValues(alpha: 0.3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.white.withValues(alpha: 0.3)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(Icons.g_mobiledata, 'Google'),
            _buildSocialButton(Icons.apple, 'Apple'),
            _buildSocialButton(Icons.facebook, 'Facebook'),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            GestureDetector(
              onTap: controller.navigateToSignUp,
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  color: Color(0xFF667eea),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Builds a circular social login icon button
  Widget _buildSocialButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () => controller.handleSocialLogin(label),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 24),
      ),
    );
  }
}
