# 🔎 TextLens Pro — OCR Text Scanner & Finder

A premium Flutter OCR app that extracts text from live camera frames or photos using on-device machine learning — perfect for digitizing documents, grabbing text from signs, or searching within scanned pages.

## ✨ Key Features

- 📷 **Live Scanner** — Real-time text detection and highlighting through the camera viewfinder
- 🖼️ **Photo to Text** — Extract text from an existing photo or a freshly captured picture
- ✨ **On-Device OCR** — Powered by `google_mlkit_text_recognition` — fast, offline, and privacy-friendly
- 🔍 **Text Highlighting** — Recognized text blocks/lines are highlighted directly on the image with a custom overlay painter
- 📋 **Copy, Share & Open Links** — Copy extracted text, share it via `share_plus`, or open detected URLs with `url_launcher`
- 🎨 **Polished Result Screen** — Clean, readable presentation of scanned text with quick actions

## 🛠️ Tech Stack

| Layer            | Technology                              |
| ---------------- | -----------------------------------------|
| Framework        | Flutter                                  |
| OCR Engine       | `google_mlkit_text_recognition`           |
| Camera           | `camera`, `image_picker`                   |
| Permissions      | `permission_handler`                        |
| Sharing          | `share_plus`, `url_launcher`                 |

## 📁 Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── live_scanner_screen.dart   # Real-time camera OCR
│   ├── photo_text_screen.dart     # Extract text from a photo
│   └── result_screen.dart         # Extracted text + actions
├── services/
│   └── ocr_service.dart            # ML Kit text recognition wrapper
├── models/
│   └── scan_result.dart
├── widgets/
│   ├── highlighted_text.dart
│   ├── scan_overlay_painter.dart
│   └── action_card.dart
└── utils/
    ├── app_theme.dart
    └── app_colors.dart
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

1. From the home screen, choose **Live Scan** to detect text in real time, or **Photo to Text** to scan an existing/captured image.
2. Detected text blocks are highlighted directly over the image.
3. On the result screen, copy the extracted text, share it, or tap any detected link to open it.

## 📌 Note

All OCR processing happens on-device via ML Kit — no image or text ever leaves the phone.
