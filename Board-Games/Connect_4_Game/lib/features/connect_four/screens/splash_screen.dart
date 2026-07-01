import 'dart:async';
import 'package:clasic_game/core/theme/app_colors.dart';
import 'package:clasic_game/features/connect_four/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToHome();
  }

  void navigateToHome() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.homeBgTop, AppColors.homeBgBottom], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo.png', width: MediaQuery.of(context).size.width * 0.8),
              Text(
                "Connect 4",
                style: GoogleFonts.silkscreen(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.darkText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
