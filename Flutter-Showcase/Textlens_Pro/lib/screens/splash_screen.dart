import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _scanController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;
  late final Animation<double> _scanProgress;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.4)),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _scanProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        blurRadius: 32,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/logo/logo_text_pro.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // App name + tagline
            FadeTransition(
              opacity: _textFade,
              child: const Column(
                children: [
                  Text(
                    'TextLens Pro',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.8,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Scan · Search · Extract',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Scanner animation
            FadeTransition(
              opacity: _textFade,
              child: _ScannerFrame(progress: _scanProgress),
            ),
          ],
        ),
      ),
    );
  }
}

/// Corner-bracket frame with an animated scan line.
class _ScannerFrame extends StatelessWidget {
  final Animation<double> progress;

  const _ScannerFrame({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      height: 72,
      child: AnimatedBuilder(
        animation: progress,
        builder: (_, __) => CustomPaint(
          painter: _ScanFramePainter(progress: progress.value),
        ),
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  final double progress;
  _ScanFramePainter({required this.progress});

  static const _corner = 18.0;
  static const _strokeW = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final bracketPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = _strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(const Offset(0, _corner), Offset.zero, bracketPaint);
    canvas.drawLine(Offset.zero, const Offset(_corner, 0), bracketPaint);
    // Top-right
    canvas.drawLine(
        Offset(size.width - _corner, 0), Offset(size.width, 0), bracketPaint);
    canvas.drawLine(
        Offset(size.width, 0), Offset(size.width, _corner), bracketPaint);
    // Bottom-left
    canvas.drawLine(
        Offset(0, size.height - _corner), Offset(0, size.height), bracketPaint);
    canvas.drawLine(
        Offset(0, size.height), Offset(_corner, size.height), bracketPaint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - _corner, size.height),
        Offset(size.width, size.height), bracketPaint);
    canvas.drawLine(Offset(size.width, size.height - _corner),
        Offset(size.width, size.height), bracketPaint);

    // Scan line
    final y = progress * size.height;
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0),
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, y, size.width, 2))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(10, y), Offset(size.width - 10, y), linePaint);
  }

  @override
  bool shouldRepaint(_ScanFramePainter old) => old.progress != progress;
}
