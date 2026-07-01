import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [const Color(0xFF10B981).withOpacity(0.05), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                  child: const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 40),
                ),
                const SizedBox(height: 15),
                const Text("Codex User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Text("Security Dashboard", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          _drawerItem(Icons.security_update_good_rounded, "Security Audit"),
          _drawerItem(Icons.cloud_sync_rounded, "Cloud Backup"),
          _drawerItem(Icons.settings_suggest_rounded, "Settings"),
          const Spacer(),
          const Divider(indent: 20, endIndent: 20),
          _drawerItem(Icons.help_outline_rounded, "Support Center"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64748B)),
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500),
      ),
      onTap: () => Get.back(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 30),
    );
  }
}
