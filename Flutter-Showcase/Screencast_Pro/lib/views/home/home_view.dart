import 'package:screencast_pro/app/routes/app_routes.dart';

import '../../controllers/home_controller.dart';
import '../../utils/import_to_export.dart';

/// HomeView is the initial landing screen the user sees when opening the app on Android.
///
/// It provides two main options (operating modes) for the user:
/// 1. Sender Mode ("Cast My Screen"): Navigates to the device discovery screen where the
///    phone searches for available receivers using a UDP broadcast.
/// 2. Receiver Mode ("Receive a Cast"): Navigates directly to the Receiver screen,
///    turning this Android device into a discoverable display for other devices.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('Screen Casting', style: boldPoppins(32, textColor: Colors.white).copyWith(letterSpacing: -0.5)),
              const SizedBox(height: 6),

              Text('Share your screen instantly with TVs, browsers , phones, and computers over Wi-Fi', style: regularPoppins(15, textColor: Colors.white54).copyWith(height: 1.5)),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      _CastCard(
                        icon: Icons.screen_share_rounded,
                        title: 'Cast My Screen',
                        subtitle: 'Share your screen live with nearby devices using the ScreenCast Pro receiver app',
                        gradientColors: const [AppColors.wifiAccent, AppColors.wifiDark],
                        glowColor: AppColors.wifiAccent,
                        onTap: controller.goToWifiDevices,
                      ),

                      const SizedBox(height: 20),

                      _CastCard(
                        icon: Icons.language_rounded,
                        title: 'Cast Without Receiver',
                        subtitle: 'Stream your screen to any browser with a simple link no receiver app required',
                        gradientColors: const [Color(0xFF43A047), Color(0xFF1B5E20)],
                        glowColor: Colors.green,
                        onTap: controller.goToPublicStream,
                      ),

                      const SizedBox(height: 20),

                      _CastCard(
                        icon: Icons.tv_rounded,
                        title: 'Cast to Smart TV',
                        subtitle: 'Discover compatible TVs on your Wi-Fi network and cast instantly',
                        gradientColors: const [Color(0xFF6A1B9A), Color(0xFF311B92)],
                        glowColor: Colors.deepPurple,
                        onTap: controller.goToTvCast,
                      ),

                      const SizedBox(height: 20),

                      _CastCard(
                        icon: Icons.download_rounded,
                        title: 'Receive a Cast',
                        subtitle: 'Turn this device into a receiver and view screens shared by others',
                        gradientColors: const [Colors.teal, Color(0xFF004D40)], // Custom teal gradient
                        glowColor: Colors.teal,
                        onTap: () => Get.toNamed(AppRoutes.receiver),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CastCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback onTap;

  const _CastCard({required this.icon, required this.title, required this.subtitle, required this.gradientColors, required this.glowColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: glowColor.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon in a frosted-glass circle
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: boldPoppins(18, textColor: Colors.white)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: regularPoppins(13, textColor: Colors.white70).copyWith(height: 1.4)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white60, size: 24),
          ],
        ),
      ),
    );
  }
}
