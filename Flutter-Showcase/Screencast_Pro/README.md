# ScreenCast Pro

A Flutter application that streams an Android phone's screen live to a Mac, Windows PC, or another Android device over the local WiFi network. This project eliminates the need for cables or third-party services by utilizing a custom UDP discovery protocol and WebSocket streaming.

## Key Features

* **Splash Screen:** A themed entry screen that explains the app's purpose on first launch.
* **System-Wide Capture:** Uses Android's `MediaProjection` API via a Foreground Service. It captures the entire OS display (home screen, other apps, notifications), not just the Flutter widget tree.
* **Browser Casting (MJPEG):** Turns the Android sender into a mini HTTP server. This allows any device with a web browser (Smart TV, PC, another phone) or a media player like VLC to view the cast by simply entering a URL or scanning a QR code. This enables casting to almost any device without a dedicated receiver app.
* **Auto-Discovery:** Automatically finds the receiver on the local network using a UDP broadcast (no manual IP entry required).
* **Seamless Streaming:** Streams JPEG frames over WebSockets directly to the receiver natively encoded by Android to reduce overhead.
* **Mobile-to-Mobile Casting:** An Android device can now act as a receiver natively, keeping the screen alive using `wakelock_plus`.
* **Dynamic Port Allocation:** Automatically assigns a free port for WebSockets to prevent "Address already in use" errors.
* **MVC Architecture:** Clean state management and routing using GetX.

## Network Protocol

* **UDP Broadcast (Port 8766):** The Android sender broadcasts a discovery ping. The receiver responds with its IP address and dynamically assigned WebSocket port.
* **WebSocket Stream (Dynamic Port):** Once connected, the Android device streams screen frames (JPEG encoded, 70% quality) directly to the receiver.

## Getting Started

### Prerequisites
* Flutter SDK installed.
* An Android device (Sender) and a Mac/Windows PC/Android device (Receiver).
* **Important:** Both devices must be connected to the **same local network** (subnet). Ethernet on the Mac works fine as long as it routes to the same local network.
* Ensure your macOS/Windows firewall allows incoming connections on the necessary UDP/TCP ports.

### 1. Start the Receiver (Mac/PC/Android)
Always start the receiver first so it can listen for the Android device.
```bash
cd <project-folder>
flutter run -d <receiver-device-id>
```
*The app will display "Ready to Receive Cast" along with its local IP.*

### 2. Start the Sender (Android)
```bash
flutter run -d <android-device-id>
```
1. Tap **WiFi Casting**.
2. Wait ~4 seconds for the Mac's name to appear in the device list.
3. Tap the Mac's name to initiate the connection.
4. Accept the Android system prompt to "Allow screen recording" (Tap "Start now").
5. Your screen will now stream live to the Mac!
6. Tap **Stop Casting** to end the session.

### Important Note on Rebuilding
Since this app heavily relies on Native Android code (`MainActivity.kt`, `ScreenCaptureService.kt`), you must completely rebuild the app if you modify any native files:
```bash
flutter clean && flutter run -d <android-device-id>
```

## Technical Stack & Packages
* **State Management:** `get` (GetX)
* **Network/WiFi Info:** `network_info_plus`, `connectivity_plus`
* **Permissions:** `permission_handler`
* **Native Android:** Kotlin, `MediaProjection`, `VirtualDisplay`, `ImageReader`, `ForegroundService`.

## Known Limitations
* **Video Only:** System audio is not captured or streamed. The UI volume slider is visual only.
* **Frame Rate:** Throttled to ~6.7 FPS (150ms interval) in the native Android service to preserve WiFi bandwidth.
* **Single Connection:** Supports one active Android sender at a time.
* **Location Permission:** Android 12+ may require location permission grants to properly read the WiFi SSID.
