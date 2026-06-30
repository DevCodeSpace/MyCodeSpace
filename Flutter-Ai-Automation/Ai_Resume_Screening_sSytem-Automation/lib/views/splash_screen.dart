import 'dart:async';
import 'package:ai_resume_demo/views/resume_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  String _loadingText = "Loading systems...";

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Update loading status text at intervals to simulate actual initialization steps
    Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _loadingText = "Initializing AI analysis engine...");
    });
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _loadingText = "Loading screening intelligence...");
    });
    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _loadingText = "System ready.");
    });

    _progressController.forward().then((_) {
      // Transition smoothly once loading finishes
      Get.off(
        () => ResumeScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 800),
      );
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Cybernetic central background glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withOpacity(0.08),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          
          // Foreground Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animation with zoom-in back elastic followed by shimmer
                Image.asset(
                  'assets/images/logo.png',
                  height: 140,
                  width: 140,
                  fit: BoxFit.contain,
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.elasticOut,
                      duration: 1200.ms,
                    )
                    .then(delay: 200.ms)
                    .shimmer(
                      duration: 1800.ms,
                      color: const Color(0xFF00E5FF).withOpacity(0.3),
                    ),
                
                const SizedBox(height: 28),
                
                // Title with neon glow
                Text(
                  'RESUME AI',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.5,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF00E5FF).withOpacity(0.6),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                
                const SizedBox(height: 10),
                
                // Subtitle
                Text(
                  'INTELLIGENCE-DRIVEN SCREENING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: Colors.white.withOpacity(0.5),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                
                const SizedBox(height: 72),
                
                // Progress Loader
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return Column(
                      children: [
                        // Neon Progress Bar track
                        Container(
                          width: 220,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 220 * _progressController.value,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00B8D4),
                                    Color(0xFF00E5FF),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withOpacity(0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1.5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Dynamic Status Text
                        Text(
                          _loadingText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
