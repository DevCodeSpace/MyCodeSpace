import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import '../../core/services/classic_bluetooth_chat_service.dart';
import '../../core/services/storage_service.dart';
import '../home/home_controller.dart';

class Message {
  final String id;
  final String? text;
  final String? imagePath;
  final String? videoPath;
  final RxDouble progress = 1.0.obs;
  final RxBool isUploading = false.obs;
  final bool isMe;
  final DateTime timestamp;
  final RxString status; // sent, delivered, read

  Message({
    required this.id,
    this.text,
    this.imagePath,
    this.videoPath,
    required this.isMe,
    required this.timestamp,
    String? status,
  }) : status = (status ?? 'sent').obs;

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'imagePath': imagePath,
    'videoPath': videoPath,
    'isMe': isMe,
    'timestamp': timestamp.toIso8601String(),
    'status': status.value,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    text: json['text'],
    imagePath: json['imagePath'],
    videoPath: json['videoPath'],
    isMe: json['isMe'] ?? false,
    timestamp: DateTime.parse(json['timestamp']),
    status: json['status'],
  );
}

class ChatSessionArgs {
  final ChatSummary summary;

  ChatSessionArgs({required this.summary});
}

class ChatController extends GetxController {
  final ClassicBluetoothChatService _classicChat =
      Get.find<ClassicBluetoothChatService>();
  final StorageService _storage = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  late ChatSummary chatSummary;
  final messages = <Message>[].obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  final isDeviceConnected = false.obs;
  final remoteProfile = Rxn<RemoteProfile>();

