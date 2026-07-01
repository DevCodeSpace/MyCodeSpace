# 🖱️ WiFi Mouse Pro

WiFi Mouse Pro is a high-performance mobile utility that transforms your smartphone into a remote input device for your computer. By establishing a connection over Wi-Fi, the app enables seamless control of cursor movement, keyboard input, scrolling, and media playback without requiring physical peripherals.

The application is designed with a focus on low-latency interaction, ensuring real-time responsiveness and a smooth user experience across different use cases such as presentations, media control, and general desktop navigation.

---

## Features

### Intelligent Cursor Control

- High-precision virtual trackpad
- Tap-to-click and long-press drag support
- Smooth and responsive cursor movement

### Seamless Scrolling

- Gesture-based scrolling
- Optimized for documents and web navigation

### Remote Keyboard Input

- Type directly from mobile device
- Works across all active input fields on desktop

### Universal Media Controls

- Play and pause functionality
- Volume control
- Track navigation

### Gyroscope-Based Motion Control

- Control cursor using device motion
- Suitable for presentations and hands-free navigation

### Customisable Cursor Sensitivity

- Adjustable speed and responsiveness
- Suitable for both precision and fast navigation

### Wi-Fi Connectivity

- Connect using local IP address
- Stable and low-latency communication

### Minimal User Interface

- Dark theme design
- Focus on usability and performance

---

## Tech Stack

### Mobile Application

- Flutter
- Dart

### Desktop Server

- Node.js

---

## Dependencies

- network_info_plus
- permission_handler
- web_socket_channel
- shared_preferences
- sensors_plus
- volume_controller

---

## Platform Support

- Android (Mobile Application)
- Windows / macOS / Linux (Desktop Server)

---

## Usage

- Use the touchpad to move the cursor
- Tap to click
- Long press to drag
- Scroll using gestures
- Use the keyboard section for typing
- Control media playback from the app

---

## Important Notes

- Both devices must be connected to the same Wi-Fi network
- Allow firewall permissions when prompted
- Keep the server running while using the app
- Disable VPN if connectivity issues occur

---

## Troubleshooting

### Unable to connect

- Verify IP address is correct
- Ensure both devices are on the same network
- Restart the server

### Cursor not responding

- Ensure server is running
- Check firewall settings

### Gyroscope not working

- Grant motion permissions
- Recalibrate by holding device steady
