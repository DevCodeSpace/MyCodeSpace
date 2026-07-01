# 📍 GeoSentry (GeoGuard)

A Flutter geofencing app that lets you draw virtual zones on a map and get notified the moment you (or a tracked device) enters or exits them — great for reminders, safety alerts, or location-based automation.

## ✨ Key Features

- 🗺️ **Interactive Map** — Browse and manage zones directly on a `google_maps_flutter` map
- 🎯 **Custom Geofence Zones** — Create, edit, and delete circular geofences with adjustable radius via an intuitive bottom sheet
- 🔔 **Enter / Exit Notifications** — Local push notifications fire automatically when a zone boundary is crossed (`flutter_local_notifications`)
- ⚙️ **Background Monitoring** — Location tracking continues even when the app isn't in the foreground (`flutter_background_service`)
- 📜 **Event Log** — Chronological history of every zone entry/exit event
- 📌 **Reverse Geocoding** — Converts coordinates into readable addresses (`geocoding`)
- 🎨 **Status Indicators & Animations** — Live status pills and smooth transitions (`flutter_animate`, `shimmer`)

## 🛠️ Tech Stack

| Layer            | Technology                                                    |
| ---------------- | ----------------------------------------------------------------|
| Framework        | Flutter                                                          |
| State Management | Provider                                                         |
| Maps             | `google_maps_flutter`                                            |
| Location         | `geolocator`, `geocoding`                                        |
| Notifications    | `flutter_local_notifications`                                    |
| Background Work  | `flutter_background_service`                                     |
| Permissions      | `permission_handler`                                              |
| Storage          | `shared_preferences`                                              |

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point, bottom-nav shell
├── theme.dart                  # App-wide theming
├── geofence_model.dart          # Geofence zone data model
├── geofence_service.dart        # Core geofencing logic (ChangeNotifier)
├── map_screen.dart               # Map view with zone overlays
├── zones_screen.dart             # List/manage saved zones
├── geofence_bottomsheet.dart      # Create-zone bottom sheet
├── edit_geofence_sheet.dart       # Edit-zone bottom sheet
├── events_screen.dart             # Entry/exit event history
└── status_pill.dart                # Reusable live-status indicator widget
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK installed
- A Google Maps API key configured for Android/iOS
- Android/iOS device or emulator with location services enabled

### Installation

```bash
flutter pub get
flutter run
```

### Usage

1. Open the **Map** tab and long-press (or use the add button) to drop a new geofence zone.
2. Adjust the zone's radius and name it from the bottom sheet, then save.
3. Grant location permission — including "Allow all the time" for background monitoring.
4. Receive a local notification whenever you enter or exit a saved zone.
5. Check the **Events** tab for a full history of crossings.

## 📌 Notes

- Background location tracking requires "Always allow" location permission on both Android and iOS.
- Battery usage may increase while background monitoring is active, depending on OS-level location update frequency.
