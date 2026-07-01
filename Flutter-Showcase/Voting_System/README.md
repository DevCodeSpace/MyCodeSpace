# 🗳️ Team Awards Voting System

A Flutter + Firebase peer-recognition app that lets team members vote for colleagues across a set of fun award categories (e.g. "Rapid Delivery Pro", "Unsung Hero", "Innovation Ninja") — with one submission per person and live, aggregated results.

<p align="center">
  <img src="assets/voting_img.png" alt="Team Awards Voting" height="220" />
</p>

## ✨ Key Features

- 🔐 **Firebase Authentication** — Secure email/password login and registration (`firebase_auth`)
- 🏆 **Multi-Category Voting** — Vote for a colleague in each award category, one at a time, in a guided flow
- ✅ **One-Time Submission** — Each authenticated user can submit their votes once; the app tracks submission state to prevent duplicates
- 👥 **Live User Directory** — Candidate list is pulled in real time from Cloud Firestore
- 📊 **Results Screen** — View aggregated vote tallies per award category once voting closes
- 🎬 **Animated UI** — Smooth onboarding/loading animations via `lottie`

## 🛠️ Tech Stack

| Layer            | Technology                          |
| ---------------- | -------------------------------------|
| Framework        | Flutter                              |
| Auth             | Firebase Authentication              |
| Database         | Cloud Firestore                       |
| Animation        | `lottie`                               |

## 📁 Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
└── screens/
    ├── login_screen.dart
    ├── register_screen.dart
    ├── home_screen.dart              # Award categories + candidate voting flow
    └── voting_results_screen.dart    # Aggregated results view
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- A Firebase project with **Authentication** (Email/Password) and **Cloud Firestore** enabled
- `flutterfire configure` run against your own Firebase project to regenerate `firebase_options.dart`

### Installation

```bash
flutter pub get
flutter run
```

### Usage

1. **Register** a new account or **log in** with existing credentials.
2. Step through each award category and select the colleague you're voting for.
3. Submit your ballot — the app records it against your user ID so you can't vote twice.
4. Visit the **Results** screen to see live vote counts once available.

## 📌 Notes

- Firestore security rules should restrict each user to writing only their own vote document to enforce the one-vote-per-person rule server-side.
- This project ships with a demo `firebase_options.dart` — replace it with your own Firebase project configuration before deploying.
