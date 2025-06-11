// Models
import 'package:flutter/material.dart';

/// Model to hold weather-related data.
class WeatherData {
  final String location; // Name of the location
  final String temperature; // Temperature as a string, e.g., "24°C"
  final String condition; // Weather condition, e.g., "Partly Cloudy"
  final IconData icon; // Icon representing the weather

  WeatherData({
    required this.location,
    required this.temperature,
    required this.condition,
    required this.icon,
  });
}

/// Model for displaying a statistic card on the dashboard.
class StatCard {
  final String title; // Title of the stat, e.g., "Revenue"
  final String value; // Value of the stat, e.g., "$12,450"
  final IconData icon; // Icon representing the stat
  final Color color; // Background or accent color
  final String change; // Change value, e.g., "+12%"

  StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.change,
  });
}

/// Model for quick action buttons shown on the dashboard.
class QuickAction {
  final IconData icon; // Icon representing the action
  final String label; // Label text, e.g., "Send"
  final Color color; // Button background color

  QuickAction({required this.icon, required this.label, required this.color});
}

/// Model for listing recent activity on the dashboard.
class ActivityItem {
  final IconData icon; // Icon representing the activity
  final String title; // Title of the activity
  final String subtitle; // Time or extra description, e.g., "2 minutes ago"
  final Color color; // Color theme for the activity

  ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

/// Model holding basic user information for dashboard use.
class UserData {
  final String name; // User's name
  final String greeting; // Dynamic greeting based on time
  final int notificationCount; // Number of notifications
  final String avatarUrl; // (Optional) URL of user's avatar

  UserData({
    required this.name,
    required this.greeting,
    required this.notificationCount,
    this.avatarUrl = '',
  });
}
