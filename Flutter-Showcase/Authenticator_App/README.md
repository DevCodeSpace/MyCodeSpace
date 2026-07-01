# 🔐 Authenticator

A Flutter-based two-factor authentication (2FA) app that generates time-based one-time passcodes (TOTP), similar to Google Authenticator. Add accounts by scanning a QR code and get live, auto-refreshing 6-digit codes for every service you protect.

## ✨ Key Features

- 📷 **QR Code Enrollment** — Scan any standard `otpauth://` QR code with `mobile_scanner` to add a new account instantly
- 🔢 **Live TOTP Codes** — RFC 6238-compliant codes generated with the `otp` package, refreshing every 30 seconds
- ⏱️ **Countdown Indicator** — Visual timer showing seconds remaining before the next code rotation
- 🔍 **Search Accounts** — Instantly filter saved accounts by name
- 💾 **Local Persistence** — Accounts are stored on-device with `shared_preferences` — no cloud sync, no external servers
- 🎬 **Staggered Animations** — Smooth list entrance animations via `flutter_staggered_animations`
- 🎨 **Custom Theming** — Light/dark theme support with `google_fonts`

## 🛠️ Tech Stack

| Layer            | Technology                              |
| ---------------- | ---------------------------------------- |
| Framework        | Flutter                                  |
| State Management | GetX                                     |
| OTP Generation   | `otp` (TOTP / RFC 6238)                  |
| QR Scanning      | `mobile_scanner`                         |
| Storage          | `shared_preferences`                     |
| UI               | `google_fonts`, `flutter_staggered_animations` |

## 📁 Project Structure

```
lib/
├── main.dart
├── Controller/
│   ├── auth_controller.dart     # Account list, TOTP timer, persistence
│   ├── scan_controller.dart     # otpauth:// URI parsing & account creation
│   └── theme_controller.dart    # Light/dark theme state
├── Model/
│   └── account_model.dart       # Account (issuer, label, secret) model
├── Scan/
│   └── scan_screen.dart         # QR scanner screen
├── dashboard/
│   └── dashboard_screen.dart    # Account list with live codes
├── Component/
│   └── app_drawer.dart
└── Routes/
    ├── app_route.dart
    └── app_pages.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- Android/iOS device or emulator with camera access

### Installation

```bash
flutter pub get
flutter run
```

### Usage

1. Tap **Scan** on the dashboard and point the camera at a service's 2FA setup QR code.
2. The account (issuer + label) is added automatically once the `otpauth://` payload is recognized.
3. View live, auto-refreshing 6-digit codes on the dashboard, with a per-account countdown to the next rotation.
4. Use the search bar to quickly find an account when your list grows.

## 🔒 Note

All secrets are stored locally on-device only. Uninstalling the app or clearing app data will remove all enrolled accounts — make sure your services offer backup codes.
