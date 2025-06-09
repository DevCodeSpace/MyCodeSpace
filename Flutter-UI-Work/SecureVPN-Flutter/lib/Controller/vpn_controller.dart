import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:wireguard_flutter/wireguard_flutter.dart';

/// Model class representing a VPN server configuration
/// Contains all necessary information for connecting to a specific VPN server
class VpnConfig {
  final String country; // Country name (e.g., "Japan")
  final String
  serverAddress; // Server IP and port (e.g., "103.125.235.18:51820")
  final String wgConfig; // WireGuard configuration string
  final String name; // Internal server name (e.g., "jp_free_1")
  final String flag; // Country flag emoji (e.g., "🇯🇵")
  final String cityName; // City where server is located (e.g., "Tokyo")

  VpnConfig({
    required this.country,
    required this.serverAddress,
    required this.wgConfig,
    required this.name,
    required this.flag,
    required this.cityName,
  });
}

/// Main VPN controller managing all VPN operations and state
/// Uses GetX for reactive state management across the app
class VpnController extends GetxController {
  // ==================== CORE VPN INSTANCE ====================
  /// WireGuard Flutter plugin instance for VPN operations
  final wireguard = WireGuardFlutter.instance;

  // ==================== REACTIVE STATE VARIABLES ====================
  /// Current country detected from IP geolocation
  var country = 'Unknown'.obs;

  /// Current VPN connection stage (disconnected, connecting, connected, etc.)
  var stage = 'disconnected'.obs;

  /// Real-time download speed in Mbps
  var downloadSpeed = 0.0.obs;

  /// Real-time upload speed in Mbps
  var uploadSpeed = 0.0.obs;

  /// Currently selected VPN server country
  var selectedConfig = 'Japan'.obs;

  /// Flag indicating if VPN is currently in the process of connecting
  var isConnecting = false.obs;

  /// Current public IP address
  var currentIP = 'Checking...'.obs;

  /// Current location (city, country) based on IP
  var currentLocation = 'Unknown'.obs;

  /// Timer for periodic speed testing (runs every 5 seconds when connected)
  Timer? _speedTestTimer;

  // ==================== VPN SERVER CONFIGURATIONS ====================
  /// List of all available VPN server configurations
  /// Each server includes WireGuard config, location info, and connection details
  final List<VpnConfig> vpnConfigs = [
    // Japan Server Configuration
    VpnConfig(
      country: 'Japan',
      name: 'jp_free_1',
      serverAddress: '103.125.235.18:51820',
      flag: '🇯🇵',
      cityName: 'Tokyo',
      wgConfig: '''
[Interface]
PrivateKey = YDbWuyBusCkpuVvr/bDuPL5FlY5A0neziZOUw/m2a3I=
Address = 10.2.0.2/32
DNS = 10.2.0.1

[Peer]
PublicKey = agoivyLoPqor8MxA/s6UWJSMcA2pMl+ajO3vy/q3oWQ=
AllowedIPs = 0.0.0.0/0
Endpoint = 103.125.235.18:51820
''',
    ),

    // Romania Server Configuration
    VpnConfig(
      country: 'Romania',
      name: 'ro_free_1',
      serverAddress: '149.102.239.225:51820',
      flag: '🇷🇴',
      cityName: 'Bucharest',
      wgConfig: '''
[Interface]
PrivateKey = EFZFRmzRI1FAVD/KRkZF9khEQuzMAIu0F5wGN8Zpnmo=
Address = 10.2.0.2/32
DNS = 10.2.0.1

[Peer]
PublicKey = 5qZc9c0rHEKhBXd+NnQ69AJuYjCKqTjt1hM2+UaZDng=
AllowedIPs = 0.0.0.0/0
Endpoint = 149.102.239.225:51820
''',
    ),

    // United States Server Configuration
    VpnConfig(
      country: 'United States',
      name: 'usa_free_47',
      serverAddress: '193.148.16.2:51820',
      flag: '🇺🇸',
      cityName: 'New York',
      wgConfig: '''
[Interface]
PrivateKey = 4LP57prpRGZCV+EBQq+3XdK1UKqzW0roxCS3AM5KdEg=
Address = 10.2.0.2/32
DNS = 10.2.0.1

[Peer]
PublicKey = ksK3faRBQlFLul2FcKPphBR9LYR+6/FbP1etg0T2liA=
AllowedIPs = 0.0.0.0/0
Endpoint = 37.19.221.198:51820
''',
    ),

    // Poland Server Configuration
    VpnConfig(
      country: 'Poland',
      name: 'pl_free_1',
      serverAddress: '193.148.16.2:51820',
      flag: '🇵🇱',
      cityName: 'Warsaw',
      wgConfig: '''
[Interface]
PrivateKey = ALxah+kYecgcfwE/KQdmVnYgp6j5K29imCOvsvhMglw=
Address = 10.2.0.2/32
DNS = 10.2.0.1

[Peer]
PublicKey = ScCkMvpikYBB3IFtDJC6Xh59pmq4StGlU/JfvALPxUE=
AllowedIPs = 0.0.0.0/0
Endpoint = 149.102.244.97:51820
''',
    ),

    // Netherlands Server Configuration
    VpnConfig(
      country: 'Netherlands',
      name: 'nl_free_200',
      serverAddress: '80.79.6.83:51820',
      flag: '🇳🇱',
      cityName: 'Amsterdam',
      wgConfig: '''
[Interface]
PrivateKey = uD8RIaHwwqFgMofb+p7ZjGjZVTLuqIE2K9OOTkStF1U=
Address = 10.2.0.2/32
DNS = 10.2.0.1

[Peer]
PublicKey = YmVuJnmFWOKaFOxY0kKgURss6jql5ow2oAQVPA4j/mM=
AllowedIPs = 0.0.0.0/0
Endpoint = 194.59.6.3:51820
''',
    ),
  ];

