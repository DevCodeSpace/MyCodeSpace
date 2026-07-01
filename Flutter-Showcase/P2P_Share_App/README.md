# 📤 ShareSphere — P2P File Transfer

A Flutter app for transferring files directly between devices over the local WiFi network — no cables, no cloud upload, no internet dependency. One device hosts a lightweight local server; the other connects and pulls the files straight across the LAN.

## ✨ Key Features

- 📡 **Local Network Discovery** — Detects devices on the same WiFi network using `network_info_plus`
- 🔗 **QR Code Connect** — Pair devices instantly by scanning a QR code instead of typing an IP address (`qr_flutter`)
- 📤 **Send Files** — Pick any file type from the device library (`file_picker`) and push it to a connected peer
- 📥 **Receive Files** — Accept incoming transfers with a live progress screen
- 📊 **Transfer Progress & History** — Real-time transfer status plus a persisted history of past sends/receives
- 🖥️ **Embedded HTTP Server** — Runs a local `shelf` / `shelf_router` server on-device to serve and receive files over HTTP
- 🧭 **Clean Architecture** — Organized into `data` / `domain` / `presentation` layers with GetX for state and routing

## 🛠️ Tech Stack

| Layer            | Technology                                  |
| ---------------- | --------------------------------------------|
| Framework        | Flutter                                     |
| State Management | GetX                                        |
| Local Server     | `shelf`, `shelf_router`                     |
| Networking       | `dio`, `network_info_plus`                  |
| File Handling    | `file_picker`, `path_provider`               |
| QR Code          | `qr_flutter`                                 |
| Storage          | `shared_preferences`                         |
| Device Info      | `device_info_plus`, `permission_handler`      |

## 📁 Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                  # Root ShareSphereApp widget
│   ├── theme/
│   ├── bindings/                  # GetX dependency injection
│   └── routes/
├── data/
│   ├── datasources/                 # Local + remote (HTTP server) data sources
│   ├── repositories/
│   ├── models/
│   └── services/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── screens/
    │   ├── splash_screen.dart
    │   ├── home_screen.dart
    │   ├── device_discovery_screen.dart
    │   ├── send_screen.dart
    │   ├── receive_screen.dart
    │   ├── transfer_screen.dart
    │   └── history_screen.dart
    ├── controllers/
    └── widgets/
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Two devices connected to the **same WiFi network**

### Installation

```bash
flutter pub get
flutter run
```

### Usage

1. On the receiving device, open **Receive** to start the local server and display a connection QR code.
2. On the sending device, open **Send**, scan the QR code (or select the discovered device), and pick the files to transfer.
3. Watch live progress on the **Transfer** screen until the send/receive completes.
4. Review past transfers anytime from the **History** tab.

## 📌 Notes

- Both devices must be on the same local network/subnet for discovery and transfer to work.
- Ensure firewall settings on the receiving device allow the app's local HTTP server port.
