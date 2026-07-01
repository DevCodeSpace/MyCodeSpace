# ⏳ Stay On Track — Digital Wellbeing

A Flutter digital-wellbeing app that tracks how much time you spend in each installed app, visualizes usage trends, and lets you set daily limits with gentle on-screen nudges when you're overdoing it.

<p align="center">
  <img src="assets/logo.png" alt="Stay On Track" height="120" />
</p>

## ✨ Key Features

- 📊 **Usage Dashboard** — Daily/weekly screen-time breakdown with interactive charts (`fl_chart`)
- 📱 **Installed Apps Overview** — Lists all installed apps with per-app usage stats (`installed_apps`, `usage_stats`)
- ⏱️ **App Time Limits** — Set a daily usage cap per app and get alerted when it's reached
- 🚨 **Limit-Reached Overlay** — A system-level overlay (`flutter_overlay_window`) interrupts the app when its limit is hit, even while running in the background
- 🔔 **Background Tracking** — Usage monitoring continues via a background service (`flutter_background_service`) with local notifications
- 🧭 **Onboarding Flow** — Guided first-run setup requesting the necessary usage-access permissions
- 📈 **Deep-Dive Analytics** — Drill into a single app's historical usage trend

## 🛠️ Tech Stack

| Layer            | Technology                                    |
| ---------------- | -----------------------------------------------|
| Framework        | Flutter                                        |
| State Management | GetX                                            |
| Usage Stats      | `usage_stats`, `installed_apps`                 |
| Charts           | `fl_chart`                                       |
| Background Work  | `flutter_background_service`, `flutter_overlay_window` |
| Notifications    | `flutter_local_notifications`                     |
| Storage          | `shared_preferences`                               |
| UI               | `google_fonts`                                      |

## 📁 Project Structure

```
lib/
├── core/
│   ├── models/
│   ├── theme/
│   ├── routes/
│   ├── services/
│   └── widgets/
└── features/
    ├── splash/
    ├── onboarding/           # Permission request flow
    ├── dashboard/             # Usage summary & charts
    ├── apps/
    │   ├── installed_apps_view.dart
    │   ├── app_details_view.dart
    │   ├── set_limit_view.dart
    │   ├── active_limits_view.dart
    │   └── limit_reached_alert_view.dart
    ├── analytics/
    │   └── analytics_deep_dive_view.dart
    └── settings/
```

Note: this project vendors patched copies of `usage_stats` and `flutter_overlay_window` under `third_party/`, referenced via `dependency_overrides` in `pubspec.yaml`.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- A physical Android device (usage-stats and overlay APIs are Android-only and largely unsupported on emulators/other platforms)

### Installation

```bash
flutter pub get
flutter run
```

### Usage

1. Complete onboarding and grant **Usage Access** and **Display over other apps** permissions when prompted.
2. Browse the **Dashboard** for an at-a-glance view of today's screen time by app.
3. Open an app's detail view to set a **daily time limit**.
4. When the limit is reached, an overlay alert appears on top of that app to remind you to take a break.

## 📌 Notes

- Accurate usage tracking depends entirely on Android's `UsageStatsManager`, which requires the user to manually grant Usage Access in system settings.
