# DineAssist AI - Restaurant Order System

Flutter restaurant ordering system for table-based ordering, QR code access, bill receipt generation, and thermal printer output. The app supports native/mobile workflows and a Flutter web deployment path with a Node.js print bridge for receipt printing.

<img src="assets/images/logo.png" alt="DineAssist AI logo" height="220" />

## Features

- **Table selection** - route customers or staff into a table-specific ordering flow.
- **Menu browsing** - restaurant screen with menu item cards and order state.
- **Bill receipt UI** - reusable receipt widget for printable order summaries.
- **QR code generator** - create QR codes for table/order access.
- **Thermal printing** - ESC/POS printer support through native and web services.
- **Web print bridge** - browser printing through a local Node.js bridge server.
- **Firebase-ready deployment** - Firebase options and documented web deploy steps.

## Architecture

```text
lib/
├── main.dart
├── configuration/
│   ├── rest_service.dart
│   ├── wifiscan_service.dart
│   ├── wifiscan_service_native.dart
│   └── wifiscan_service_web.dart
├── controller/
│   ├── printer_controller.dart
│   └── restaurant_controller.dart
├── model/
│   └── order_model.dart
├── routes/
│   ├── app_bindings.dart
│   ├── app_pages.dart
│   └── app_routes.dart
├── service/
│   ├── printer_service.dart
│   ├── printer_service_native.dart
│   └── printer_service_web.dart
└── view/
    ├── qr_generator/qr_code_generator.dart
    ├── restaurant_screen.dart
    ├── splash_screen.dart
    ├── table_selection_screen.dart
    └── widgets/
        ├── bill_receipt.dart
        └── menu_item_card.dart
```

## Getting Started

### Prerequisites

- Flutter SDK with Dart `^3.11.5`
- Android Studio or Xcode for mobile builds
- Node.js for web thermal printing
- Firebase CLI for deployment

### Run Locally

```bash
flutter pub get
flutter run
```

## Print Bridge Server For Web Printing

To print from the web app to a thermal printer, the **Node.js bridge server** must be running.

### Requirements

- Node.js must be installed
- The billing computer and printer must be on the same WiFi network

### Steps to Start the Server

**Step 1** - Navigate to the project folder:

```bash
cd Dineassist-Ai
```

**Step 2** - Start the server:

```bash
node print_bridge_server.js
```

**Step 3** - You should see this message:

```text
========================================
  Print Bridge Server  —  Port 8080
  Keep this running while using the web app
========================================
```

> Do not close the terminal — keep the server running as long as you need to print from the web app.

---

### Printing Notes

- **Same WiFi** — The mobile/tablet and billing computer must be on the same WiFi network
- **Printer IP** — Default printer IP: `192.168.1.223` (to change it, update `printerIp` in `printer_controller.dart`)
- **Bridge URL** — The web app connects to `http://192.168.1.9:8080` (local IP of the billing computer)

---

## Deployment Steps

```bash
# 1. Install dependencies
flutter pub get

# 2. Build for web
flutter build web

# 3. Deploy to Firebase (use Node.js v22)
PATH="/opt/homebrew/opt/node@22/bin:$PATH" firebase deploy
```

## Key Dependencies

| Package | Purpose |
|---|---|
| `get` | Routing, state management, dependency injection |
| `dio` / `http` | API communication |
| `speech_to_text` | Voice input support |
| `qr_flutter` | QR code generation |
| `firebase_core` | Firebase app initialization |
| `esc_pos_printer_plus` | Thermal printer connection |
| `esc_pos_utils_plus` | ESC/POS receipt commands and capabilities |
| `google_fonts` | Typography |

## Quality

```bash
flutter analyze
flutter test
dart format .
```

## Notes

- Keep the bridge server running while printing from web.
- Update the printer IP and bridge URL before deploying to a different network.
- The app is private and is not intended for publishing to pub.dev.
