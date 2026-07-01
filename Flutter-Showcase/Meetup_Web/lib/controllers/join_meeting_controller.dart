import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/firebase_signaling_service.dart';

class JoinMeetingController extends ChangeNotifier {
  static const int roomIdLength = 8;
  
  String? validationMessage;
  bool isCheckingRoom = false;

  void clearValidation() {
    if (validationMessage != null) {
      validationMessage = null;
      notifyListeners();
    }
  }

  String sanitize(String value) {
    String parsed = _extractRoomId(value);
    parsed = parsed.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (parsed.length > roomIdLength) {
      parsed = parsed.substring(0, roomIdLength);
    }
    return parsed;
  }

  String _extractRoomId(String input) {
    input = input.trim();
    // Parse path URLs like https://meet.example.com/join/AB12CD34
    if (input.contains('/join/')) {
      final parts = input.split('/join/');
      if (parts.length > 1) {
        final candidate = parts[1].split('?').first.split('#').first.trim();
        if (candidate.length >= 8) {
          return candidate.substring(0, 8);
        }
      }
    }
    // Parse hash fragment URLs like https://meet.example.com/#/join/AB12CD34
    if (input.contains('#/join/')) {
      final parts = input.split('#/join/');
      if (parts.length > 1) {
        final candidate = parts[1].split('?').first.trim();
        if (candidate.length >= 8) {
          return candidate.substring(0, 8);
        }
      }
    }
    return input;
  }

  String? _validateRoomId(String roomId) {
    if (roomId.isEmpty) {
      return 'Enter a room ID.';
    }
    if (roomId.length < roomIdLength) {
      return 'Room ID must be at least $roomIdLength characters.';
    }
    return null;
  }

  Future<void> join(BuildContext context, String rawRoomId) async {
    final roomId = rawRoomId.trim().toUpperCase();
    final validation = _validateRoomId(roomId);

    if (validation != null) {
      validationMessage = validation;
      notifyListeners();
      return;
    }

    isCheckingRoom = true;
    validationMessage = null;
    notifyListeners();

    final authService = context.read<AuthService>();
    final userId = authService.user?.uid ?? authService.anonymousId;
    final signalingService = context.read<FirebaseSignalingService>();
    String? joinError;
    try {
      joinError = await signalingService.getJoinableRoomError(roomId, userId);
    } catch (_) {
      joinError = 'Could not verify the room right now. Please try again.';
    }

    isCheckingRoom = false;
    validationMessage = joinError;
    notifyListeners();

    if (joinError != null) {
      return;
    }

    if (context.mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/call', arguments: {'roomId': roomId, 'createRoom': false});
    }
  }
}
