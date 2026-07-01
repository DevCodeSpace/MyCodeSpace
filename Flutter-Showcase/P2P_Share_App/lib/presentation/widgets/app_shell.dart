import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

import 'app_dock_nav.dart';
import 'app_expansion_menu.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.activeTab,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final DockTab? activeTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          children: [
            Positioned(
              top: 60,
              right: -80,
              child: _GlowOrb(
                color: AppTheme.gold.withValues(alpha: 0.08),
                size: 260,
              ),
            ),
            Positioned(
              top: 120,
              left: -110,
              child: _GlowOrb(color: const Color(0xFFDEEAFE), size: 340),
            ),
            SafeArea(child: child),
            if (activeTab != null)
              Positioned(
                right: 20,
                bottom: bottomNavigationBar != null ? 10 : 20,
                child: SafeArea(
                  child: AppExpansionMenu(active: activeTab!),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
