import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_theme.dart';
import '../../domain/entities/device.dart';
import '../controllers/connection_controller.dart';
import '../widgets/app_dock_nav.dart';
import '../widgets/app_shell.dart';
import '../widgets/brand_header.dart';
import '../widgets/frosted_panel.dart';

class DeviceDiscoveryScreen extends StatefulWidget {
  const DeviceDiscoveryScreen({super.key});

  @override
  State<DeviceDiscoveryScreen> createState() => _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends State<DeviceDiscoveryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final connectionController = Get.find<ConnectionController>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    connectionController.startContinuousDiscovery();
  }

  @override
  void dispose() {
    connectionController.stopContinuousDiscovery();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      activeTab: DockTab.radar,
      child: Column(
        children: [
          const BrandHeader(showBell: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 10),
                // --- RADAR SECTION ---
                LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth;
                    final radarSize = size.clamp(280.0, 440.0);
                    return SizedBox(
                      height: radarSize,
                      width: radarSize,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ambient glow behind radar
                          _GlowOrb(color: AppTheme.gold.withValues(alpha: 0.15), size: radarSize * 0.8),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, _) {
                              return Obx(
                                () => CustomPaint(
                                  size: Size(radarSize, radarSize),
                                  painter: _RadarPainter(progress: _controller.value),
                                  child: Stack(
                                    children: [
                                      // Central Node
                                      Center(
                                        child: Container(
                                          width: radarSize * 0.22,
                                          height: radarSize * 0.22,
                                          decoration: BoxDecoration(
                                            color: AppTheme.surface,
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 2)],
                                            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5), width: 2),
                                          ),
                                          child: Icon(Icons.track_changes_rounded, size: radarSize * 0.1, color: AppTheme.gold),
                                        ),
                                      ),
                                      ..._buildDeviceMarkers(
                                        connectionController.discoveredDevices,
                                        radarSize: radarSize,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // --- STATUS PANEL ---
                Obx(
                  () => FrostedPanel(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.sensors_rounded, color: AppTheme.gold),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(connectionController.statusText.value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                  const Text('Visible to nearby nodes', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                                ],
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: connectionController.scanNow,
                            //   child: Container(
                            //     padding: const EdgeInsets.symmetric(
                            //       horizontal: 18,
                            //       vertical: 10,
                            //     ),
                            //     decoration: BoxDecoration(
                            //       color: AppTheme.gold,
                            //       borderRadius: BorderRadius.circular(16),
                            //       boxShadow: [
                            //         BoxShadow(
                            //           color: AppTheme.gold.withValues(
                            //             alpha: 0.2,
                            //           ),
                            //           blurRadius: 12,
                            //           offset: const Offset(0, 4),
                            //         ),
                            //       ],
                            //     ),
                            //     child: const Text(
                            //       'Scan Now',
                            //       style: TextStyle(
                            //         color: Colors.white,
                            //         fontWeight: FontWeight.w700,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDeviceMarkers(List<Device> devices, {required double radarSize}) {
    if (devices.isEmpty) return const <Widget>[];

    final double radius = radarSize * 0.36; // Responsive orbit distance
    final double center = radarSize / 2;

    return devices.asMap().entries.map((entry) {
      final index = entry.key;
      final device = entry.value;

      // Calculate angle for each device
      final double angle = (index * (2 * math.pi / devices.length)) - (math.pi / 2);

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Subtle pulse/float effect
          final double floatOffset = math.sin(_controller.value * 2 * math.pi + index) * 5;
          const double markerSize = 64.0;
          return Positioned(
            left: center + (math.cos(angle) * radius) - (markerSize / 2),
            top: center + (math.sin(angle) * radius) - (markerSize / 2) + floatOffset,
            child: child!,
          );
        },
        child: GestureDetector(
          onTap: () => connectionController.sendPairingRequest(device),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3), width: 2),
                  boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: -4)],
                ),
                child: Icon(device.kind == DeviceKind.tablet ? Icons.tablet_mac_rounded : Icons.smartphone_rounded, color: AppTheme.gold, size: 28),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.gold.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  device.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
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

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Background circles (rings)
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.gold.withValues(alpha: 0.12);

    for (final r in [radius * 0.35, radius * 0.65, radius * 0.95]) {
      canvas.drawCircle(center, r, ringPaint);
    }

    // Rotating Beam (Sweep)
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: [AppTheme.gold.withValues(alpha: 0.0), AppTheme.gold.withValues(alpha: 0.25), AppTheme.gold.withValues(alpha: 0.0)],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(progress * math.pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, sweepPaint);

    // Animated Waves
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress + (i * 0.33)) % 1;
      final waveRadius = radius * waveProgress;
      final opacity = (1 - waveProgress).clamp(0.0, 1.0) * 0.35;

      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppTheme.gold.withValues(alpha: opacity);

      canvas.drawCircle(center, waveRadius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
