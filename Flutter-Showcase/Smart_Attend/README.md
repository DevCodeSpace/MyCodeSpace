# Smart Attend — Face Attendance System

A Flutter-based employee attendance management app powered by face liveness detection. Employees are enrolled via face scan, and daily check-in / check-out is verified through the same liveness flow — no manual entry required.

---

## Features

- **Face Enrollment** — Register each employee's face using liveness detection
- **Check-In / Check-Out** — Attendance marked via face scan, not manual tap
- **Live Status Tracking** — Real-time present / absent / late counts on the dashboard
- **Attendance History** — Full log of all check-in and check-out records
- **Animated Working Indicator** — Visual pulse badge for employees currently on shift
- **Premium Dashboard UI** — Ocean-deep gradient app bar, glassmorphic stats panel, department-colored employee cards

---

## Tech Stack

| Layer            | Technology                             |
| ---------------- | -------------------------------------- |
| Framework        | Flutter 3.x                            |
| State Management | GetX                                   |
| Face Detection   | flutter_face_liveness                  |
| Architecture     | GetX MVC (Controller / View / Binding) |

---

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── employee_model.dart       # Employee data + demo list
│   └── attendance_model.dart     # Attendance record + status enum
├── modules/
│   └── attendance/
│       ├── attendance_binding.dart   # GetX dependency injection
│       ├── attendance_controller.dart # Core business logic
│       ├── home_view.dart            # Main dashboard screen
│       ├── history_view.dart         # Attendance logs screen
│       └── liveness_view.dart        # Face scan screen
│   └── splash/
│       └── splash_view.dart
└── routes/
    ├── app_routes.dart           # Route name constants
    └── app_pages.dart            # Route definitions
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.5`
- Dart SDK `^3.11.5`
- Android Studio / Xcode for device deployment

### Installation

```bash
# Clone the repo
git clone <repo-url>
cd attendance_system

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run
```

---

## How It Works

1. **Enroll** — Tap "Enroll Face" on an employee card → face liveness scan runs → face ID is stored in memory and linked to the employee
2. **Check In** — Tap "Check In" → liveness scan verifies the face → attendance record is created with timestamp
3. **Check Out** — Tap "Check Out" → another liveness scan → shift is marked complete
4. **Dashboard** — Stats panel updates in real-time showing Present / Absent / Late counts

> Face ID registry is currently in-memory. For production use, replace with SharedPreferences or a local database.

---

## Dependencies

```yaml
dependencies:
  flutter_face_liveness: ^3.1.0 # Face liveness detection
  get: ^4.7.3 # State management & routing
```

---

## Screens

| Screen         | Description                                 |
| -------------- | ------------------------------------------- |
| Home Dashboard | Employee list with live attendance status   |
| Liveness Scan  | Camera-based face enrollment / verification |
| History / Logs | Chronological attendance record feed        |
