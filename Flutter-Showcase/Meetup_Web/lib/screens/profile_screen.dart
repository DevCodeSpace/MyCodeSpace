import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/profile_controller.dart';
import '../services/auth_service.dart';
import '../utils/user_format.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController controller;

  @override
  void initState() {
    super.initState();
    controller = ProfileController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.attach(context);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final displayName = user.displayName ?? 'CodeX Guest';
    final email = user.email ?? 'No Email (Anonymous Login)';
    final photoUrl = user.photoURL;
    final providerId = user.providerData.isNotEmpty ? user.providerData.first.providerId : 'anonymous';

    String accountType = 'Anonymous';
    IconData providerIcon = Icons.account_circle;
    if (providerId == 'google.com') {
      accountType = 'Google Account';
      providerIcon = Icons.g_mobiledata;
    } else if (providerId == 'password') {
      accountType = 'Email Account';
      providerIcon = Icons.email_outlined;
    }

    final initials = getInitials(displayName, fallback: 'U');

    // Widget avatarWidget =

    final isWeb = MediaQuery.of(context).size.width > 720;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isWeb ? 24.0 : 16.0, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16)],
                  ),
                  child: ClipOval(
                    child: (photoUrl != null && photoUrl.isNotEmpty)
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: colorScheme.primaryContainer,
                              child: Center(
                                child: Text(
                                  initials,
                                  style: GoogleFonts.googleSans(fontSize: 36, fontWeight: FontWeight.bold, color: colorScheme.primary),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: colorScheme.primaryContainer,
                            child: Center(
                              child: Text(
                                initials,
                                style: GoogleFonts.googleSans(fontSize: 36, fontWeight: FontWeight.bold, color: colorScheme.primary),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(displayName, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text(email, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                _buildInfoCard(
                  context: context,
                  user: user,
                  displayName: displayName,
                  email: email,
                  providerIcon: providerIcon,
                  accountType: accountType,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [colorScheme.error, colorScheme.error.withValues(alpha: 0.8)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Log Out'),
                          titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          content: const Text('Are you sure you want to log out from CodeX Meet?', style: TextStyle(fontSize: 16)),
                          contentPadding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Yes', style: TextStyle(color: colorScheme.error)),
                            ),
                          ],
                          actionsPadding: const EdgeInsets.all(12),
                        ),
                      );

                      if (confirm == true) {
                        await controller.signOut();
                        if (mounted && Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required User user,
    required String displayName,
    required String email,
    required IconData providerIcon,
    required String accountType,
    required ColorScheme colorScheme,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(context, icon: Icons.badge_outlined, label: 'Display Name', value: displayName),
            const Divider(height: 32),
            _buildInfoRow(context, icon: Icons.mail_outline, label: 'Email Address', value: email),
            // const Divider(height: 32),
            // _buildInfoRow(
            //   context,
            //   icon: Icons.vpn_key_outlined,
            //   label: 'User ID',
            //   value: user.uid,
            //   trailing: IconButton(
            //     icon: Icon(_copied ? Icons.check : Icons.copy, size: 18, color: _copied ? Colors.green : colorScheme.onSurfaceVariant),
            //     onPressed: () => _copyToClipboard(user.uid),
            //     tooltip: 'Copy User ID',
            //   ),
            // ),
            const Divider(height: 32),
            _buildInfoRow(context, icon: providerIcon, label: 'Account Provider', value: accountType),
            const Divider(height: 32),
            _buildInfoRow(context, icon: Icons.calendar_today_outlined, label: 'Joined On', value: formatDate(user.metadata.creationTime)),
            const Divider(height: 32),
            _buildInfoRow(context, icon: Icons.access_time, label: 'Last Sign In', value: formatDate(user.metadata.lastSignInTime)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value, Widget? trailing}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: colorScheme.primaryContainer.withValues(alpha: 0.4), shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
              ),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
