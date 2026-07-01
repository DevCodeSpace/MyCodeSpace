import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import '../../core/services/classic_bluetooth_chat_service.dart';
import '../../core/services/storage_service.dart';
import '../../routes/app_routes.dart';
import '../chat/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RemoteProfile {
  final String name;
  final String bio;
  final String? imagePath;

  RemoteProfile({required this.name, required this.bio, this.imagePath});

  Map<String, dynamic> toJson() => {
    'name': name,
    'bio': bio,
    'imagePath': imagePath,
  };

  factory RemoteProfile.fromJson(Map<String, dynamic> json) => RemoteProfile(
    name: json['name'] ?? 'Unknown User',
    bio: json['bio'] ?? '',
    imagePath: json['imagePath'],
  );
}

class ChatSummary {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime time;
  final bool isOnline;
  final String? imagePath;

  ChatSummary({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.isOnline = false,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lastMessage': lastMessage,
    'time': time.toIso8601String(),
    'isOnline': isOnline,
    'imagePath': imagePath,
  };

  factory ChatSummary.fromJson(Map<String, dynamic> json) => ChatSummary(
    id: json['id'],
    name: json['name'],
    lastMessage: json['lastMessage'],
    time: DateTime.parse(json['time']),
    isOnline: json['isOnline'] ?? false,
    imagePath: json['imagePath'],
  );
}

class HomeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final ClassicBluetoothChatService _classicChat =
      Get.find<ClassicBluetoothChatService>();

  final userName = ''.obs;
  final userImagePath = ''.obs;
  final chats = <ChatSummary>[].obs;

  // Selection Mode
  final isSelectionMode = false.obs;
  final selectedChatIds = <String>{}.obs;

  late final StreamSubscription<ClassicIncomingChatMessage>
  _incomingChatSubscription;
  late final StreamSubscription<ClassicConnectionEvent>
  _connectionEventSubscription;
  Timer? _deviceRefreshTimer;
  final Map<String, String> _messageBuffers = {};

