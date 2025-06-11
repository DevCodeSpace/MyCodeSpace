
// Models
import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPageModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class StatsCardModel {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  StatsCardModel({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

