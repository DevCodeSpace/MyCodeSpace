// ignore_for_file: deprecated_member_use, unused_field, prefer_typing_uninitialized_variables

import 'dart:math' as math;

import 'package:animations_app/Configuration/app_configuration.dart';
import 'package:animations_app/Helper/common_widgets.dart';
import 'package:animations_app/View/CustomPainter/enhanced_background_painter.dart';
import 'package:animations_app/Helper/routes.dart';
import 'package:animations_app/Helper/transfer_option.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransferMethodSelector extends StatefulWidget {
  const TransferMethodSelector({super.key});

  @override
  State<TransferMethodSelector> createState() => _TransferMethodSelectorState();
}

class _TransferMethodSelectorState extends State<TransferMethodSelector>
    with TickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _backgroundAnimation;
  late List<Animation<double>> _cardAnimations;

  int? _hoveredIndex; // Variable to track the hovered card index

  var _bannerAd; // Variable to store the banner ad instance
  final bool _isBannerAdReady = false; // Flag to check if the ad is ready

  @override
  void initState() {
    super.initState();
    _loadBannerAd(); // Load the banner ad when the widget initializes

    // Initialize the background animation controller
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 15), // Set duration for animation
      vsync: this,
    )..repeat(); // Repeat the animation indefinitely

    // Initialize the card animation controller
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800), // Set duration for animation
      vsync: this,
    );

    // Define background animation for rotating effect
    _backgroundAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi, // Rotate full circle
    ).animate(_backgroundAnimationController);

    // Create staggered animations for cards
    _cardAnimations = List.generate(
      2, // Number of cards to animate
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            index * 0.2, // Start animation at different intervals
            0.6 + index * 0.2, // End animation at different intervals
            curve: Curves.easeOut, // Use ease-out effect for smooth animation
          ),
        ),
      ),
    );

    // Start the card animations when the widget initializes
    _cardAnimationController.forward();
  }

  void _loadBannerAd() {
    // _bannerAd = AdsHelper.createBannerAd()
    //   ..load().then((_) {
    //     if (mounted) {
    //       setState(() {
    //         _isBannerAdReady = true;
    //       });
    //     }
    //   });
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // Dispose of the banner ad instance
    _backgroundAnimationController
        .dispose(); // Dispose of the background animation controller
    _cardAnimationController
        .dispose(); // Dispose of the card animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        shadowColor: Colors.blue.withOpacity(0.15), // Set shadow color
        cardTheme: CardTheme(
          elevation: 8, // Set card elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Set rounded border
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Set scaffold background color
        appBar: _buildAnimatedAppBar(), // Build the animated app bar
        body: _buildBody(), // Build the main body content
      ),
    );
  }

  // Function to build an animated app bar
  PreferredSizeWidget _buildAnimatedAppBar() {
    return PreferredSize(
      preferredSize:
          const Size.fromHeight(kToolbarHeight), // Set app bar height
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 800), // Set animation duration
        tween: Tween<double>(begin: 0, end: 1), // Define animation range
        builder: (context, double value, child) {
          return AppBar(
            elevation: 0, // Remove app bar shadow
            backgroundColor: Colors.transparent, // Make background transparent
            title: Opacity(
              opacity: value, // Apply animation opacity to title
              child: const Text(
                'Transfer Methods',
                style: TextStyle(
                  color: Colors.black87, // Set title text color
                  fontWeight: FontWeight.bold, // Set title font weight
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to build the main body content
  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Custom background with animated painter
            CustomPaint(
              painter: EnhancedBackgroundPainter(
                animation: _backgroundAnimation.value,
                primaryColor: Colors.blue.withOpacity(0.05),
                secondaryColor: Colors.purple.withOpacity(0.03),
              ),
              size: Size.infinite,
            ),
            _buildContent(), // Build the main content
          ],
        );
      },
    );
  }

  // Function to build the content inside the body
  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Enable smooth scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildAnimatedHeader(), // Build the animated header section
              const SizedBox(height: 12),
              _buildTransferOptions(), // Build the transfer options section
              const SizedBox(height: 24),
              // _buildQuickActionsSection() // Uncomment if quick actions are needed
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build the transfer options list
  Widget _buildTransferOptions() {
    // Define constant for spacing between options
    const double kSpacing = 12.0;

    // List of transfer options
    final options = [
      TransferOption(
        title: 'WiFi Transfer',
        description: 'Quick local transfer',
        icon: Icons.wifi_rounded,
        color: Colors.blue,
        features: const ['Ultra-fast', 'No internet', 'Same network'],
        details: const [
          'Transfer speed up to 50MB/s',
          'Works within 30m range',
          'Secure local encryption'
        ],
        onTap: () => _navigateToFTPScreen(), // Navigation action on tap
      ),
      TransferOption(
        title: 'Cloud Transfer',
        description: 'Share anywhere',
        icon: Icons.cloud_upload_rounded,
        color: Colors.green,
        features: const ['Remote access', 'Link sharing', 'Secure'],
        details: const [
          'End-to-end encryption',
          'Available worldwide',
          'Auto-sync enabled'
        ],
        onTap: () => showComingSoonDialog(), // Dialog action on tap
      ),
    ];

    // Returning a ListView to display transfer options with separators
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: kSpacing), // Spacing between items
      itemBuilder: (context, index) => _buildAnimatedCard(
          options[index], index), // Building animated card for each option
    );
  }

// Widget to build each transfer option card with animation
  Widget _buildAnimatedCard(TransferOption option, int index) {
    return AnimatedBuilder(
      // Using the animation object for the card
      animation: _cardAnimations[index],
      builder: (context, child) {
        return Transform.translate(
          // Moving the card horizontally based on the animation value
          offset: Offset(100 * (1 - _cardAnimations[index].value), 0),
          child: Opacity(
            // Adjusting opacity based on the animation value
            opacity: _cardAnimations[index].value,
            child: _buildOptionCard(option, index), // Card content builder
          ),
        );
      },
    );
  }

// Widget to build the transfer option card with animation and hover effect
  Widget _buildOptionCard(TransferOption option, int index) {
    // Constant for border radius of the card
    const double kBorderRadius = 16.0;

    return MouseRegion(
      // Detect hover and update the hovered index state
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: AnimatedContainer(
        // Smooth animation duration for scaling effect on hover
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          // Apply scale transformation when the card is hovered
          ..scale(_hoveredIndex == index ? 1.02 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              // Gradient colors for the card background
              colors: [
                option.color.withOpacity(0.8),
                option.color,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.circular(kBorderRadius), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: option.color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4), // Shadow for depth effect
              ),
            ],
          ),
          child: Material(
            color:
                Colors.transparent, // Transparent material for InkWell effect
            child: InkWell(
              onTap: option.onTap, // Action when the card is tapped
              borderRadius: BorderRadius.circular(
                  kBorderRadius), // Rounded InkWell border
              child: Padding(
                padding: const EdgeInsets.all(16), // Padding around the content
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildOptionHeader(option), // Header of the option card
                    const SizedBox(height: 12),
                    buildFeaturesList(
                        option.features), // Features list in the card
                    const SizedBox(height: 12),
                    buildDetailsList(
                        option.details), // Details list in the card
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

// Navigate to FTP screen
  void _navigateToFTPScreen() {
    Get.toNamed(Routes.ftpPage); // Navigates to the FTP page using GetX
  }
}
