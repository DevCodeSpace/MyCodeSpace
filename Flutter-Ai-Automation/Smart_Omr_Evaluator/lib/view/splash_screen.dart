import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:ai_omr_check/view/orm_upload_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    Get.offAll(() => OmrUploadScreen(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // Dynamic Glowing Violet Ambient Light
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary.withValues(alpha: 0.15)),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.3, duration: 2000.ms, curve: Curves.easeInOut).fadeIn(duration: 1000.ms),

          // Dynamic Glowing Magenta Ambient Light
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: colors.secondary.withValues(alpha: 0.15)),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.3, duration: 2200.ms, curve: Curves.easeInOut).fadeIn(duration: 1000.ms),

          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Logo Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.primary.withValues(alpha: 0.15), width: 2),
                    boxShadow: [
                      BoxShadow(color: colors.primary.withValues(alpha: 0.15), blurRadius: 30, spreadRadius: 2),
                      BoxShadow(color: colors.secondary.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    width: 100,
                    errorBuilder: (context, error, stackTrace) => Icon(LucideIcons.scanLine, size: 80, color: colors.primary),
                  ),
                ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack).then().shimmer(duration: 1200.ms, color: colors.secondary.withValues(alpha: 0.2)),

                const SizedBox(height: 36),

                // Animated App Title
                // Text(
                //   'Smart OMR Evaluator',
                //   style: TextStyle(
                //     fontSize: 24,
                //     fontWeight: FontWeight.w900,
                //     letterSpacing: 10,
                //     color: const Color(0xFF0F172A),
                //     shadows: [Shadow(color: colors.primary.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 5))],
                //   ),
                // ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad),

                // const SizedBox(height: 8),

                // Neon Tagline
                Text(
                  'Smart OMR Evaluator',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 5,
                    color: colors.primary,
                    shadows: [Shadow(color: colors.primary.withValues(alpha: 0.15), blurRadius: 10)],
                  ),
                ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
