import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import 'chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD),
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
        titleSpacing: 0,
        title: Obx(() {
          final profile = controller.remoteProfile.value;
          final name = profile?.name ?? controller.chatSummary.name;
          final imagePath = profile?.imagePath ?? controller.chatSummary.imagePath;

          return FadeIn(
            child: Row(
              children: [
                Hero(
                  tag: 'chat_avatar_${controller.chatSummary.id}',
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.lightBlue,
                    backgroundImage: imagePath != null ? FileImage(File(imagePath)) : null,
                    child: imagePath == null
                        ? Text(name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      _buildOnlineStatus(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        // actions: [
        //   IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),
          SlideInUp(duration: const Duration(milliseconds: 300), child: _buildInputArea()),
        ],
      ),
    );
  }

  Widget _buildOnlineStatus() {
    return Obx(() {
      final isOnline = controller.isDeviceConnected.value;
      return Row(
        children: [
          if (isOnline)
            Flash(
              infinite: true,
              duration: const Duration(seconds: 3),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              ),
            ),
          if (isOnline) const SizedBox(width: 4),
          Text(isOnline ? 'Online' : 'Offline', style: TextStyle(fontSize: 12, color: isOnline ? Colors.green : Colors.grey)),
        ],
      );
    });
  }

  Widget _buildMessageBubble(Message message) {
    bool isImage = message.imagePath != null;
    bool isVideo = message.videoPath != null;

    return SlideInUp(
      from: 20,
      duration: const Duration(milliseconds: 200),
      child: Align(
        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 4, top: 4),
          padding: (isImage || isVideo) ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          decoration: BoxDecoration(
            color: message.isMe ? const Color(0xFFDCF8C6) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(message.isMe ? 12 : 0),
              bottomRight: Radius.circular(message.isMe ? 0 : 12),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(message.imagePath!), fit: BoxFit.cover, width: Get.width * 0.45, height: 180),
                ),
              if (isVideo) _buildVideoPreview(message),
              if (message.text != null)
                Padding(
                  padding: (isImage || isVideo) ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
                  child: Text(message.text!, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                ),
              Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 4, left: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(DateFormat('hh:mm a').format(message.timestamp), style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    if (message.isMe) ...[const SizedBox(width: 4), Obx(() => _buildStatusIcon(message.status.value))],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'sent':
        return const Icon(Icons.done, size: 14, color: Colors.grey);
      case 'delivered':
        return const Icon(Icons.done_all, size: 14, color: Colors.grey);
      case 'read':
        return const Icon(Icons.done_all, size: 14, color: Colors.blue);
      default:
        return const Icon(Icons.access_time, size: 14, color: Colors.grey);
    }
  }

  Widget _buildVideoPreview(Message message) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
        ),
        Obx(() {
          if (message.isUploading.value) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 8),
                  Text('${(message.progress.value * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Set the color to white explicitly
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.transparent), // Optional: add if needed
                ],
              ),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      onSubmitted: (_) => controller.sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        filled: false,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.grey),
                    onPressed: controller.pickAndSendImage,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ZoomIn(
            child: GestureDetector(
              onTap: controller.sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFF075E54), shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
