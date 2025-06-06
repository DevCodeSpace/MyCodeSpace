// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:animations_app/Configuration/animation_config.dart';
import 'package:animations_app/Configuration/theme_config.dart';
import 'package:animations_app/View/CustomPainter/shield_pattern_painter.dart';
import 'package:animations_app/View/CustomPainter/wave_pattern_painter.dart';
import 'package:animations_app/View/choose_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'CustomPainter/circuit_pattern_painter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  bool _isLastPage = false;
  int _currentPageIndex = 0;

  // Animation controllers
  late final AnimationController _iconRotationController;
  late final AnimationController _iconScaleController;
  late final AnimationController _patternAnimationController;
  late final AnimationController _backgroundController;

  // Animations
  late final Animation<double> _backgroundScale;
  late final Animation<double> _iconScale;
  late final Animation<double> _patternOpacity;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: 'Wireless FTP File Transfer',
      description:
          'Transform your device into a powerful FTP server! Access and transfer files wirelessly from any browser or FTP client on your network - no cables needed.',
      illustration: Icons
          .wifi_tethering_rounded, // WiFi icon to show wireless connectivity
      color: Color(0xFF00B0FF), // Bright blue for tech feel
      bgPattern: 'circuit',
    ),
    const OnboardingPage(
      title: 'Access Anywhere',
      description:
          'Browse and manage files from any device on your WiFi network. Simply enter the provided FTP address in your browser or file manager to instantly connect.',
      illustration: Icons.devices_rounded, // Shows multi-device compatibility
      color: Color(0xFF00C853), // Fresh green for accessibility
      bgPattern: 'wave',
    ),
    const OnboardingPage(
      title: 'Complete Control',
      description:
          'Upload, download, and organize files with ease. Full file management with secure password protection keeps your data safe while sharing on your local network.',
      illustration:
          Icons.folder_special_rounded, // Folder icon for file management
      color: Color(0xFFFF6D00), // Energetic orange for control
      bgPattern: 'shield',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _iconRotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _iconScaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _patternAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Initialize animations
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

    _backgroundScale = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    _iconScaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconRotationController.dispose();
    _iconScaleController.dispose();
    _patternAnimationController.dispose();
    _backgroundController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
      _isLastPage = index == _pages.length - 1;
    });
  }

  Future<void> _markOnboardingComplete() async {
    // Implement your onboarding completion logic here
  }

  void _navigateToTransferScreen() async {
    await _markOnboardingComplete();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TransferMethodSelector(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            _buildSkipButton(),
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: Listenable.merge([
                          _iconRotationController,
                          _iconScaleController,
                          _patternAnimationController,
                          _backgroundController,
                        ]),
                        builder: (context, child) {
                          return _buildPage(_pages[index]);
                        },
                      );
                    },
                  ),
                ),
                _buildBottomNavigation(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: TextButton.icon(
        onPressed: _navigateToTransferScreen,
        icon: const Icon(Icons.skip_next_rounded, size: 20),
        label: const Text(
          'Skip',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedIcon(page),
          const SizedBox(height: 48),
          _buildPageContent(page),
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(OnboardingPage page) {
    return Transform.scale(
      scale: _backgroundScale.value,
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: page.color.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: page.color.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5 * _backgroundScale.value,
            ),
            BoxShadow(
              color: page.color.withOpacity(0.1),
              blurRadius: 40,
              spreadRadius: 10 * _backgroundScale.value,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: _patternOpacity.value,
              child: Transform.rotate(
                angle: _iconRotationController.value * 2 * math.pi,
                child: _buildPatternBackground(page),
              ),
            ),
            Transform.scale(
              scale: _iconScale.value,
              child: Transform.rotate(
                angle: page.bgPattern == 'circuit'
                    ? _iconRotationController.value * 2 * math.pi
                    : 0,
                child: Icon(
                  page.illustration,
                  size: 80,
                  color: page.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(OnboardingPage page) {
    return Column(
      children: [
        Text(
          page.title,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.bold,
            color: page.color,
            height: 1.2,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          page.description,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
            height: 1.6,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmoothPageIndicator(
            controller: _pageController,
            count: _pages.length,
            effect: ExpandingDotsEffect(
              activeDotColor: _pages[_currentPageIndex].color,
              dotHeight: 8,
              dotWidth: 8,
              spacing: 6,
              expansionFactor: 3,
            ),
          ),
          _buildNavigationButton(),
        ],
      ),
    );
  }

  Widget _buildNavigationButton() {
    final currentPage = _pages[_currentPageIndex];
    return ElevatedButton(
      onPressed: () {
        if (_isLastPage) {
          _navigateToTransferScreen();
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: currentPage.color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 3,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isLastPage ? 'Get Started' : 'Continue',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            _isLastPage
                ? Icons.rocket_launch_rounded
                : Icons.arrow_forward_rounded,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternBackground(OnboardingPage page) {
    switch (page.bgPattern) {
      case 'circuit':
        return CustomPaint(
          size: const Size(200, 200),
          painter: CircuitPatternPainter(
            color: page.color.withOpacity(_patternOpacity.value),
            progress: _iconRotationController.value,
          ),
        );
      case 'wave':
        return CustomPaint(
          size: const Size(200, 200),
          painter: WavePatternPainter(
            color: page.color.withOpacity(_patternOpacity.value),
            progress: _patternAnimationController.value,
          ),
        );
      case 'shield':
        return CustomPaint(
          size: const Size(200, 200),
          painter: ShieldPatternPainter(
            color: page.color.withOpacity(_patternOpacity.value),
            progress: _patternAnimationController.value,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class OnboardingPage {
  // Core properties
  final String title;
  final String description;
  final IconData illustration;
  final Color color;
  final String bgPattern;

  // Enhanced properties
  final Color? secondaryColor;
  final List<String>? bulletPoints;
  final String? ctaButtonText;
  final VoidCallback? onCtaPressed;
  final String? imagePath;
  final Duration animationDuration;
  final Curve animationCurve;
  final Map<String, dynamic>? metadata;

  // Animation configurations
  final AnimationConfig animationConfig;

  // Theme configurations
  final ThemeConfig themeConfig;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.illustration,
    required this.color,
    required this.bgPattern,
    this.secondaryColor,
    this.bulletPoints,
    this.ctaButtonText,
    this.onCtaPressed,
    this.imagePath,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.animationCurve = Curves.easeInOutBack,
    this.metadata,
    AnimationConfig? animationConfig,
    ThemeConfig? themeConfig,
  })  : animationConfig = animationConfig ?? const AnimationConfig(),
        themeConfig = themeConfig ?? const ThemeConfig();

  // Copy with method for easy modifications
  OnboardingPage copyWith({
    String? title,
    String? description,
    IconData? illustration,
    Color? color,
    String? bgPattern,
    Color? secondaryColor,
    List<String>? bulletPoints,
    String? ctaButtonText,
    VoidCallback? onCtaPressed,
    String? imagePath,
    Duration? animationDuration,
    Curve? animationCurve,
    Map<String, dynamic>? metadata,
    AnimationConfig? animationConfig,
    ThemeConfig? themeConfig,
  }) {
    return OnboardingPage(
      title: title ?? this.title,
      description: description ?? this.description,
      illustration: illustration ?? this.illustration,
      color: color ?? this.color,
      bgPattern: bgPattern ?? this.bgPattern,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      bulletPoints: bulletPoints ?? this.bulletPoints,
      ctaButtonText: ctaButtonText ?? this.ctaButtonText,
      onCtaPressed: onCtaPressed ?? this.onCtaPressed,
      imagePath: imagePath ?? this.imagePath,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      metadata: metadata ?? this.metadata,
      animationConfig: animationConfig ?? this.animationConfig,
      themeConfig: themeConfig ?? this.themeConfig,
    );
  }
}

// Example usage and helper functions
extension OnboardingPageListExtension on List<OnboardingPage> {
  OnboardingPage? getByTitle(String title) {
    try {
      return firstWhere((page) => page.title == title);
    } catch (e) {
      return null;
    }
  }

  List<OnboardingPage> withAnimation(AnimationConfig config) {
    return map((page) => page.copyWith(animationConfig: config)).toList();
  }

  List<OnboardingPage> withTheme(ThemeConfig theme) {
    return map((page) => page.copyWith(themeConfig: theme)).toList();
  }
}
