// AppRoutes defines every named navigation route used in the app.
// GetX maps these string constants to specific screens via AppPages.pages.
abstract class AppRoutes {
  static const splash = '/'; // Initial splash screen
  // Android sender screens (phone/tablet)
  static const home = '/home'; // Home — shows "WiFi Casting" entry card
  static const devices = '/devices'; // Device list — runs UDP broadcast discovery
  static const casting = '/casting'; // Active cast session — streams frames to Mac
  static const publicStream = '/public-stream'; // Browser casting screen (HTTP Server)

  // Mac / PC receiver screen
  static const receiver = '/receiver'; // Fullscreen frame display; Mac opens this at launch

  // Smart TV casting — discovers TVs via SSDP and pushes the MJPEG stream URL
  // using LG SSAP WebSocket / Samsung REST API / DLNA UPnP AVTransport
  static const tvCast = '/tv-cast';
}