  // ==================== CONTROLLER LIFECYCLE METHODS ====================

  /// Called when controller is initialized
  /// Sets up VPN stage monitoring and initializes WireGuard
  @override
  void onInit() {
    super.onInit();

    // Listen to VPN connection stage changes (disconnected, connecting, connected, etc.)
    wireguard.vpnStageSnapshot.listen((event) async {
      // Extract stage name from enum (e.g., "VpnStage.connected" -> "connected")
      stage.value = event.toString().split('.').last;
      isConnecting.value = false; // Reset connecting flag when stage changes

      if (stage.value == 'connected') {
        // When successfully connected, start monitoring and testing
        await detectCountry(); // Get current country from IP
        await startPeriodicSpeedTest(); // Begin speed monitoring
        await checkIPAddress(); // Get current public IP
      } else {
        // When disconnected, stop monitoring and reset values
        stopPeriodicSpeedTest();
        currentIP.value = 'Checking...';
        currentLocation.value = 'Unknown';
      }
    });

    // Initialize WireGuard with retry logic
    initialize();
  }

  /// Called when controller is disposed
  /// Ensures proper cleanup of timers and resources
  @override
  void onClose() {
    stopPeriodicSpeedTest(); // Cancel speed test timer
    super.onClose();
  }

  // ==================== INITIALIZATION METHODS ====================

