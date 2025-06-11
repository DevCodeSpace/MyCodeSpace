// SPLASH SCREEN
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:soothly/Controller/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: controller.logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: math.max(0.0, controller.logoScale.value),
                    child: Transform.rotate(
                      angle: controller.logoRotation.value * 2 * math.pi,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.flash_on,
                          size: 60,
                          color: Color(0xFF667eea),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 40),

              Obx(() => Text(
                    controller.appName.value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  )),

              SizedBox(height: 80),

              // Loading Progress
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    Obx(() => Text(
                          controller.loadingText.value,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        )),
                    SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: controller.loadingProgress,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: math.max(
                              0.0, math.min(1.0, controller.loadingProgress.value)),
                          backgroundColor: Colors.white30,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
