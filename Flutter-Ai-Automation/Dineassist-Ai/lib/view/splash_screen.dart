import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant_order/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Move to the ordering route after splash.
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (GetPlatform.isWeb) {
        // On web, table ID should be in the URL query parameters
        Get.offNamed(AppRoutes.order, parameters: Get.parameters.map((key, value) => MapEntry(key, value ?? '')));
      } else {
        // On mobile app, allow choosing table
        Get.offNamed(AppRoutes.tableSelection);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: const Color(0xFFFFB800).withOpacity(0.2), blurRadius: 30, spreadRadius: 10)],
                      ),
                      child: Image.asset('assets/images/logo.png'),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'DineAssist AI'.toUpperCase(),
                      style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The Future of Dining',
                      style: GoogleFonts.poppins(color: const Color(0xFFFFB800), fontSize: 14, fontWeight: FontWeight.w300, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
