# 🪪 Aadhaar Data Extractor

A Flutter utility app that scans an Aadhaar card (India's national ID) via camera or a gallery image, decodes the embedded secure QR code, and extracts the holder's details into a clean, verifiable summary card — no manual typing required.

<p align="center">
  <img src="assets/aadhar-logo.png" alt="Aadhaar Data Extractor" height="120" />
</p>

## ✨ Key Features

- 📷 **QR / Barcode Scanning** — Live camera scan via `qr_code_scanner`, plus ML Kit barcode detection for secure QR (SQR) codes
- 🖼️ **Scan from Gallery** — Pick an existing Aadhaar photo with `image_picker` instead of using the live camera
- 🧾 **XML Data Parsing** — Decodes the Aadhaar secure QR payload (XML) into name, DOB, gender, address, and masked Aadhaar number
- ✅ **Review & Confirm** — Presents extracted fields on a government-style summary card before accepting
- 🕓 **Recent Scans** — Keeps a local history of previously scanned records for quick lookup
- 📤 **Export & Share** — Push results to a connected sheet/service (`py_con.dart`) or share via `share_plus`
- ⚙️ **Settings** — Configurable options persisted with `shared_preferences`

## 🛠️ Tech Stack

| Layer            | Technology                                                      |
| ---------------- | ---------------------------------------------------------------- |
| Framework        | Flutter                                                           |
| State Management | GetX                                                              |
| QR / Barcode     | `qr_code_scanner`, `google_mlkit_barcode_scanning`                |
| Data Parsing     | `xml`                                                             |
| Storage          | `shared_preferences`, `path_provider`                            |
| Media            | `image_picker`, `image`                                          |
| Sharing / Export | `share_plus`, `file_picker`, `http`, `url_launcher`               |
| Animation        | `lottie`                                                          |

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point & routing
├── demo_screen.dart        # Landing / scan entry screen
├── home_screen.dart        # Extracted data review screen
├── recent_screen.dart      # Scan history
├── settings.dart            # App settings & preferences
├── aadhar_model.dart        # Aadhaar data model
├── sheet_controller.dart    # GetX controller for data/sheet state
└── py_con.dart               # External service/export connector
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

1. Launch the app and tap **Scan** to open the camera, or **Select Image** to pick a photo from the gallery.
2. Point the camera at the Aadhaar card's secure QR code (back of PVC card or e-Aadhaar printout).
3. Review the extracted Name, DOB, Gender, Address, and masked Aadhaar number.
4. Confirm to save the record to **Recent Scans**, or export/share it.

## 🔒 Note

This app only reads data already encoded in the Aadhaar's official secure QR code — it does not perform OCR on the printed card image or store data on any remote server beyond what you explicitly export.