  @override
  void onInit() {
    super.onInit();
    refreshProfile();
    loadChatHistory();
    _initializePairedDeviceChat();

    _incomingChatSubscription = _classicChat.incomingMessages.listen(
      _handleIncomingChat,
    );
    _connectionEventSubscription = _classicChat.connectionEvents.listen((event) {
      refreshChats();
      if (event.isConnected && event.deviceAddress != null) {
        _sendMyProfile(event.deviceAddress!);
      }
    });
    _deviceRefreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => refreshChats(),
    );
    refreshChats();
  }

  Future<void> _initializePairedDeviceChat() async {
    final ready = await _classicChat.initializePairedChat();
    if (!ready) {
      Get.snackbar(
        'Bluetooth Required',
        'Turn on Bluetooth and pair the other phone in system settings.',
      );
      return;
    }
    await refreshChats();
  }

  void refreshProfile() {
    userName.value = _storage.getUserName();
    userImagePath.value = _storage.getUserImagePath();
  }

  Future<void> refreshChats() async {
    await _updateChatAvailability();
  }

  void upsertChatSummary(ChatSummary summary) {
    _upsertChat(summary);
  }

  void enterSelectionMode(String chatId) {
    isSelectionMode.value = true;
    selectedChatIds.add(chatId);
  }

  void toggleSelection(String chatId) {
    if (selectedChatIds.contains(chatId)) {
      selectedChatIds.remove(chatId);
      if (selectedChatIds.isEmpty) {
        exitSelectionMode();
      }
    } else {
      selectedChatIds.add(chatId);
    }
  }

  void exitSelectionMode() {
    isSelectionMode.value = false;
    selectedChatIds.clear();
  }

  Future<void> deleteSelectedChats() async {
    if (selectedChatIds.isEmpty) return;

    final idsToDelete = Set<String>.from(selectedChatIds);

    // 1. Remove from local chats list
    chats.removeWhere((chat) => idsToDelete.contains(chat.id));

    // 2. Remove messages from storage
    final Map<String, dynamic> allMessages =
        jsonDecode(_storage.getChatMessages());
    for (final id in idsToDelete) {
      allMessages.remove(id);
    }
    await _storage.setChatMessages(jsonEncode(allMessages));

    // 3. Remove remote profiles from storage
    final Map<String, dynamic> allProfiles =
        jsonDecode(_storage.getRemoteProfiles());
    for (final id in idsToDelete) {
      allProfiles.remove(id);
    }
    await _storage.setRemoteProfiles(jsonEncode(allProfiles));

    // 4. Save updated chat history
    _saveChatHistory();

    // 5. Exit selection mode
    exitSelectionMode();

    Get.snackbar(
      'Success',
      'Selected chats deleted successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _handleIncomingChat(ClassicIncomingChatMessage incoming) async {
    final String address = incoming.deviceAddress;
    final String part = incoming.message;

    _messageBuffers[address] = (_messageBuffers[address] ?? '') + part;
    String buffer = _messageBuffers[address]!;

    while (buffer.isNotEmpty) {
      int startIndex = buffer.indexOf('{');

      if (startIndex == -1) {
        // No JSON object start found. 
        // If the buffer is long or has been sitting for a while, it might be plain text.
        // For now, if it doesn't contain '{', treat the whole thing as plain text.
        await _processSingleIncomingMessage(address, incoming.timestamp, buffer.trim());
        buffer = '';
        break;
      }

      // If there is text before the first '{', handle it as plain text
      if (startIndex > 0) {
        final textPart = buffer.substring(0, startIndex).trim();
        if (textPart.isNotEmpty) {
          await _processSingleIncomingMessage(address, incoming.timestamp, textPart);
        }
        buffer = buffer.substring(startIndex);
        startIndex = 0;
      }

      // Try to find matching '}' for the '{' at startIndex
      int braceCount = 0;
      int endIndex = -1;
      for (int i = startIndex; i < buffer.length; i++) {
        if (buffer[i] == '{') {
          braceCount++;
        } else if (buffer[i] == '}') {
          braceCount--;
        }

        if (braceCount == 0) {
          endIndex = i;
          break;
        }
      }

      if (endIndex != -1) {
        // Found a complete JSON object
        final jsonPart = buffer.substring(startIndex, endIndex + 1);
        await _processSingleIncomingMessage(address, incoming.timestamp, jsonPart);
        buffer = buffer.substring(endIndex + 1);
      } else {
        // Incomplete JSON object, wait for more data
        break;
      }
    }

    _messageBuffers[address] = buffer;
  }

  Future<void> _processSingleIncomingMessage(
    String deviceAddress,
    DateTime timestamp,
    String messagePart,
  ) async {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(messagePart);
    } catch (e) {
      // If it looks like JSON but failed to parse, don't show as text
      if (messagePart.startsWith('{')) return;

      // Fallback for old plain text messages
      data = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'text',
        'content': messagePart,
      };
    }

    final type = data['type'] as String?;
    final id = data['id'] as String?;

    if (type == 'status') {
      _handleStatusUpdate(deviceAddress, id!, data['content']);
      return;
    }

    if (type == 'profile') {
      await _handleRemoteProfile(deviceAddress, data);
      return;
    }

    // Check if the chat is already open for this device
    ChatController? activeChatController;
    if (Get.isRegistered<ChatController>()) {
      final chatController = Get.find<ChatController>();
      if (chatController.chatSummary.id == deviceAddress) {
        activeChatController = chatController;
      }
    }

    String? textContent = type == 'text' ? data['content'] : null;
    String? imagePath;

    if (type == 'image') {
      imagePath = await _saveBase64Image(data['content'], id!);
      textContent = 'Photo';
    }

    if (activeChatController != null) {
      activeChatController.onIncomingMessage(
        Message(
          id: id!,
          text: type == 'text' ? data['content'] : null,
          imagePath: imagePath,
          isMe: false,
          timestamp: timestamp,
          status: 'delivered',
        ),
      );
    } else {
      _saveIncomingMessageToStorage(deviceAddress, {
        'id': id,
        'text': type == 'text' ? data['content'] : null,
        'imagePath': imagePath,
        'isMe': false,
        'timestamp': timestamp.toIso8601String(),
        'status': 'delivered',
      });

      final summary = ChatSummary(
        id: deviceAddress,
        name: _resolveDeviceName(deviceAddress),
        lastMessage: textContent ?? 'Message',
        time: timestamp,
        isOnline: _classicChat.isConnectedTo(deviceAddress),
      );
      _upsertChat(summary);

      Get.snackbar(
        _resolveDeviceName(deviceAddress),
        textContent ?? 'Message',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white.withOpacity(0.9),
        duration: const Duration(seconds: 4),
        onTap: (_) {
          Get.toNamed(
            AppRoutes.CHAT,
            arguments: ChatSessionArgs(summary: summary),
          );
        },
      );
    }

    // Send "delivered" status back
    _sendDeliveryStatus(deviceAddress, id!);
  }

  Future<void> _handleRemoteProfile(String address, Map<String, dynamic> data) async {
    String? localImagePath;
    if (data['image'] != null) {
      localImagePath = await _saveBase64Image(data['image'], 'profile_$address');
    }

    final profile = RemoteProfile(
      name: data['name'] ?? 'Unknown User',
      bio: data['bio'] ?? '',
      imagePath: localImagePath,
    );

    // Save to storage
    final Map<String, dynamic> allProfiles = jsonDecode(_storage.getRemoteProfiles());
    allProfiles[address] = profile.toJson();
    await _storage.setRemoteProfiles(jsonEncode(allProfiles));

    // Update ChatSummary if exists
    final existingIndex = chats.indexWhere((c) => c.id == address);
    if (existingIndex != -1) {
      final old = chats[existingIndex];
      chats[existingIndex] = ChatSummary(
        id: old.id,
        name: profile.name,
        lastMessage: old.lastMessage,
        time: old.time,
        isOnline: old.isOnline,
        imagePath: profile.imagePath,
      );
      chats.refresh();
      _saveChatHistory();
    }

    // Notify ChatController if active
    if (Get.isRegistered<ChatController>()) {
      final chatController = Get.find<ChatController>();
      if (chatController.chatSummary.id == address) {
        chatController.updateRemoteProfile(profile);
      }
    }
  }

  void _sendMyProfile(String address) async {
    try {
      final name = _storage.getUserName();
      final bio = _storage.getUserBio();
      final imagePath = _storage.getUserImagePath();
      String? base64Image;

      if (imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          // Compress or just send as is? User said compress quality ~30
          // For now, let's just send Base64
          base64Image = base64Encode(bytes);
        }
      }

      final payload = jsonEncode({
        'type': 'profile',
        'name': name,
        'bio': bio,
        'image': base64Image,
      });

      await _classicChat.sendMessage(address: address, message: payload);
    } catch (e) {
      debugPrint('Error sending profile: $e');
    }
  }

  Future<String> _saveBase64Image(String base64String, String id) async {
    final bytes = base64Decode(base64String);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/img_$id.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  void _handleStatusUpdate(String deviceAddress, String messageId, String status) {
    // 1. Update Storage
    final Map<String, dynamic> allMessages = Map<String, dynamic>.from(
      jsonDecode(_storage.getChatMessages()),
    );
    final List<dynamic> deviceMessages =
        List<dynamic>.from(allMessages[deviceAddress] ?? []);

    bool updated = false;
    for (var i = 0; i < deviceMessages.length; i++) {
      if (deviceMessages[i]['id'] == messageId) {
        if (status == 'read') {
          deviceMessages[i]['status'] = 'read';
          updated = true;
        } else if (status == 'delivered' &&
            deviceMessages[i]['status'] == 'sent') {
          deviceMessages[i]['status'] = 'delivered';
          updated = true;
        }
      }
    }

    if (updated) {
      allMessages[deviceAddress] = deviceMessages;
      _storage.setChatMessages(jsonEncode(allMessages));

      // 2. Update Active Controller if present
      if (Get.isRegistered<ChatController>()) {
        final chatController = Get.find<ChatController>();
        if (chatController.chatSummary.id == deviceAddress) {
          chatController.updateMessageStatus(messageId, status);
        }
      }
    }
  }

  void _sendDeliveryStatus(String address, String messageId) async {
    final payload = jsonEncode({
      'id': messageId,
      'type': 'status',
      'content': 'delivered',
    });
    await _classicChat.sendMessage(address: address, message: payload);
  }

  void _saveIncomingMessageToStorage(
    String deviceAddress,
    Map<String, dynamic> messageJson,
  ) {
    final Map<String, dynamic> allMessages = Map<String, dynamic>.from(
      jsonDecode(_storage.getChatMessages()),
    );

    final List<dynamic> deviceMessages =
        allMessages[deviceAddress] != null
            ? List<dynamic>.from(allMessages[deviceAddress])
            : [];

    deviceMessages.add(messageJson);
    allMessages[deviceAddress] = deviceMessages;

    _storage.setChatMessages(jsonEncode(allMessages));
  }

  void loadChatHistory() {
    final historyJson = _storage.getChatHistory();
    final decoded = jsonDecode(historyJson) as List<dynamic>;
    chats.value = decoded.map((e) => ChatSummary.fromJson(e)).toList();
  }

  Future<void> _updateChatAvailability() async {
    final pairedDevices = await _classicChat.getPairedDevices();
    final pairedByAddress = <String, ClassicBluetoothDevice>{
      for (final device in pairedDevices) device.address: device,
    };

    final Map<String, dynamic> remoteProfiles = jsonDecode(_storage.getRemoteProfiles());

    final updatedChats = chats.map((chat) {
      final profileJson = remoteProfiles[chat.id];
      final profile = profileJson != null ? RemoteProfile.fromJson(profileJson) : null;
      
      return ChatSummary(
        id: chat.id,
        name: profile?.name ?? pairedByAddress[chat.id]?.name ?? chat.name,
        lastMessage: chat.lastMessage,
        time: chat.time,
        isOnline: _classicChat.isConnectedTo(chat.id),
        imagePath: profile?.imagePath ?? chat.imagePath,
      );
    }).toList();

    for (final device in pairedDevices) {
      if (!updatedChats.any((chat) => chat.id == device.address)) {
        final profileJson = remoteProfiles[device.address];
        final profile = profileJson != null ? RemoteProfile.fromJson(profileJson) : null;

        updatedChats.insert(
          0,
          ChatSummary(
            id: device.address,
            name: profile?.name ?? device.name,
            lastMessage: 'Paired in phone Bluetooth settings',
            time: DateTime.now(),
            isOnline: _classicChat.isConnectedTo(device.address),
            imagePath: profile?.imagePath,
          ),
        );
      }
    }

    chats.value = updatedChats;
    _saveChatHistory();
  }

  String _resolveDeviceName(String address) {
    final existing = chats.firstWhereOrNull((chat) => chat.id == address);
    if (existing != null && existing.name.trim().isNotEmpty) {
      return existing.name;
    }
    return 'Paired Device';
  }

  void _upsertChat(ChatSummary summary) {
    final updatedChats = chats.where((chat) => chat.id != summary.id).toList();
    updatedChats.insert(0, summary);
    chats.value = updatedChats;
    _saveChatHistory();
  }

  void _saveChatHistory() {
    final json = jsonEncode(chats.map((e) => e.toJson()).toList());
    _storage.setChatHistory(json);
  }

  @override
  void onClose() {
    _deviceRefreshTimer?.cancel();
    _incomingChatSubscription.cancel();
    _connectionEventSubscription.cancel();
    super.onClose();
  }
}
