# 💬 Bluetooth Chat

A Flutter chat app that lets two nearby devices message each other — with text, images, and video — entirely over Bluetooth, with no WiFi, mobile data, or internet connection required.

## ✨ Key Features

- 📡 **Device Discovery & Pairing** — Scan and connect to nearby devices using both Bluetooth Classic and BLE (`flutter_blue_plus`, `ble_peripheral`, `bt_classic`)
- 💬 **Real-Time Messaging** — Send and receive text messages with delivery status (sent / delivered / read)
- 🖼️ **Media Sharing** — Send images and videos over the Bluetooth link, with automatic video compression (`video_compress`) before transfer
- 📊 **Chunked File Transfer** — Files are split into MTU-optimized chunks with live progress tracking (`FileTransferService`)
- 👤 **Profile & Settings** — Configure device profile and app preferences, persisted locally
- 🎨 **Polished UI** — Custom theming, shimmer loading states, and smooth transitions (`flutter_animate`, `animate_do`, `shimmer`)
- 🧭 **MVC Architecture** — Clean separation of views, controllers, and bindings using GetX

## 🛠️ Tech Stack

| Layer            | Technology                                             |
| ---------------- | -------------------------------------------------------|
| Framework        | Flutter                                                 |
| State Management | GetX                                                    |
| Bluetooth        | `flutter_blue_plus`, `flutter_ble_peripheral`, `ble_peripheral`, `bt_classic` |
| Permissions      | `permission_handler`                                    |
| Media            | `image_picker`, `video_compress`, `video_player`         |
| Storage          | `shared_preferences`                                     |
| UI               | `google_fonts`, `flutter_animate`, `animate_do`, `shimmer` |

## 📁 Project Structure

```
lib/
├── main.dart
├── core/
│   ├── theme/app_theme.dart
│   └── services/
│       ├── bluetooth_service.dart              # BLE discovery & connection
│       ├── classic_bluetooth_chat_service.dart # Classic Bluetooth chat channel
│       ├── file_transfer_service.dart           # Chunked file/media transfer
│       └── storage_service.dart                 # Local chat history persistence
├── modules/
│   ├── splash/
│   ├── home/           # Device list & discovery
│   ├── connect/         # Pairing / connection flow
│   ├── chat/             # Messaging screen & controller
│   └── profile/          # Profile & settings
└── routes/
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Two physical Bluetooth-capable devices (Bluetooth features do not work on most emulators)

### Installation

```bash
flutter pub get
flutter run
```

### Usage

1. Grant Bluetooth and nearby-device permissions when prompted.
2. On the **Home** screen, tap **Scan** to discover nearby devices running the app.
3. Select a device to connect and open the chat screen.
4. Send text, photos, or videos — delivery status updates in real time as the transfer completes.

## 📌 Known Limitations

- Bluetooth Classic and BLE availability/behavior varies by device manufacturer and OS version.
- Large video files take longer to transfer due to Bluetooth's limited bandwidth compared to WiFi.
