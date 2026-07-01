import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_rtc/services/auth_service.dart';
import 'package:web_rtc/services/webrtc_service.dart';
import '../utils/meeting_link.dart';

class ActiveEmoji {
  final String id;
  final String emoji;
  final String senderName;

  ActiveEmoji(this.id, this.emoji, this.senderName);
}

class CallController extends ChangeNotifier {
  final String roomId;
  final bool createRoom;

  WebRTCService? webRTCService;
  AuthService? authService;

  bool isLeaving = false;
  bool isEmojiMenuOpen = false;
  bool isParticipantsOpen = false;
  bool isChatOpen = false;
  bool showQrCode = false;

  final List<ActiveEmoji> activeEmojis = [];

  void Function(ChatMessage)? onNewMessageCallback;
  void Function()? onPeerLeftCallback;

  CallController({required this.roomId, required this.createRoom});

  String get meetingLink => buildCallMeetingLink(roomId);

  void attach(BuildContext context) {
    authService = Provider.of<AuthService>(context, listen: false);
    webRTCService = Provider.of<WebRTCService>(context, listen: false);

    webRTCService?.remoteRenderer.addListener(_onRemoteVideoSizeChanged);
    webRTCService?.localRenderer.addListener(_onLocalVideoSizeChanged);

    webRTCService?.onNewMessage = (msg) {
      onNewMessageCallback?.call(msg);
    };

    webRTCService?.onNewReaction = (emoji, senderName) {
      spawnEmoji(emoji, senderName);
    };

    webRTCService?.onPeerLeft = () {
      onPeerLeftCallback?.call();
    };

    final googleName = authService?.user?.displayName ?? 'Anonymous CodeX';
    final userId = authService?.user?.uid ?? authService?.anonymousId ?? 'anonymous_user';
    webRTCService?.setLocalUserIdentity(googleName);

    webRTCService?.initialize(roomId, createRoom: createRoom, userId: userId);
  }

  void spawnEmoji(String emoji, String senderName) {
    final String uniqueId = DateTime.now().microsecondsSinceEpoch.toString();
    activeEmojis.add(ActiveEmoji(uniqueId, emoji, senderName));
    notifyListeners();
  }

  void removeEmoji(String id) {
    activeEmojis.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void sendReaction(String emoji) {
    webRTCService?.sendReaction(emoji);
  }

  void _onRemoteVideoSizeChanged() {
    notifyListeners();
  }

  void _onLocalVideoSizeChanged() {
    notifyListeners();
  }

  Future<void> leaveRoom(BuildContext context) async {
    if (isLeaving) return;
    isLeaving = true;
    notifyListeners();
    ScaffoldMessenger.of(context).clearSnackBars();
    // Fire teardown in the background. The leave signal that notifies the peer
    // is sent inside leaveCall(); we don't need to block the user's exit on the
    // local cleanup + candidate housekeeping, otherwise the leaver sits on a
    // loading state while the other side has already seen "participant left".
    final leaveFuture = webRTCService?.leaveCall();
    if (leaveFuture != null) unawaited(leaveFuture);
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void toggleEmojiMenu() {
    isEmojiMenuOpen = !isEmojiMenuOpen;
    notifyListeners();
  }

  void toggleParticipants() {
    isParticipantsOpen = !isParticipantsOpen;
    if (isParticipantsOpen) {
      isChatOpen = false;
    }
    notifyListeners();
  }

  void toggleChat() {
    webRTCService?.markChatAsRead();
    isChatOpen = !isChatOpen;
    if (isChatOpen) {
      isParticipantsOpen = false;
    }
    notifyListeners();
  }
  
  void closeParticipants() {
    isParticipantsOpen = false;
    notifyListeners();
  }
  
  void closeChat() {
    isChatOpen = false;
    notifyListeners();
  }

  void toggleQrCode() {
    showQrCode = !showQrCode;
    notifyListeners();
  }

  @override
  void dispose() {
    webRTCService?.remoteRenderer.removeListener(_onRemoteVideoSizeChanged);
    webRTCService?.localRenderer.removeListener(_onLocalVideoSizeChanged);
    if (!isLeaving) {
      webRTCService?.leaveCall();
    }
    super.dispose();
  }
}
