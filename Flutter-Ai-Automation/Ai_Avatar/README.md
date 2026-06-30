# AI Avatar Chat - Gift Assistant

A Flutter app where users have a live, face-to-face voice conversation with **Ava**, a real-time AI video avatar, to get personalised gift recommendations. Ava listens, talks back on video, searches the Govava gift catalog mid-conversation, and renders shoppable gift cards right below the video panel.

<img src="assets/images/govava_ai.png" alt="AI Avatar Gift Assistant" height="360" />

## ✨ Features

- **Live AI video avatar** — real-time talking avatar streamed over WebRTC via the [Anam SDK](packages/anam_flutter_sdk-0.1.0/).
- **Voice conversation** — speech in / speech out powered by the OpenAI Realtime API over WebSocket, with mic gating to avoid the avatar hearing its own voice.
- **AI tool calling** — the model invokes a `search_gifts` tool during conversation; results are fetched from the Govava keyword-search API and shown as a gift grid.
- **Gift cards & details** — responsive 2-column gift grid with shimmer loading skeletons, plus a rich product details bottom sheet with a Buy Now flow.
- **Session lifecycle handling** — connect/disconnect states, ephemeral token refresh, conversation context persistence, and graceful end-of-call detection.
- **Polished dark UI** — custom deep-navy/violet theme, video-call style mic & end-call controls, animated idle states.

## 📱 Main Screen

The whole app is a single screen ([avatar_chat_screen.dart](lib/modules/assistant/view/avatar_chat_screen.dart)), laid out top to bottom:

1. **Header** — app icon, status line (Connecting… / Loading avatar… / Ask me anything!), and a "Live" pill while connected.
2. **Avatar panel** — Anam WebRTC video when streaming; pulsing placeholder or spinner otherwise.
3. **Gift area** — how-it-works card when idle, hint while chatting, shimmer skeletons while searching, gift grid when results arrive.
4. **Action bar** — gradient "Start Chat" button when idle; circular Mic / End call controls during a session.

## 🏗 Architecture

```
lib/
├── main.dart                          # App entry — GetX bindings, theme, ScreenUtil
├── configuration/
│   └── app_configuration.dart         # Shared text styles, connectivity check, dialogs
├── core/
│   ├── helpers/                       # Settings (SharedPreferences), API logger
│   ├── utils/import_to_export.dart    # Barrel file for common imports
│   └── widgets/popup.dart             # Reusable popups
├── services/
│   ├── service_config.dart            # Base URL + endpoint path constants
│   ├── rest_services.dart             # Govava REST client (keyword search etc.)
│   └── real_time_conversation.dart    # /customer/assistant/* session APIs
└── modules/assistant/
    ├── controller/
    │   ├── assistant_controller.dart  # Session lifecycle, mic capture, Anam + OpenAI wiring
    │   ├── conversation_controller.dart # Gift search state shared with the UI
    │   └── realtime_ws.dart           # OpenAI Realtime WebSocket client + tool dispatch
    ├── model/                         # API response models
    └── view/
        └── avatar_chat_screen.dart    # The single chat screen UI

packages/
└── anam_flutter_sdk-0.1.0/            # Local Anam SDK (WebRTC avatar streaming)
```

### Session flow

1. **Start Chat** → `POST /customer/assistant/start` returns session metadata: Anam session token, ephemeral OpenAI realtime token, system prompt, and tool definitions.
2. [AssistantController](lib/modules/assistant/controller/assistant_controller.dart) connects:
   - the **Anam SDK** (WebRTC) to stream the avatar's video/audio into the avatar panel, and
   - the **OpenAI Realtime WebSocket** ([realtime_ws.dart](lib/modules/assistant/controller/realtime_ws.dart)) for the voice conversation.
3. Mic audio is captured with the `record` package and streamed to OpenAI; assistant speech is voiced through the avatar.
4. When the model calls the **`search_gifts`** tool, [ConversationController](lib/modules/assistant/controller/conversation_controller.dart) hits `POST /customer/search/keyword_search` and populates the gift grid.
5. Ending the call (user tap, timeout, or detected closing phrase) finalises the conversation context on the backend and tears down both connections.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK **3.41+** (Dart SDK `^3.11.4`)
- Xcode (iOS) / Android Studio (Android)
- A device or emulator with microphone access

### Setup & Run

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app
flutter run
```

The Anam SDK is vendored as a local path package at [packages/anam_flutter_sdk-0.1.0](packages/anam_flutter_sdk-0.1.0/), so no extra setup is needed for it.

### Configuration

API hosts and endpoint paths live in [lib/services/service_config.dart](lib/services/service_config.dart):

```dart
static const String baseUrl = "https://core-api.govava.com";   // production
// static const String baseUrl = "https://api.govava.smart-maple.com"; // staging
```

Swap the `baseUrl` to point the app at staging for local testing.

### Permissions

The app requests **microphone** permission at session start (via `permission_handler`). The screen is kept awake during a call with `wakelock_plus`.

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `get` | State management, routing, dependency injection |
| `anam_flutter_sdk` (local) | Real-time avatar video over WebRTC |
| `flutter_webrtc` | WebRTC engine used by the Anam SDK |
| `web_socket_channel` | OpenAI Realtime API connection |
| `record` | Microphone PCM capture for speech input |
| `http` | REST calls to the Govava backend |
| `permission_handler` | Mic permission flow |
| `wakelock_plus` | Keep screen on during a live session |
| `google_fonts` | Poppins typography |
| `flutter_screenutil` | Responsive sizing |
| `shared_preferences` | Auth token / settings persistence |
| `connectivity_plus` | Network status checks |

## 🧪 Quality

```bash
flutter analyze   # static analysis (flutter_lints)
flutter test      # unit/widget tests
dart format .     # formatting
```

## 📄 Notes

- The project is private (`publish_to: none`).
- Supported platforms: Android, iOS (desktop/web folders exist but the avatar flow targets mobile).
