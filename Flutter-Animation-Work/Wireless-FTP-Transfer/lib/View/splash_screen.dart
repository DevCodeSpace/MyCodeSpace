// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:animations_app/Export/export.dart';
import 'package:animations_app/View/CustomPainter/splash_screen_painter/splash_circuit_pattern_painter.dart';
import 'package:animations_app/View/CustomPainter/splash_screen_painter/splash_wave_pattern_painter.dart';
import 'package:animations_app/View/choose_option.dart';
import 'package:animations_app/View/onboarding_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// SplashScreen widget that displays an animated splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers for various animations
  late final AnimationController _fadeController;
  late final AnimationController _iconRotationController;
  late final AnimationController _iconScaleController;
  late final AnimationController _patternAnimationController;
  late final AnimationController _waveController;
  late final AnimationController _pulseController;

  // Animations for fade, slide, scale, opacity, wave, and pulse effects
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _iconScale;
  late final Animation<double> _patternOpacity;
  late final Animation<double> _waveAnimation;
  late final Animation<double> _pulseAnimation;

  // Constants for animation durations and logo size
  static const Duration _animationDuration = Duration(milliseconds: 1500);
  static const Duration _navigationDelay = Duration(seconds: 3);
  static const double _logoSize = 150.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations(); // Initialize all animations
    _handleNavigation(); // Handle navigation after delay
  }

  // Method to initialize all animation controllers and animations
  void _initializeAnimations() {
    // Main fade and slide controller
    _fadeController = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    // Pattern and icon animation controllers
    _iconRotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(); // Repeat the rotation animation indefinitely

    _iconScaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true); // Repeat the scale animation with reverse

    _patternAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(
        reverse: true); // Repeat the pattern opacity animation with reverse

    // New wave effect controller
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Repeat the wave animation indefinitely

    // New pulse effect controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true); // Repeat the pulse animation with reverse

    // Setup animations
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _iconScale = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _iconScaleController,
      curve: Curves.easeInOutBack,
    ));

    _patternOpacity = Tween<double>(
      begin: 0.1,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _patternAnimationController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward(); // Start the fade animation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeController,
          _iconRotationController,
          _iconScaleController,
          _patternAnimationController,
          _waveController,
          _pulseController,
        ]),
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Animated background pattern with waves
              _buildAnimatedBackground(),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAnimatedLogo(),
                    const SizedBox(height: 40),
                    _buildAnimatedTexts(),
                    const SizedBox(height: 60),
                    _buildEnhancedLoadingIndicator(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Method to build the animated background with rotating pattern and wave effect
  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Rotating pattern
        Center(
          child: Opacity(
            opacity: _patternOpacity.value,
            child: Transform.rotate(
              angle: _iconRotationController.value * 2 * math.pi,
              child: CustomPaint(
                size: const Size(300, 300),
                painter: CircuitPatternPainter(
                  color: const Color(0xFF00B0FF)
                      .withOpacity(_patternOpacity.value),
                  progress: _iconRotationController.value,
                ),
              ),
            ),
          ),
        ),
        // Wave effect
        CustomPaint(
          painter: WavePainter(
            waveAnimation: _waveAnimation.value,
            color: const Color(0xFF00B0FF).withOpacity(0.1),
          ),
          size: Size.infinite,
        ),
      ],
    );
  }

  // Method to build the animated logo with fade, slide, scale, and pulse effects
  Widget _buildAnimatedLogo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Transform.scale(
          scale: _iconScale.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse effect
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: _logoSize + 20,
                  height: _logoSize + 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B0FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Main logo
              Container(
                width: _logoSize,
                height: _logoSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00B0FF).withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: const Color(0xFF00B0FF).withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'app_logo',
                  child: Image.asset('assets/appstore.png').paddingAll(25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to handle navigation after a delay
  Future<void> _handleNavigation() async {
    try {
      await Future.delayed(_navigationDelay);
      if (!mounted) return;

      final bool isOnboardingComplete = await _checkOnboardingStatus();
      if (!mounted) return;

      await _navigateToNextScreen(isOnboardingComplete);
    } catch (e) {
      _showError(e.toString());
    }
  }

  // Method to check if onboarding is complete
  Future<bool> _checkOnboardingStatus() async {
    return Settings.isOnBoardingComplete;
  }

  // Method to navigate to the next screen based on onboarding status
  Future<void> _navigateToNextScreen(bool isOnboardingComplete) async {
    Settings.isOnBoardingComplete = true;
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            isOnboardingComplete
                ? const TransferMethodSelector()
                : const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
  }

  // Method to build animated texts with fade, slide, and pulse effects
  Widget _buildAnimatedTexts() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: const [
                  Color(0xFF00B0FF),
                  Color(0xFF0091EA),
                  Color(0xFF00B0FF),
                ],
                stops: [
                  0.0,
                  0.5 + (_pulseAnimation.value - 1),
                  1.0,
                ],
              ).createShader(bounds),
              child: Text(
                'Wireless FTP File Transfer',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Transform.scale(
              scale: 1.0 + (_pulseAnimation.value - 1) * 0.1,
              child: Text(
                'Wireless File Transfer Made Easy',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
                animation: _iconRotationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      4 * math.sin(_iconRotationController.value * 2 * math.pi),
                      4 * math.cos(_iconRotationController.value * 2 * math.pi),
                    ),
                    child: Text(
                      'Fast • Secure • Reliable',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }

  // Method to show an error message using a SnackBar
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $message'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Method to build an enhanced loading indicator with pulse effect
  Widget _buildEnhancedLoadingIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00B0FF).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00B0FF).withOpacity(0.2),
                      ),
                    ),
                  ),
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF00B0FF)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF00B0FF),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all animation controllers to free up resources
    _fadeController.dispose();
    _iconRotationController.dispose();
    _iconScaleController.dispose();
    _patternAnimationController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}
