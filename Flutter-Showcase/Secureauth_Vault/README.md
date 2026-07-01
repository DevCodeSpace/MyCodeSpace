# 🔒 SecureAuth Vault

An all-in-one Flutter security vault for credentials, documents, and 2FA codes — protected behind biometric/PIN authentication and AES-256 encryption, with optional encrypted Google Drive backup.

<p align="center">
  <img src="assets/logo/logo.png" alt="SecureAuth Vault" height="120" />
</p>

## ✨ Key Features

- 🔑 **Password Vault** — Store, categorize, and tag login credentials with a built-in strong password generator
- 📄 **Document Vault** — Securely store scanned documents and files, organized into folders
- 🔐 **Built-in Authenticator** — Generate live TOTP 2FA codes for other accounts, enrolled via QR scan (`mobile_scanner`, `otp`)
- 🧬 **Biometric & PIN Lock** — App unlock via fingerprint/Face ID (`local_auth`) with a custom PIN pad fallback
- 🛡️ **AES-256 Encryption at Rest** — All sensitive data is encrypted (`encrypt`, `crypto`) before being persisted to a local SQLite database
- 🔑 **OS-Backed Secure Storage** — Master keys held in Keychain (iOS) / Keystore (Android) via `flutter_secure_storage`
- ☁️ **Encrypted Google Drive Backup** — Optional backup/restore of the vault to the user's own Google Drive (`google_sign_in`, `googleapis`)
- 🧩 **Server-Driven UI Module** — Dynamic UI screens rendered via `stac`, configurable through Firebase Remote Config

## 🛠️ Tech Stack

| Layer            | Technology                                                     |
| ---------------- | -----------------------------------------------------------------|
| Framework        | Flutter                                                           |
| State Management | GetX                                                              |
| Local Database   | `sqflite`                                                          |
| Encryption       | `encrypt` (AES-256), `crypto`, `flutter_secure_storage`             |
| Biometrics       | `local_auth`                                                       |
| 2FA / OTP        | `otp`, `mobile_scanner`                                             |
| Cloud Backup     | `google_sign_in`, `googleapis`, Firebase                              |
| File Handling    | `file_picker`, `image_picker`, `path_provider`                          |

## 📁 Project Structure

```
lib/
├── main.dart
├── models/            # Credential, Document, Category, Account models
├── widgets/
│   └── pin_pad.dart
├── core/
│   ├── services/       # Encryption, database, auth & backup services
│   └── utils/           # Password generator, tag helper, constants
├── app/
│   ├── theme/
│   ├── bindings/
│   └── routes/
└── modules/
    ├── splash/
    ├── setup/            # First-run vault setup (master PIN/biometric)
    ├── auth/              # Unlock screen
    ├── authentication/     # Built-in TOTP authenticator (scan + codes)
    ├── dashboard/
    ├── credentials/         # Password vault CRUD
    ├── documents/            # Document vault + folders
    ├── settings/              # Backup, security & app settings
    └── sdui/                    # Server-driven UI renderer
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- A Firebase project (for Remote Config) and Google Cloud OAuth credentials (for Drive backup)
- Android/iOS device with biometric hardware for full functionality

### Installation

```bash
flutter pub get
flutter run
```

### Usage

1. On first launch, complete **Setup** — create a master PIN and optionally enable biometric unlock.
2. Add **Credentials** (with auto-generated strong passwords) or upload **Documents** into folders.
3. Scan a service's 2FA QR code under **Authenticator** to generate live TOTP codes alongside your vault.
4. From **Settings**, sign in with Google to enable encrypted backup/restore of your vault.

## 🔒 Security Notes

- All credential and document data is encrypted with AES-256 before it touches disk; the encryption key itself is stored in the platform's secure enclave (Keychain/Keystore), not in the app's plaintext storage.
- Google Drive backup uploads only the encrypted vault blob — Google never sees your data in plaintext.
