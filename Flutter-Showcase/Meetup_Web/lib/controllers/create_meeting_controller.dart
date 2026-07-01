import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../utils/meeting_link.dart';

class CreateMeetingController extends ChangeNotifier {
  late final String roomId;
  late final String meetingLink;

  CreateMeetingController() {
    roomId = const Uuid().v4().split('-').first.toUpperCase();
    meetingLink = buildCreateMeetingLink(roomId);
  }

  Future<void> copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: meetingLink));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meeting URL copied to clipboard')),
    );
  }

  void startCall(BuildContext context) {
    Navigator.of(context).pop(); // Dismiss Dialog
    Navigator.of(context).pushNamed(
      '/call',
      arguments: {'roomId': roomId, 'createRoom': true},
    );
  }
}
