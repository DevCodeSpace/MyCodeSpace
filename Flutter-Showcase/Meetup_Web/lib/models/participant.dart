import 'package:flutter/material.dart';

/// Model representing a meeting participant (local or remote).
class Participant {
  final String name;
  final bool isMuted;
  final bool isCameraOff;
  final Color bgColor;
  final bool isRemote;

  const Participant({required this.name, required this.isMuted, required this.isCameraOff, required this.bgColor, required this.isRemote});

  String get initial {
    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return 'U';
  }
}
