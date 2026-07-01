import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:web_rtc/screens/create_meeting_screen.dart';
import 'package:web_rtc/screens/join_meeting_screen.dart';
import 'package:web_rtc/services/auth_service.dart';
import 'package:web_rtc/utils/user_format.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final features = [
    _FeatureData(icon: Icons.lock, title: 'Secure connection', subtitle: 'Direct peer-to-peer video with WebRTC encryption.'),
    _FeatureData(icon: Icons.swap_horiz, title: 'Fast signaling', subtitle: 'Exchange SDP and ICE candidates with Socket.IO.'),
    _FeatureData(icon: Icons.devices, title: 'Cross-platform', subtitle: 'Designed flawlessly for Android, iOS, and Web.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final authProvider = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 8,
          children: [
            Image.asset('assets/image/logo.png', width: 40),
            Text('CodeX Meet', style: textTheme.headlineSmall),
          ],
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        actions: [
          if (authProvider.user != null)
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/profile'),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ClipOval(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: (authProvider.user?.photoURL != null && authProvider.user!.photoURL!.isNotEmpty)
                        ? Image.network(
                            authProvider.user!.photoURL!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(context).colorScheme.primary,
                                alignment: Alignment.center,
                                child: Text(
                                  getInitials(authProvider.user?.displayName ?? ''),
                                  style: GoogleFonts.googleSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Theme.of(context).colorScheme.primary,
                            alignment: Alignment.center,
                            child: Text(
                              getInitials(authProvider.user?.displayName ?? ''),
                              style: GoogleFonts.googleSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: constraints.maxWidth > 720
                    ? KeyedSubtree(key: const ValueKey('desktop'), child: buildDesktopView(context))
                    : KeyedSubtree(key: const ValueKey('mobile'), child: buildMobileView(context)),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildDesktopView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Container
          Container(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(40)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Secure video calling for teams and friends.', style: textTheme.headlineMedium),
                const SizedBox(height: 16),
                Text(
                  'Create a meeting room, share a link, and enjoy a direct peer-to-peer call.\nNo third-party video SDKs; just Pure WebRTC and Socket.IO signaling.',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.video_call, size: 22),
                        label: const Text('Create Meeting', style: TextStyle(fontSize: 16)),
                        // onPressed: () => Navigator.of(context).pushNamed('/create'),
                        onPressed: () {
                          showDialog(context: context, builder: (_) => CreateMeetingDialog());
                        },
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        icon: const Icon(Icons.login),
                        label: const Text('Join Meeting', style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          showDialog(context: context, builder: (_) => JoinMeetingDialog());
                        },
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 20)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('What you can do', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),

          // Vertical Cards in a Horizontal Row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: features.map((data) {
                return Expanded(child: _FeatureCard(data: data, isWeb: true));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMobileView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Secure video calling for teams and friends.', style: textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  'Create a meeting room, share a link, and enjoy a direct peer-to-peer call.\nNo third-party video SDKs; just Pure WebRTC and Socket.IO signaling.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.video_call, size: 22),
                      label: const Text('Create Meeting'),
                      onPressed: () {
                        showDialog(context: context, builder: (_) => CreateMeetingDialog());
                      },
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      icon: const Icon(Icons.login),
                      label: const Text('Join Meeting'),
                      onPressed: () {
                        showDialog(context: context, builder: (_) => JoinMeetingDialog());
                      },
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('What you can do', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),

          Column(
            spacing: 16,
            children: features.map((data) {
              return _FeatureCard(data: data, isWeb: false);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Simple data model holding the properties
class _FeatureData {
  final IconData icon;
  final String title;
  final String subtitle;

  _FeatureData({required this.icon, required this.title, required this.subtitle});
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  final bool isWeb;

  const _FeatureCard({required this.data, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final iconWidget = Container(
      padding: EdgeInsets.all(isWeb ? 16 : 12),
      decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
      child: Icon(data.icon, color: colorScheme.primary, size: isWeb ? 28 : 20),
    );

    final textContent = [
      Text(
        data.title,
        textAlign: isWeb ? TextAlign.center : TextAlign.start,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
      ),
      // const SizedBox(height: 4),
      Text(
        data.subtitle,
        textAlign: isWeb ? TextAlign.center : TextAlign.start,
        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.4),
      ),
    ];

    return Container(
      padding: EdgeInsets.all(isWeb ? 24 : 16),
      decoration: BoxDecoration(color: colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(isWeb ? 32 : 20)),
      child: isWeb
          ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [iconWidget, const SizedBox(height: 20), ...textContent])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconWidget,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: textContent),
                ),
              ],
            ),
    );
  }
}
