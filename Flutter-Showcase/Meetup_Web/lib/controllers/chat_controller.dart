import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/webrtc_service.dart';
import '../models/poll_message.dart';

class ChatItem {
  final dynamic chat;
  final PollMessage? poll;

  ChatItem.chat(this.chat) : poll = null;
  ChatItem.poll(this.poll) : chat = null;

  bool get isPoll => poll != null;

  DateTime get timestamp => isPoll ? poll!.timestamp : chat!.timestamp;
}

class ChatController extends ChangeNotifier {
  late final WebRTCService _service;

  void attach(BuildContext context) {
    _service = Provider.of<WebRTCService>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _service.markChatAsRead();
    });
  }

  void sendChat(String text) {
    final trimmed = text.trim();
    if (trimmed.isNotEmpty) {
      _service.sendMessage(trimmed);
    }
  }

  void sendPoll(String question, List<String> options) {
    _service.sendPoll(question, options);
  }

  void voteOnPoll(String pollId, int optionIndex) {
    _service.voteOnPoll(pollId, optionIndex);
  }

  List<ChatItem> buildTimeline() {
    final items = <ChatItem>[
      for (final m in _service.chatMessages) ChatItem.chat(m),
      for (final p in _service.polls) ChatItem.poll(p)
    ];
    items.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return items;
  }
}
