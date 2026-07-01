import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'settings_controller.dart';
import '../../core/theme/app_theme.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  // Defining the specific background color from the image
  static const Color scaffoldBg = Color(0xFFEDF6FE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: scaffoldBg, // Matches the image's background tint
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
        surfaceTintColor: Colors.transparent,
        // backgroundColor: Colors.transparent, // Keeps AppBar transparent
        elevation: 0,

        title: Text(
          'Settings',
          style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   Icon(Icons.more_vert, color: AppTheme.primaryBlue),
        //   const SizedBox(width: 16),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _buildAvatarCard(context),
            const SizedBox(height: 24),
            _buildSettingsSection(
              context,
              title: 'ACCOUNT SETTINGS',
              tiles: [
                Obx(
                  () => _buildClickableTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Edit Name',
                    subtitle: controller.name.value,
                    onTap: () => _showEditDialog(context, 'Name', controller.name.value, controller.updateName),
                  ),
                ),
                Divider(indent: 72, height: 1, color: Colors.grey[200]),
                Obx(
                  () => _buildClickableTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'Edit Bio',
                    subtitle: controller.bio.value,
                    onTap: () => _showEditDialog(context, 'Bio', controller.bio.value, controller.updateBio),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 16),
            // _buildSettingsSection(
            //   context,
            //   title: 'APP SETTINGS',
            //   tiles: [
            //     // PLACEHOLDER for logic not present in original code
            //     _buildSwitchTile(
            //       context,
            //       icon: Icons.chat_bubble_outline_rounded,
            //       title: 'Read Receipts',
            //       subtitle: 'Show when you’ve seen messages',
            //       value: controller.readReceiptsEnabled,
            //       onChanged: (val) =>
            //           controller.readReceiptsEnabled.value = val,
            //     ),
            //     Divider(indent: 72, height: 1, color: Colors.grey[200]),
            //     _buildClickableTile(
            //       context,
            //       icon: Icons.color_lens_outlined,
            //       title: 'Themes',
            //       subtitle: 'Light Mode',
            //       onTap: () => Get.snackbar('TODO', 'Implement Theme Picker'),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 16),
            _buildSettingsSection(
              context,
              title: 'SECURITY & PRIVACY',
              tiles: [
                _buildClickableTile(context, icon: Icons.lock_outline_rounded, title: 'Privacy Policy', onTap: () {}),
                Divider(indent: 72, height: 1, color: Colors.grey[200]),
                _buildClickableTile(context, icon: Icons.assignment_outlined, title: 'Terms & Conditions', onTap: () {}),
                Divider(indent: 72, height: 1, color: Colors.grey[200]),
                _buildClickableTile(context, icon: Icons.security_outlined, title: 'Privacy Settings', onTap: () {}),
              ],
            ),
            // const SizedBox(height: 24),
            // _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- Profile/Avatar Section ---
  Widget _buildAvatarCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _buildAvatar(context),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Text(
                    controller.name.value.isEmpty ? 'Enter Name' : controller.name.value,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.bio.value.isEmpty ? 'Set Bio' : controller.bio.value,
                          style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 120,
      child: Stack(
        children: [
          Obx(
            () => Container(
              height: 120,
              width: 120,
              padding: const EdgeInsets.all(4), // White border effect
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: controller.imagePath.value.isNotEmpty ? DecorationImage(image: FileImage(File(controller.imagePath.value)), fit: BoxFit.cover) : null,
                ),
                child: controller.imagePath.value.isEmpty ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))],
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Reusable Settings Section Container ---
  Widget _buildSettingsSection(BuildContext context, {required String title, required List<Widget> tiles}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryBlue.withOpacity(0.8), letterSpacing: 1.0),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  // --- Custom Tile Building ---

  // For Navigable Items (Edit Name, Privacy Policy)
  Widget _buildClickableTile(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: _buildIconCircle(icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])) : null,
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]?.withOpacity(0.7)),
      onTap: onTap,
    );
  }

  // For Switch items (Read Receipts)
  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(
      () => SwitchListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
        secondary: _buildIconCircle(icon),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        value: value.value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryBlue,
      ),
    );
  }

  // Creates the stylized background circular for the icon
  Widget _buildIconCircle(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.08), shape: BoxShape.circle),
      child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
    );
  }

  // --- Logout Button ---
  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextButton.icon(
        onPressed: () {}, // Handle Logout logic
        icon: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
        label: const Text(
          'Logout',
          style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: TextButton.styleFrom(padding: const EdgeInsets.all(18)),
      ),
    );
  }

  // --- Dialogs (Slightly improved styling) ---
  void _showEditDialog(BuildContext context, String title, String initialValue, Function(String) onSave) {
    final textController = TextEditingController(text: initialValue);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $title', style: const TextStyle(color: AppTheme.primaryBlue)),
        content: TextField(
          controller: textController,
          autofocus: true,
          cursorColor: AppTheme.primaryBlue,
          decoration: InputDecoration(
            hintText: 'Enter your $title',
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(textController.text);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
