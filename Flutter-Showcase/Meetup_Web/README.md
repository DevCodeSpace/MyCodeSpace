# Pure WebRTC Video Calling

This Flutter project demonstrates a complete 1-to-1 video calling system using Pure WebRTC and Firestore-based signaling.

## Project Structure

- `lib/main.dart` — App entrypoint and routing.
- `lib/screens/` — Home, CreateMeeting, JoinMeeting, and Call screens.
- `lib/services/` — `WebRTCService` and `FirebaseSignalingService`.

## Features

- Create meeting room
- Generate unique room ID
- Copy meeting URL
- Join meeting by ID or URL
- Local and remote video views
- Mute/unmute microphone
- Enable/disable camera
- Switch front/back camera
- Leave meeting
- Supports Android, iOS, and Web

## Setup Instructions

### 1. Install Flutter dependencies

From the Flutter project root:

```bash
flutter pub get
```

### 2. Configure Firebase

This app uses Firestore for signaling, so you must configure Firebase for your platforms.

- `lib/firebase_options.dart` contains the Firebase configuration for Android, iOS, and Web.
- Ensure Firestore is enabled and the Firebase config values match your project.

### 3. Run the Flutter app

```bash
flutter run
```

For web:

```bash
flutter run -d chrome
```

### 4. Use the app

1. Tap **Create Meeting** to generate a room ID.
2. Copy the meeting URL or room ID.
3. Open the same room ID in a second device or browser.
4. Start a 1-to-1 WebRTC call.

## WebRTC Signaling Flow

1. A user joins a room by creating or opening a Firestore room document.
2. The first participant becomes the caller and waits for the second peer.
3. The second participant becomes the callee and reads the caller's offer from Firestore.
4. The callee sends an answer back to Firestore.
5. Both peers exchange ICE candidates through Firestore subcollections.
6. Once the peer connection is established, local and remote video streams connect directly.

## Permissions

- Android: `CAMERA`, `RECORD_AUDIO`, `INTERNET`
- iOS: `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`
- Web: browser permission requests are handled automatically by the browser

## Notes

- This example uses `flutter_webrtc` and `cloud_firestore`.
- No third-party video SDKs like Agora, Twilio, Jitsi, or Daily are used.
