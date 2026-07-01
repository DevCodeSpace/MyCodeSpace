import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/theme/app_theme.dart';
import 'app_dock_nav.dart';

class AppExpansionMenu extends StatefulWidget {
  const AppExpansionMenu({super.key, required this.active});

  final DockTab active;

  @override
  State<AppExpansionMenu> createState() => _AppExpansionMenuState();
}

class _AppExpansionMenuState extends State<AppExpansionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _isExpanded ? 300 : 72,
      width: _isExpanded ? 300 : 72,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          _buildMenuItem(
            index: 0,
            icon: Icons.grid_view_rounded,
            label: 'Home',
            route: AppRoutes.home,
            active: widget.active == DockTab.home,
          ),
          _buildMenuItem(
            index: 1,
            icon: Icons.radar_rounded,
            label: 'Radar',
            route: AppRoutes.discovery,
            active: widget.active == DockTab.radar,
          ),
          _buildMenuItem(
            index: 2,
            icon: Icons.folder_open_rounded,
            label: 'Vault',
            route: AppRoutes.send,
            active: widget.active == DockTab.vault,
          ),
          _buildMenuItem(
            index: 3,
            icon: Icons.history_toggle_off_rounded,
            label: 'Log',
            route: AppRoutes.history,
            active: widget.active == DockTab.log,
          ),
          _buildMainButton(),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
    required String route,
    required bool active,
  }) {
    // Distribute items along a perfect 90-degree arc with ample spacing
    final double angle = (index * 30.0) * math.pi / 180;
    const double distance = 160.0;

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final double offset = _expandAnimation.value * distance;
        return Transform.translate(
          offset: Offset(-math.cos(angle) * offset, -math.sin(angle) * offset),
          child: Opacity(
            opacity: _expandAnimation.value,
            child: Transform.scale(scale: _expandAnimation.value, child: child),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          _toggle();
          Get.offAllNamed(route);
        },
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: active
                ? AppTheme.gold
                : AppTheme.panelBlue.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.gold.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.white, width: 2.5),
          ),
          child: Icon(
            icon,
            color: active ? Colors.white : AppTheme.gold,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _expandAnimation.value * math.pi / 4,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.gold, Color(0xFF6397FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gold.withValues(alpha: 0.35),
                    blurRadius: 25,
                    spreadRadius: -2,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3.5),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }
}
