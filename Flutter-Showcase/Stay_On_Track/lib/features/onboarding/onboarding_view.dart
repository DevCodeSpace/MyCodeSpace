import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/glass_button.dart';
import 'onboarding_controller.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: GlacierColors.background,
      body: Stack(
        children: [
          // Background Atmosphere Mesh
          Positioned.fill(
            child: Container(decoration: const BoxDecoration(gradient: GlacierColors.bgMeshGradient)),
          ),
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(shape: BoxShape.circle, color: GlacierColors.primary.withValues(alpha: 0.05)),
            ),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                height: 60,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bubble_chart, color: GlacierColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'StayOnTrack',
                      style: GlacierTextStyles.titleMedium.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.w800, letterSpacing: 3.0),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Layout PageView
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 80),
              child: Column(
                children: [
                  // Illustration & Graphics Area
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Obx(() {
                        return AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _buildIllustration(controller.currentPage.value));
                      }),
                    ),
                  ),

                  // Content text PageView
                  Expanded(
                    flex: 3,
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      itemCount: controller.steps.length,
                      itemBuilder: (context, index) {
                        final step = controller.steps[index];
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              step.title,
                              style: GlacierTextStyles.headline.copyWith(color: GlacierColors.onSurface),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              step.description,
                              style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.8)),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Indicators
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.steps.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: controller.currentPage.value == index ? 32 : 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: controller.currentPage.value == index ? GlacierColors.primary : GlacierColors.surfaceContainerHigh,
                            boxShadow: controller.currentPage.value == index
                                ? [BoxShadow(color: GlacierColors.primary.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)]
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),

                  // Button
                  Obx(() {
                    final isLast = controller.currentPage.value == controller.steps.length - 1;
                    return GlassButton(
                      text: isLast ? 'Get Started' : 'Continue',
                      icon: const Icon(Icons.arrow_forward, color: GlacierColors.primary, size: 20),
                      onPressed: controller.nextPage,
                    );
                  }),
                ],
              ),
            ),
          ),

          // Step Footer
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(() {
                return Text(
                  'STEP ${controller.currentPage.value + 1} OF 3',
                  style: GlacierTextStyles.labelSmall.copyWith(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.4), letterSpacing: 2.0),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(int pageIndex) {
    if (pageIndex == 0) {
      return SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular Target progress ring
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: 0.75,
                strokeWidth: 8,
                backgroundColor: GlacierColors.surfaceContainerHighest.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(GlacierColors.primary),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('75%', style: GlacierTextStyles.display.copyWith(color: GlacierColors.primary)),
                Text('DAILY TARGET', style: GlacierTextStyles.labelSmall.copyWith(color: GlacierColors.onSurfaceVariant, fontSize: 8, letterSpacing: 1.5)),
              ],
            ),

            // Floating Icons
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(80, -60 + math.sin(_floatController.value * 2 * math.pi) * 8),
                  child: GlassContainer(
                    width: 50,
                    height: 50,
                    borderRadius: 12,
                    opacity: 0.1,
                    borderColor: GlacierColors.tertiary.withValues(alpha: 0.2),
                    child: const Icon(Icons.widgets, color: GlacierColors.tertiary, size: 24),
                  ),
                );
              },
            ),

            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-80, 50 - math.sin((_floatController.value + 0.3) * 2 * math.pi) * 6),
                  child: GlassContainer(
                    width: 46,
                    height: 46,
                    borderRadius: 12,
                    opacity: 0.1,
                    borderColor: GlacierColors.secondary.withValues(alpha: 0.2),
                    child: const Icon(Icons.insert_chart, color: GlacierColors.secondary, size: 20),
                  ),
                );
              },
            ),

            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-70, -60 + math.cos(_floatController.value * 2 * math.pi) * 5),
                  child: GlassContainer(
                    width: 40,
                    height: 40,
                    borderRadius: 10,
                    opacity: 0.1,
                    borderColor: GlacierColors.onSurfaceVariant.withValues(alpha: 0.1),
                    child: const Icon(Icons.settings, color: GlacierColors.onSurfaceVariant, size: 18),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else if (pageIndex == 1) {
      return SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GlassContainer(
              width: 180,
              height: 120,
              borderRadius: 16,
              opacity: 0.1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Instagram',
                          style: GlacierTextStyles.bodyMedium.copyWith(color: GlacierColors.onSurface, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '85%',
                          style: GlacierTextStyles.bodySmall.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 4,
                        color: GlacierColors.surfaceContainerHighest.withValues(alpha: 0.3),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(widthFactor: 0.85, child: Container(color: GlacierColors.primary)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('1h 42m / 2h 00m', style: GlacierTextStyles.labelSmall.copyWith(fontSize: 8)),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(90, 40 + math.sin(_floatController.value * 2 * math.pi) * 8),
                  child: GlassContainer(
                    width: 44,
                    height: 44,
                    borderRadius: 12,
                    opacity: 0.1,
                    borderColor: GlacierColors.tertiary.withValues(alpha: 0.2),
                    child: const Icon(Icons.notifications_active, color: GlacierColors.tertiary, size: 20),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Target progress icon
            GlassContainer(
              width: 140,
              height: 140,
              borderRadius: 30,
              opacity: 0.2,
              borderColor: GlacierColors.primary.withValues(alpha: 0.1),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt, color: GlacierColors.primary, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'FOCUS MODE',
                      style: GlacierTextStyles.labelSmall.copyWith(color: GlacierColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-80, -60 + math.sin(_floatController.value * 2 * math.pi) * 7),
                  child: GlassContainer(
                    width: 44,
                    height: 44,
                    borderRadius: 12,
                    opacity: 0.1,
                    borderColor: GlacierColors.secondary.withValues(alpha: 0.2),
                    child: const Icon(Icons.bedtime, color: GlacierColors.secondary, size: 20),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
  }
}
