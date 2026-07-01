import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:track_app_usage/core/services/usage_service.dart';
import 'package:track_app_usage/core/widgets/glass_button.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}

class NavigationScaffold extends StatelessWidget {
  final List<Widget> pages;

  const NavigationScaffold({super.key, required this.pages});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      backgroundColor: GlacierColors.background,
      body: Obx(() {
        final usageService = Get.find<UsageService>();

        if (!usageService.isPermissionGranted.value) {
          return _buildPermissionGate(usageService);
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 768) {
              return _buildDesktopView(controller);
            } else {
              return _buildMobileView(controller);
            }
          },
        );
      }),
    );
  }

  Widget _buildDesktopView(NavigationController controller) {
    return Row(
      children: [
        _buildSideNavRail(controller),
        Expanded(
          child: Obx(() {
            return IndexedStack(index: controller.currentIndex.value, children: pages);
          }),
        ),
      ],
    );
  }

  Widget _buildMobileView(NavigationController controller) {
    return Obx(() {
      return Stack(
        children: [
          IndexedStack(index: controller.currentIndex.value, children: pages),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNavBar(controller)),
        ],
      );
    });
  }

  Widget _buildPermissionGate(UsageService usageService) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFD2BBFF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD2BBFF).withValues(alpha: 0.25), width: 1),
              ),
              child: const Icon(Icons.shield_outlined, color: Color(0xFFD2BBFF), size: 28),
            ),

            const SizedBox(height: 24),

            Text(
              "One permission\nto get started",
              style: GlacierTextStyles.titleMedium.copyWith(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2, color: GlacierColors.onSurface),
            ),

            const SizedBox(height: 12),

            Text(
              "Glacier needs Usage Access to track how long you spend in each app. Your data never leaves your device.",
              style: GlacierTextStyles.labelSmall.copyWith(fontSize: 14, height: 1.2, color: GlacierColors.onSurface.withValues(alpha: 0.55)),
            ),

            const SizedBox(height: 32),

            ...[
              (Icons.bar_chart_rounded, "Per-app hourly breakdowns"),
              (Icons.notifications_none_rounded, "Smart limit alerts"),
              (Icons.lock_outline_rounded, "Fully private, on-device only"),
            ].map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(item.$1, size: 20, color: const Color(0xFFD2BBFF)),
                    Text(item.$2, style: GlacierTextStyles.labelSmall.copyWith(fontSize: 13, color: GlacierColors.onSurface.withValues(alpha: 0.75))),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 3),

            GlassButton(
              // ✅ This updates isPermissionGranted which triggers Obx rebuild
              onPressed: usageService.requestUsagePermission,
              text: "Grant Access",
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                "You can revoke this anytime in Settings",
                style: GlacierTextStyles.labelSmall.copyWith(fontSize: 11, color: GlacierColors.onSurface.withValues(alpha: 0.3)),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(NavigationController controller) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: GlacierColors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GlacierColors.onSurfaceVariant.withValues(alpha: 0.1), width: 1.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      _buildNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Home', index: 0, controller: controller),
                      _buildNavItem(icon: Icons.widgets_outlined, activeIcon: Icons.widgets, label: 'Apps', index: 1, controller: controller),
                      _buildNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', index: 3, controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem({required int index, required IconData icon, required IconData activeIcon, required String label, required NavigationController controller}) {
    final isSelected = controller.currentIndex.value == index;
    final activeColor = GlacierColors.primary;
    final inactiveColor = GlacierColors.onSurfaceVariant.withValues(alpha: 0.55);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.changePage(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(isSelected ? activeIcon : icon, key: ValueKey<bool>(isSelected), color: isSelected ? activeColor : inactiveColor, size: 22),
              ),
              const SizedBox(height: 4),
              Text(label, style: GlacierTextStyles.labelSmall.copyWith(color: isSelected ? activeColor : inactiveColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideNavRail(NavigationController controller) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: GlacierColors.surface.withValues(alpha: 0.3),
            border: const Border(
              right: BorderSide(
                color: Color(0x0FD2BBFF), // 6% opacity primary
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // App Logo at the top
              const Icon(Icons.bubble_chart, color: GlacierColors.primary, size: 32),
              const SizedBox(height: 64),
              // Nav Rail Items
              Obx(() {
                return Column(
                  children: [
                    _buildRailNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, index: 0, controller: controller),
                    const SizedBox(height: 24),
                    _buildRailNavItem(icon: Icons.widgets_outlined, activeIcon: Icons.widgets, index: 1, controller: controller),
                    const SizedBox(height: 24),
                    _buildRailNavItem(icon: Icons.insert_chart_outlined, activeIcon: Icons.insert_chart, index: 2, controller: controller),
                    const SizedBox(height: 24),
                    _buildRailNavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, index: 3, controller: controller),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRailNavItem({required IconData icon, required IconData activeIcon, required int index, required NavigationController controller}) {
    final isActive = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changePage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: isActive ? GlacierColors.primary.withValues(alpha: 0.15) : Colors.transparent, borderRadius: BorderRadius.circular(16)),
        child: Icon(isActive ? activeIcon : icon, color: isActive ? GlacierColors.primary : GlacierColors.onSurfaceVariant.withValues(alpha: 0.7), size: 28),
      ),
    );
  }
}
