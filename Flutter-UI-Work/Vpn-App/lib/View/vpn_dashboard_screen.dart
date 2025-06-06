import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_med/Controller/vpn_controller.dart';

/// Main home screen displaying VPN connection status and controls
/// Features modern glassmorphism UI with gradient backgrounds
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the VPN controller instance for state management
    final VpnController controller = Get.find();

    return Scaffold(
      body: Container(
        // Gradient background for modern glass effect
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0B), // Dark top
              Color(0xFF1A1A1D), // Lighter middle
              Color(0xFF0A0A0B), // Dark bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ==================== HEADER SECTION ====================
              // App branding with shield icon and title
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    // Shield icon container with glassmorphism effect
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.05,
                        ), // Semi-transparent white
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.1,
                          ), // Subtle border
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // App title with custom typography
                    const Text(
                      'SecureVPN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing:
                            -0.5, // Tight letter spacing for modern look
                      ),
                    ),

                    // Premium badge (commented out for cleaner look)
                    // const Spacer(),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 12,
                    //     vertical: 6,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFF00D4AA).withValues(alpha: 0.2),
                    //     borderRadius: BorderRadius.circular(20),
                    //     border: Border.all(
                    //       color: const Color(0xFF00D4AA).withValues(alpha: 0.3),
                    //     ),
                    //   ),
                    //   child: const Text(
                    //     'Premium',
                    //     style: TextStyle(
                    //       color: Color(0xFF00D4AA),
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),

              // ==================== MAIN CONTENT AREA ====================
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ==================== CONNECTION STATUS CIRCLE ====================
                      // Large animated circle showing connection status with glow effect
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring - appears when connected
                            Obx(
                              () => AnimatedContainer(
                                duration: const Duration(milliseconds: 800),
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      // Glow effect only when connected
                                      color:
                                          controller.stage.value == 'connected'
                                              ? const Color(
                                                0xFF00D4AA,
                                              ).withValues(alpha: 0.3)
                                              : Colors.transparent,
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Main connection circle with gradient
                            Obx(
                              () => AnimatedContainer(
                                duration: const Duration(milliseconds: 800),
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // Dynamic gradient based on connection status
                                  gradient: RadialGradient(
                                    colors: [
                                      // Connected: Green gradient / Disconnected: Gray gradient
                                      controller.stage.value == 'connected'
                                          ? const Color(
                                            0xFF00D4AA,
                                          ) // Bright green
                                          : const Color(
                                            0xFF404040,
                                          ), // Dark gray
                                      controller.stage.value == 'connected'
                                          ? const Color(
                                            0xFF00A085,
                                          ) // Darker green
                                          : const Color(
                                            0xFF2A2A2A,
                                          ), // Darker gray
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(
                                        0,
                                        10,
                                      ), // Drop shadow
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(
                                      alpha: 0.1,
                                    ), // Inner glass effect
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Connection status icon (shield or loading spinner)
                                        Obx(() {
                                          if (controller.isConnecting.value) {
                                            // Show loading spinner when connecting
                                            return const SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                            );
                                          }
                                          // Show shield icon based on connection status
                                          return Icon(
                                            controller.stage.value ==
                                                    'connected'
                                                ? Icons
                                                    .shield_rounded // Filled shield when connected
                                                : Icons
                                                    .shield_outlined, // Outlined shield when disconnected
                                            color: Colors.white,
                                            size: 48,
                                          );
                                        }),
                                        const SizedBox(height: 12),

                                        // Status text below icon
                                        Obx(
                                          () => Text(
                                            controller.isConnecting.value
                                                ? 'Connecting...'
                                                : controller.stage.value ==
                                                    'connected'
                                                ? 'Protected'
                                                : 'Not Protected',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ==================== SERVER SELECTION CARD ====================
                      // Card displaying currently selected server with dropdown functionality
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.05,
                          ), // Glass effect background
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.1,
                            ), // Subtle border
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card title
                            const Text(
                              'Server Location',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Selected server display with tap to change
                            Obx(() {
                              // Find currently selected server configuration
                              final selectedServer = controller.vpnConfigs
                                  .firstWhere(
                                    (config) =>
                                        config.country ==
                                        controller.selectedConfig.value,
                                  );

                              return InkWell(
                                onTap:
                                    () => _showServerSelection(
                                      context,
                                      controller,
                                    ),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Country flag emoji
                                      Text(
                                        selectedServer.flag,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(width: 12),

                                      // Country and city information
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            selectedServer.country,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            selectedServer.cityName,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),

                                      // Dropdown arrow icon
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================== CONNECTION STATISTICS ====================
                      // Card showing download/upload speeds (fades when disconnected)
                      Obx(
                        () => AnimatedOpacity(
                          // Reduce opacity when disconnected
                          opacity:
                              controller.stage.value == 'connected' ? 1.0 : 0.5,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Download speed section
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.download_rounded,
                                        color: Color(0xFF00D4AA), // Teal green
                                        size: 28,
                                      ),
                                      const SizedBox(height: 8),

                                      // Real-time download speed display
                                      Obx(
                                        () => Text(
                                          '${controller.downloadSpeed.value.toStringAsFixed(1)} Mbps',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'Download',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Vertical divider between download and upload
                                Container(
                                  width: 1,
                                  height: 60,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),

                                // Upload speed section
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Icon(
                                        Icons.upload_rounded,
                                        color: Color(0xFF00D4AA), // Teal green
                                        size: 28,
                                      ),
                                      const SizedBox(height: 8),

                                      // Real-time upload speed display
                                      Obx(
                                        () => Text(
                                          '${controller.uploadSpeed.value.toStringAsFixed(1)} Mbps',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'Upload',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ==================== CONNECT/DISCONNECT BUTTON ====================
                      // Main action button that changes color and text based on connection status
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Obx(
                          () => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: ElevatedButton(
                              // Disable button when connecting to prevent multiple taps
                              onPressed:
                                  controller.isConnecting.value
                                      ? null
                                      : () {
                                        if (controller.stage.value ==
                                            'connected') {
                                          controller
                                              .disconnect(); // Disconnect if currently connected
                                        } else {
                                          controller
                                              .startVpn(); // Connect if currently disconnected
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                // Dynamic button color: Red when connected, Green when disconnected
                                backgroundColor:
                                    controller.stage.value == 'connected'
                                        ? const Color(
                                          0xFFFF4757,
                                        ) // Red for disconnect
                                        : const Color(
                                          0xFF00D4AA,
                                        ), // Green for connect
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    28,
                                  ), // Rounded corners
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                minimumSize: const Size(
                                  double.infinity,
                                  56,
                                ), // Full width button
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Show loading spinner when connecting
                                  if (controller.isConnecting.value) ...[
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ] else ...[
                                    // Show power icon when not connecting
                                    Icon(
                                      controller.stage.value == 'connected'
                                          ? Icons.power_settings_new_rounded
                                          : Icons.power_settings_new_rounded,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                  ],

                                  // Dynamic button text based on connection state
                                  Text(
                                    controller.isConnecting.value
                                        ? 'Connecting...'
                                        : controller.stage.value == 'connected'
                                        ? 'Disconnect'
                                        : 'Connect',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32), // Bottom spacing
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

  /// Shows bottom sheet modal for server selection
  /// Displays all available VPN server locations with flags and names
  void _showServerSelection(BuildContext context, VpnController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allow content to determine height
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1D), // Dark background
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar at top of bottom sheet
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Bottom sheet title
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Select Server Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                // List of all available VPN servers
                ...controller.vpnConfigs.map(
                  (config) => ListTile(
                    leading: Text(
                      config.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      config.country,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      config.cityName,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    // Show check mark for currently selected server
                    trailing:
                        controller.selectedConfig.value == config.country
                            ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFF00D4AA),
                            )
                            : null,
                    onTap: () async {
                      // Change server configuration and close bottom sheet
                      await controller.changeConfig(config.country);
                      Get.back();
                      // Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 24), // Bottom spacing
              ],
            ),
          ),
    );
  }
}
