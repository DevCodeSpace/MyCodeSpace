// lib/app/modules/splash/splash_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    // Pulse animation for radar rings
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

    // Vertical scan beam animation
    _scanController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    // Fade-in entry animation for text/branding
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    // Start fade-in and set timer to navigate to Home
    _fadeController.forward();
    Timer(const Duration(milliseconds: 2800), () {
      Get.offNamed(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Premium Dark Gradient Background ─────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF0A0D14), Color(0xFF141923), Color(0xFF0F131C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),

          // Decorative grid pattern in background
          Positioned.fill(
            child: Opacity(opacity: 0.05, child: CustomPaint(painter: _GridPainter())),
          ),

          // ── Main Content Column ──────────────────────────────────────────
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Biometric Scanning Core
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing Radar Rings
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(220, 220),
                            painter: _RadarPainter(pulseVal: _pulseController.value, color: const Color(0xFF00E5FF)),
                          );
                        },
                      ),

                      // Scanning Frame and Beam
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glowing scanning corners
                            CustomPaint(
                              size: const Size(140, 140),
                              painter: _ScannerFramePainter(color: const Color(0xFF00E5FF)),
                            ),

                            // Glowing Central Biometric Icon (Face/Shield)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.06),
                                boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.08), blurRadius: 24, spreadRadius: 2)],
                              ),
                              child: Image.asset("assets/images/logo.png", width: 100, height: 100),
                              // const Icon(Icons.face_retouching_natural, size: 56, color: Color(0xFF00E5FF)),
                            ),

                            // Scanning Beam
                            AnimatedBuilder(
                              animation: _scanController,
                              builder: (context, child) {
                                return Positioned(
                                  top: 10 + (_scanController.value * 120),
                                  left: 8,
                                  right: 8,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF),
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.8), blurRadius: 10, spreadRadius: 2)],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 1),

                  // ── Branding Section ─────────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeController,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic)),
                      child: Column(
                        children: [
                          // Glow backing for app title
                          Text(
                            'Smart Attend',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              foreground: Paint()
                                ..shader = const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF00A3FF)]).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                              shadows: [Shadow(color: const Color(0xFF00E5FF).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4))],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'FACE ATTENDANCE SYSTEM',
                            style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Footer Loading Indicators ──────────────────────────────
                  FadeTransition(
                    opacity: _fadeController,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: Color(0xFF00E5FF), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'SECURE BIOMETRIC LOG IN',
                              style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Mini glowing linear indicator
                        SizedBox(
                          width: 140,
                          height: 2,
                          child: LinearProgressIndicator(backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF))),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Painters for stunning visual effects ────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RadarPainter extends CustomPainter {
  final double pulseVal;
  final Color color;

  _RadarPainter({required this.pulseVal, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Pulse rings
    for (int i = 0; i < 3; i++) {
      final t = (pulseVal + i / 3.0) % 1.0;
      final radius = maxRadius * t;
      final opacity = (1.0 - t) * 0.25;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + (1.5 * (1.0 - t));

      canvas.drawCircle(center, radius, paint);
    }

    // Static dashed border ring
    final staticPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, maxRadius * 0.8, staticPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.pulseVal != pulseVal;
  }
}

class _ScannerFramePainter extends CustomPainter {
  final Color color;

  _ScannerFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 20.0;
    final w = size.width;
    final h = size.height;

    // Top Left Corner
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top Right Corner
    canvas.drawLine(Offset(w, 0), Offset(w - cornerLength, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerLength), paint);

    // Bottom Left Corner
    canvas.drawLine(Offset(0, h), Offset(cornerLength, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - cornerLength), paint);

    // Bottom Right Corner
    canvas.drawLine(Offset(w, h), Offset(w - cornerLength, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