  /// Initialize WireGuard VPN with retry logic for reliability
  /// Attempts initialization up to 3 times with 2-second delays between retries
  Future<void> initialize() async {
    const maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        await wireguard
            .initialize(interfaceName: vpnConfigs.first.name)
            .timeout(
              const Duration(seconds: 20), // 20-second timeout
              onTimeout: () {
                throw TimeoutException(
                  'Initialization timed out after 20 seconds',
                );
              },
            );
        return; // Success - exit retry loop
      } catch (error) {
        retryCount++;
        if (retryCount == maxRetries) {
          log('Initialization error: $error');
        } else {
          await Future.delayed(const Duration(seconds: 2)); // Wait before retry
          log('Retrying initialization ($retryCount/$maxRetries)...');
        }
      }
    }
  }

  // ==================== NETWORK DETECTION METHODS ====================

  /// Detect current country and location using IP geolocation API
  /// Uses ip-api.com service for free geolocation data
  Future<void> detectCountry() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        country.value = data['country'] ?? 'Unknown';
        // Combine city and country for location display
        currentLocation.value = '${data['city']}, ${data['country']}';
      }
    } catch (e) {
      // Handle errors gracefully by setting default values
      country.value = 'Unknown';
      currentLocation.value = 'Unknown';
    }
  }

  /// Get current public IP address using ipify.org service
  /// Simple API that returns just the IP address as plain text
  Future<void> checkIPAddress() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        currentIP.value = response.body; // Plain text IP response
      }
    } catch (e) {
      currentIP.value = 'Error';
    }
  }

  // ==================== SPEED TESTING METHODS ====================

  /// Perform network speed test using Cloudflare's speed test endpoints
  /// Tests both download and upload speeds and updates reactive variables
  Future<void> testSpeed() async {
    try {
      // ============ DOWNLOAD SPEED TEST ============
      final startTime = DateTime.now();
      final response = await http.get(
        Uri.parse(
          'https://speed.cloudflare.com/__down?bytes=10000000',
        ), // Download 10MB
      );

      final endTime = DateTime.now();
      final duration =
          endTime.difference(startTime).inMilliseconds /
          1000; // Convert to seconds
      final bytes = response.bodyBytes.length;
      // Calculate Mbps: (bytes * 8 bits per byte) / (duration in seconds) / 1,000,000
      downloadSpeed.value = (bytes * 8 / duration / 1000000);

      // ============ UPLOAD SPEED TEST ============
      final uploadStart = DateTime.now();
      await http.post(
        Uri.parse('https://speed.cloudflare.com/__up'),
        body: 'A' * 1000000, // Upload 1MB of data
      );

      final uploadEnd = DateTime.now();
      final uploadDuration =
          uploadEnd.difference(uploadStart).inMilliseconds / 1000;
      // Calculate upload speed in Mbps
      uploadSpeed.value = (1000000 * 8 / uploadDuration / 1000000);
    } catch (e) {
      // Reset speeds to 0 on error
      downloadSpeed.value = 0.0;
      uploadSpeed.value = 0.0;
      log('Speed test error: $e');
    }
  }

  /// Start periodic speed testing that runs every 5 seconds when connected
  /// Provides real-time speed monitoring for connected VPN sessions
  Future<void> startPeriodicSpeedTest() async {
    // Run initial speed test immediately
    await testSpeed();

    // Start periodic timer for continuous monitoring
    _speedTestTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (stage.value == 'connected') {
        await testSpeed(); // Continue testing while connected
      } else {
        stopPeriodicSpeedTest(); // Stop if disconnected
      }
    });
  }

  /// Stop periodic speed testing and reset speed values
  /// Called when VPN disconnects or controller is disposed
  void stopPeriodicSpeedTest() {
    _speedTestTimer?.cancel(); // Cancel the timer
    _speedTestTimer = null; // Clear the timer reference
    downloadSpeed.value = 0.0; // Reset download speed
    uploadSpeed.value = 0.0; // Reset upload speed
  }

  // ==================== VPN CONNECTION METHODS ====================

  /// Start VPN connection using the currently selected server configuration
  /// Handles connection process with timeout and retry logic
  Future<void> startVpn() async {
    try {
      isConnecting.value = true; // Set connecting flag for UI feedback

      // Find the selected server configuration
      final config = vpnConfigs.firstWhere(
        (c) => c.country == selectedConfig.value,
      );

      // Start VPN connection with WireGuard
      await wireguard.startVpn(
        serverAddress: config.serverAddress,
        wgQuickConfig: config.wgConfig,
        // iOS-specific: Bundle identifier for WireGuard network extension
        providerBundleIdentifier: 'com.example.vpn_demo_latest.WGExtension',
      );

      // Wait for connection to be established (max 5 seconds)
      int retries = 10;
      while (stage.value != 'connected' && retries > 0) {
        await Future.delayed(const Duration(milliseconds: 500));
        retries--;
      }

      if (stage.value == 'connected') {
        // Connection successful - start monitoring
        await detectCountry();
        await startPeriodicSpeedTest();
        await checkIPAddress();
      } else {
        log('Timeout : VPN connected stage not reached in time.');
      }
    } catch (error) {
      log('Start VPN error: $error');
      isConnecting.value = false; // Reset connecting flag on error
    }
  }

  /// Disconnect from VPN and cleanup monitoring
  /// Stops all background monitoring and resets connection state
  Future<void> disconnect() async {
    try {
      stopPeriodicSpeedTest(); // Stop speed monitoring first
      await wireguard.stopVpn(); // Disconnect from VPN
      country.value = 'Unknown'; // Reset country detection
    } catch (e) {
      log('Failed to disconnect: $e');
    }
  }

  /// Get current VPN connection status from WireGuard
  /// Useful for refreshing connection state or debugging
  Future<void> getStatus() async {
    try {
      final currentStage = await wireguard.stage();
      stage.value = currentStage.toString().split('.').last;
    } catch (e) {
      log('Failed to get status: $e');
    }
  }

  /// Change VPN server configuration
  /// If currently connected, disconnects and reconnects to new server
  /// If disconnected, just updates the selection for next connection
  Future<void> changeConfig(String newConfig) async {
    if (stage.value == 'connected') {
      // If connected, disconnect first then reconnect with new config
      await disconnect().then((_) async {
        selectedConfig.value = newConfig;
        await startVpn();
      });
    } else {
      // If disconnected, just update the selection
      selectedConfig.value = newConfig;
    }
  }
}
