import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Colors.blue.shade50]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 1500),
              child: ZoomIn(
                duration: const Duration(milliseconds: 1000),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 30, spreadRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset('assets/images/app_logo.png', fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 500),
              child: Text(
                'Bluchat',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade800, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 10),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 800),
              child: Text(
                'Connect. Chat. Share.',
                style: TextStyle(fontSize: 16, color: Colors.blue.shade400, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 60),
            // FadeIn(
            //   duration: const Duration(milliseconds: 1000),
            //   delay: const Duration(milliseconds: 1200),
            //   child: SizedBox(width: 40, height: 40, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade800))),
            // ),
          ],
        ),
      ),
    );
  }
}
