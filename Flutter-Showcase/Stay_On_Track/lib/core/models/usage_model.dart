import 'dart:typed_data';
import 'package:flutter/material.dart';

class DailyUsagePoint {
  final DateTime date;
  final double totalMinutes;

  const DailyUsagePoint({
    required this.date,
    required this.totalMinutes,
  });

  String get shortDayLabel {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[date.weekday - 1];
  }

  String get compactValueLabel {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes.round() % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class AppUsageInfo {
  final String id;
  final String name;
  final String category;
  final IconData? icon;
  final Uint8List? appIconBytes;
  final Color themeColor;
  double elapsedMinutes; // live accumulative screen time
  UsageLimit? limit;

  AppUsageInfo({
    required this.id,
    required this.name,
    required this.category,
    this.icon,
    this.appIconBytes,
    required this.themeColor,
    this.elapsedMinutes = 0,
    this.limit,
  });

  double get percentUsed {
    if (limit == null || limit!.limitMinutes == 0) return 0.0;
    return (elapsedMinutes / limit!.limitMinutes).clamp(0.0, 1.0);
  }

  bool get isLimitExceeded {
    if (limit == null || !limit!.isActive) return false;
    return elapsedMinutes >= limit!.limitMinutes;
  }
}

class UsageLimit {
  bool isActive;
  double limitMinutes;
  bool repeatDaily;
  bool notifyAt80;

  UsageLimit({
    this.isActive = true,
    required this.limitMinutes,
    this.repeatDaily = true,
    this.notifyAt80 = true,
  });
}

class DeviceUsageStats {
  double totalGoalMinutes;
  int pickups;
  int notifications;
  bool isFocusModeOn;

  DeviceUsageStats({
    this.totalGoalMinutes = 300, // 5 hours default
    this.pickups = 42,
    this.notifications = 184,
    this.isFocusModeOn = true,
  });
}