  StreamSubscription<ClassicIncomingChatMessage>? _incomingMessageSubscription;
  StreamSubscription<ClassicConnectionEvent>? _connectionStateSubscription;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ChatSessionArgs) {
      chatSummary = args.summary;
    } else {
      chatSummary = args as ChatSummary;
    }
    _initializeChat();
    _loadRemoteProfile();
  }

  void _loadRemoteProfile() {
    final Map<String, dynamic> allProfiles = jsonDecode(_storage.getRemoteProfiles());
    if (allProfiles.containsKey(chatSummary.id)) {
      remoteProfile.value = RemoteProfile.fromJson(allProfiles[chatSummary.id]);
    }
  }

  void updateRemoteProfile(RemoteProfile profile) {
    remoteProfile.value = profile;
    // Update chatSummary name for consistency if needed
    chatSummary = ChatSummary(
      id: chatSummary.id,
      name: profile.name,
      lastMessage: chatSummary.lastMessage,
      time: chatSummary.time,
      isOnline: chatSummary.isOnline,
      imagePath: profile.imagePath,
    );
  }

  Future<void> _initializeChat() async {
    _loadStoredMessages();
    sendReadStatus();

    final ready = await _classicChat.initializePairedChat();
    if (!ready) {
      Get.snackbar(
        'Bluetooth Required',
        'Turn on Bluetooth and pair the other phone in system settings.',
      );
      return;
    }

    isDeviceConnected.value = _classicChat.isConnectedTo(chatSummary.id);

    if (!isDeviceConnected.value) {
      isDeviceConnected.value = await _classicChat.connectToDevice(
        chatSummary.id,
      );
    }

    _connectionStateSubscription = _classicChat.connectionEvents.listen((
      event,
    ) {
      if (event.deviceAddress == chatSummary.id) {
        isDeviceConnected.value = event.isConnected;
        if (!event.isConnected) {
          Get.snackbar('Disconnected', 'Connection with the device was lost.');
        }
      }
    });
  }

  void sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    final text = messageController.text.trim();
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      if (!_classicChat.isConnectedTo(chatSummary.id)) {
        isDeviceConnected.value = await _classicChat.connectToDevice(
          chatSummary.id,
        );
      }

      if (!isDeviceConnected.value) {
        Get.snackbar(
          'Not Ready',
          'Open the app on the other phone and keep Bluetooth on, then try again.',
        );
        return;
      }

      final payload = jsonEncode({
        'id': messageId,
        'type': 'text',
        'content': text,
      });

      final sent = await _classicChat.sendMessage(
        address: chatSummary.id,
        message: payload,
      );
      if (!sent) {
        Get.snackbar('Send Error', 'Failed to deliver message.');
        return;
      }

      onIncomingMessage(Message(
        id: messageId,
        text: text,
        isMe: true,
        timestamp: DateTime.now(),
        status: 'sent',
      ));
      messageController.clear();
    } catch (e) {
      Get.snackbar('Send Error', 'Failed to deliver message: $e');
    }
  }

  void sendImage(String path) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final file = File(path);
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final payload = jsonEncode({
      'id': messageId,
      'type': 'image',
      'content': base64Image,
    });

    try {
      final sent = await _classicChat.sendMessage(
        address: chatSummary.id,
        message: payload,
      );

      if (sent) {
        onIncomingMessage(
          Message(
            id: messageId,
            imagePath: path,
            isMe: true,
            timestamp: DateTime.now(),
            status: 'sent',
          ),
        );
      } else {
        Get.snackbar('Error', 'Failed to send image');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send image: $e');
    }
  }

  Future<void> pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) sendImage(image.path);
  }

  Future<void> pickAndSendVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return;

      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        videoPath: video.path,
        isMe: true,
        timestamp: DateTime.now(),
      );
      message.isUploading.value = true;
      message.progress.value = 0.0;
      messages.add(message);
      _scrollToBottom();

      final MediaInfo? info = await VideoCompress.compressVideo(
        video.path,
        quality: VideoQuality.LowQuality,
        deleteOrigin: false,
      );

      if (info == null || info.path == null) return;
      _simulateChunkedSending(message, info.path!);
    } catch (e) {
      Get.snackbar('Video Error', e.toString());
    }
  }

  void _simulateChunkedSending(Message message, String path) async {
    final file = File(path);
    final totalSize = await file.length();
    int sentSize = 0;
    const chunkSize = 1024 * 50;

    while (sentSize < totalSize) {
      await Future.delayed(const Duration(milliseconds: 300));
      sentSize += chunkSize;
      if (sentSize > totalSize) sentSize = totalSize;
      message.progress.value = sentSize / totalSize;
    }
    message.isUploading.value = false;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // When scrolling to bottom (viewing messages), mark all as read
    sendReadStatus();
  }

  void sendReadStatus() async {
    final unreadMessages =
        messages.where((m) => !m.isMe && m.status.value != 'read').toList();
    if (unreadMessages.isEmpty) return;

    for (var msg in unreadMessages) {
      msg.status.value = 'read';
    }
    _persistMessages();

    // Notify peer about the last read message or all
    final lastMsgId = unreadMessages.last.id;
    final payload = jsonEncode({
      'id': lastMsgId,
      'type': 'status',
      'content': 'read',
    });

    await _classicChat.sendMessage(address: chatSummary.id, message: payload);
  }

  void updateMessageStatus(String messageId, String status) {
    final message = messages.firstWhereOrNull((m) => m.id == messageId);
    if (message != null) {
      // If setting to read, or delivered
      if (status == 'read') {
        message.status.value = 'read';
      } else if (status == 'delivered' && message.status.value == 'sent') {
        message.status.value = 'delivered';
      }
      _persistMessages();
    }
  }

  void onIncomingMessage(Message message) {
    final duplicate =
        message.text != null &&
        messages.isNotEmpty &&
        messages.last.text == message.text &&
        messages.last.isMe == message.isMe &&
        message.timestamp.difference(messages.last.timestamp).inSeconds.abs() <
            2;

    if (duplicate) {
      return;
    }

    messages.add(message);
    _persistMessages();
    _updateChatSummary(message);
    _scrollToBottom();
  }

  void _loadStoredMessages() {
    final Map<String, dynamic> raw = jsonDecode(_storage.getChatMessages());
    final dynamic saved = raw[chatSummary.id];
    if (saved is List) {
      messages.assignAll(
        saved.whereType<Map>().map(
          (entry) => Message.fromJson(Map<String, dynamic>.from(entry)),
        ),
      );
    }
  }

  void _persistMessages() {
    final Map<String, dynamic> allMessages = Map<String, dynamic>.from(
      jsonDecode(_storage.getChatMessages()),
    );
    allMessages[chatSummary.id] = messages
        .map((message) => message.toJson())
        .toList();
    _storage.setChatMessages(jsonEncode(allMessages));
  }

  void _updateChatSummary(Message message) {
    final preview = message.text?.trim().isNotEmpty == true
        ? message.text!
        : message.imagePath != null
        ? 'Photo'
        : message.videoPath != null
        ? 'Video'
        : 'Message';

    final updatedSummary = ChatSummary(
      id: chatSummary.id,
      name: chatSummary.name,
      lastMessage: preview,
      time: message.timestamp,
      isOnline: isDeviceConnected.value,
      imagePath: chatSummary.imagePath,
    );

    chatSummary = updatedSummary;
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().upsertChatSummary(updatedSummary);
    }
  }

  @override
  void onClose() {
    _incomingMessageSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    VideoCompress.cancelCompression();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
