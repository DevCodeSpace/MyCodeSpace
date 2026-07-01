import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_container.dart';
import 'splash_controller.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: GlacierColors.background,
      body: Stack(
        children: [
          // Background Atmospheric Mesh
          Positioned.fill(
            child: Container(decoration: const BoxDecoration(gradient: GlacierColors.bgMeshGradient)),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(shape: BoxShape.circle, color: GlacierColors.primary.withValues(alpha: 0.08)),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(shape: BoxShape.circle, color: GlacierColors.tertiary.withValues(alpha: 0.06)),
            ),
          ),

          // Main Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Motif
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Glass Ring
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: GlacierColors.primary.withValues(alpha: 0.1), width: 2),
                          ),
                        ),
                        // Inner Rotating Motif
                        RotationTransition(
                          turns: _rotationController,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.transparent),
                            ),
                            child: CircularProgressIndicator(
                              value: 0.25,
                              strokeWidth: 2,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(GlacierColors.primary.withValues(alpha: 0.4)),
                            ),
                          ),
                        ),
                        // Reverse Rotating Motif
                        RotationTransition(
                          turns: ReverseAnimation(_rotationController),
                          child: SizedBox(
                            width: 110,
                            height: 110,
                            child: CircularProgressIndicator(
                              value: 0.15,
                              strokeWidth: 1.5,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(GlacierColors.tertiary.withValues(alpha: 0.3)),
                            ),
                          ),
                        ),
                        // Central Core Box
                        GlassContainer(
                          width: 80,
                          height: 80,
                          borderRadius: 24,
                          elevated: true,
                          opacity: 0.75,
                          borderColor: GlacierColors.primary.withValues(alpha: 0.2),
                          child: Center(child: Image.asset('assets/logo.png', height: 60)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // App Identity
                  Text(
                    'APP USAGE TRACKER',
                    style: GlacierTextStyles.headline.copyWith(color: GlacierColors.onSurface, letterSpacing: 2),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'REFINE YOUR DIGITAL FOCUS',
                    style: GlacierTextStyles.labelSmall.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.6), letterSpacing: 3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Tagline Pill
                  GlassContainer(
                    borderRadius: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    opacity: 0.1,
                    borderColor: GlacierColors.primary.withValues(alpha: 0.05),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: GlacierColors.primary),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Intelligent usage analytics',
                          style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.onSurfaceVariant, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),

                  // Getting Ready Loading Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(GlacierColors.primary))),
                      const SizedBox(width: 10),
                      Text(
                        'App is getting ready...',
                        style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),

          // Footnote Brand
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'StayOnTrack',
                style: GlacierTextStyles.labelSmall.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.4), letterSpacing: 4.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
