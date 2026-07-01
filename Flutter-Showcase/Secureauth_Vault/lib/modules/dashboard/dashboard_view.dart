import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => controller.onUserInteraction(),
      child: Obx(
        () => Scaffold(
          extendBody: true,
          body: IndexedStack(index: controller.currentIndex.value, children: controller.pages),
          bottomNavigationBar: _buildPremiumBottomBar(context),
        ),
      ),
    );
  }

  Widget _buildPremiumBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final backgroundColor = isDark ? const Color(0xBE111827) : const Color(0xBEFFFFFF);
    final borderColor = isDark ? const Color(0x33374151) : const Color(0x1F374151);

    return Obx(() {
      final selectedIndex = controller.currentIndex.value;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4), // Slightly deeper padding for a cleaner float
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06),
                  blurRadius: 30,
                  spreadRadius: -2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.lock_outline_rounded,
                        activeIcon: Icons.lock_rounded,
                        label: 'Vault',
                        isSelected: selectedIndex == 0,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.folder_outlined,
                        activeIcon: Icons.folder_rounded,
                        label: 'Files',
                        isSelected: selectedIndex == 1,
                        activeColor: isDark ? const Color(0xFF60A5FA) : activeColor,
                        inactiveColor: inactiveColor,
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.qr_code_scanner_rounded,
                        activeIcon: Icons.qr_code_scanner_rounded,
                        label: 'Auth',
                        isSelected: selectedIndex == 2,
                        activeColor: isDark ? const Color(0xFF2DD4BF) : activeColor,
                        inactiveColor: inactiveColor,
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.settings_outlined,
                        activeIcon: Icons.settings_rounded,
                        label: 'Settings',
                        isSelected: selectedIndex == 3,
                        activeColor: isDark ? const Color(0xFFA78BFA) : activeColor,
                        inactiveColor: inactiveColor,
                      ),
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

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey<bool>(isSelected),
                  color: isSelected ? activeColor : inactiveColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : inactiveColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
