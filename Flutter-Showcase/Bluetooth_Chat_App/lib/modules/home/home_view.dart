import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: controller.isSelectionMode.value
            ? AppBar(
                leading: IconButton(icon: const Icon(Icons.close), onPressed: controller.exitSelectionMode),
                title: Text('${controller.selectedChatIds.length} selected'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Delete Chats'),
                          content: const Text('Are you sure you want to delete selected chats? This will clear all message history.'),
                          actions: [
                            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                controller.deleteSelectedChats();
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            : AppBar(
                title: ZoomIn(child: const Text('Messages')),
                elevation: 0.5,
                actions: [_buildProfileButton()],
              ),
        body: Obx(() {
          if (controller.chats.isEmpty) {
            // If we are "loading" or empty, show shimmer for a split second or empty state
            // For now, if truly empty, show empty state.
            // (Usually you'd have a loading state, but here it's reactive)
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: controller.refreshChats,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: controller.chats.length,
              separatorBuilder: (context, index) => const Divider(indent: 80, height: 1),
              itemBuilder: (context, index) {
                final chat = controller.chats[index];
                return _buildChatTile(chat, index);
              },
            ),
          );
        }),
        floatingActionButton: ElasticIn(
          child: FloatingActionButton.extended(
            onPressed: controller.refreshChats,
            backgroundColor: AppTheme.primaryBlue,
            icon: const Icon(Icons.sync, color: Colors.white),
            label: const Text(
              'Refresh',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.SETTINGS)?.then((_) => controller.refreshProfile()),
        child: Obx(
          () => Hero(
            tag: 'profile_avatar',
            child: BounceInDown(
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.lightBlue,
                backgroundImage: controller.userImagePath.value.isNotEmpty ? FileImage(File(controller.userImagePath.value)) : null,
                child: controller.userImagePath.value.isEmpty ? const Icon(Icons.person, color: AppTheme.primaryBlue, size: 20) : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(ChatSummary chat, int index) {
    return Obx(() {
      final isSelected = controller.selectedChatIds.contains(chat.id);
      return FadeInRight(
        delay: Duration(milliseconds: index * 100),
        duration: const Duration(milliseconds: 500),
        child: Container(
          color: isSelected ? AppTheme.lightBlue.withOpacity(0.5) : Colors.transparent,
          child: ListTile(
            onTap: () {
              if (controller.isSelectionMode.value) {
                controller.toggleSelection(chat.id);
              } else {
                Get.toNamed(AppRoutes.CHAT, arguments: chat);
              }
            },
            onLongPress: () {
              if (!controller.isSelectionMode.value) {
                controller.enterSelectionMode(chat.id);
              }
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.lightBlue,
                  backgroundImage: chat.imagePath != null ? FileImage(File(chat.imagePath!)) : null,
                  child: chat.imagePath == null
                      ? Text(
                          chat.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 20),
                        )
                      : null,
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Flash(
                      infinite: true,
                      duration: const Duration(seconds: 3),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
                    ),
                  ),
              ],
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    chat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                Text(DateFormat('hh:mm a').format(chat.time), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            trailing: controller.isSelectionMode.value ? Checkbox(value: isSelected, onChanged: (val) => controller.toggleSelection(chat.id), shape: const CircleBorder()) : null,
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(child: Icon(Icons.chat_bubble_outline_rounded, size: 80, color: Colors.grey[200])),
          const SizedBox(height: 24),
          FadeInUp(
            child: const Text(
              'No conversations yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.darkGrey),
            ),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Text('Pair both phones in Bluetooth, then refresh here.', style: TextStyle(color: Colors.grey[500])),
          ),
          // const SizedBox(height: 32),
          // FadeInUp(
          //   delay: const Duration(milliseconds: 400),
          //   child: ElevatedButton(
          //     onPressed: controller.refreshChats,
          //     child: const Text('Refresh Devices'),
          //   ),
          // ),
          // const SizedBox(height: 12),
          // FadeInUp(
          //   delay: const Duration(milliseconds: 500),
          //   child: Text('The app now uses paired devices from phone Bluetooth settings.', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          // ),
        ],
      ),
    );
  }
}
