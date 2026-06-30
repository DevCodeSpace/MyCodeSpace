# AI Avatar Chat — Project Context

> **Last updated:** 2026-06-03  
> **Flutter SDK:** 3.x (Dart 3)  
> **State management:** GetX (GetxController / Obx / Rx*)  
> **Architecture:** MVC — Models parse JSON, Views render UI only, Controllers hold all logic and state

---

## What this app does

Single-screen gift-suggestion chatbot powered by a real-time AI avatar (Ava).  
The user taps **Start Chat**, speaks naturally, and the AI:

1. Introduces itself and asks who the gift is for.
2. Asks follow-up questions (age, occasion, lifestyle).
3. Calls `search_gifts` → gift cards populate the entire lower screen real estate.
4. Ends the conversation with a farewell.

---

## Folder structure

```
ai_avtar_chat/
├── lib/
│   ├── main.dart                            App entry — opens AvatarChatScreen directly
│   ├── configuration/
│   │   └── app_configuration.dart           Shared text styles, checkConnection(), loadingDialog()
│   ├── controller/
│   │   ├── chatbot/
│   │   │   └── conversation_controller.dart Gift-search state; calls real keyword search API
│   │   ├── dashboard/
│   │   │   └── bottom_controller.dart       Tab index + PageController for DashboardScreen
│   │   └── real_time_ai/
│   │       └── realtime_ws.dart             OpenAI Realtime WebSocket client
│   ├── core/
│   │   ├── helpers/
│   │   │   ├── api_logger.dart              Logs HTTP calls (method, status, body)
│   │   │   ├── routes.dart                  GetPage route registry (2 active routes)
│   │   │   └── settings.dart               SharedPreferences wrapper (static getters/setters)
│   │   └── utils/
│   │       └── import_to_export.dart        Barrel — import this file everywhere
│   ├── model/
│   │   ├── assistant/
│   │   │   └── assistant_start_response.dart  Parses /customer/assistant/start response
│   │   └── gift_search/
│   │       └── gift_card_keyword_search_model.dart  Input + response models for keyword search API
│   ├── modules/
│   │   ├── assistant/
│   │   │   └── assistant_controller.dart    Full AI session lifecycle (WebSocket, Anam, mic)
│   │   ├── authentication/
│   │   │   ├── login/model/login_response_model.dart
│   │   │   └── signin/
│   │   │       ├── controller/signin_controller.dart
│   │   │       └── view/signin.dart
│   │   ├── avatar_chat/
│   │   │   └── view/avatar_chat_screen.dart  Main gift-chat UI (dark navy/violet theme)
│   │   ├── components/
│   │   │   ├── fields/email.dart / password.dart
│   │   │   └── widgets/btn.dart / fga.dart / popup.dart
│   │   ├── dashboard/
│   │   │   └── view/dashboard_screen.dart
│   │   └── home/
│   │       ├── controller/home_controller.dart
│   │       └── view/home_screen.dart
│   └── services/
│       ├── real_time_conversation.dart      HTTP wrappers for assistant session endpoints
│       ├── rest_services.dart               Generic REST helpers
│       └── service_config.dart             All endpoint path constants
└── packages/
    └── anam_flutter_sdk-0.1.0/             Local Anam WebRTC avatar SDK
```

---

## App boot flow

```
main()
  └─ Settings.init()          — load SharedPreferences
  └─ ScreenUtilInit           — responsive sizing (design canvas: 375×812)
       └─ GetMaterialApp
            ├─ initialBinding — AssistantController + ConversationController (lazy, global)
            └─ home: AvatarChatScreen
```

---

## AvatarChatScreen layout (top → bottom)

| Zone | Widget | Description |
|---|---|---|
| Header | `_Header` | App icon, "Gift Assistant" title, status label, green "Live" pill |
| Avatar | `_AvatarPanel` | 210 px card — pulsing placeholder → spinner → live `AnamAvatarView` |
| Gift cards | `_GiftCardsGrid` | Full-screen grid of `_GiftCard` entries. Clickable to open details sheet. |
| Action bar | `_ActionBar` | "Start Chat" gradient button **or** End + Mic toggle when live |

Theme: deep-space navy `#0D0D1A` + indigo-violet `#6C3CE1`/`#9B6DFF`. No bottom navigation.

---

## Gift search flow (two triggers)

### 1 — AI tool call (primary)
```
AI speaks → calls search_gifts("query")
  → _searchGiftsCallback()
  → ConversationController.searchKeyWord(query)
  → giftProducts populated
  → _GiftCardsRow renders
```

### 2 — Client-side keyword fallback (secondary)
When the AI's `search_gifts` tool is not triggered (e.g. user directly names a product):
```
user transcript finalised
  → _clientSideGiftSearchFallback(text)
  → skip if: giftProducts not empty OR AI hasn't spoken yet
  → match text against _giftProductKeywords (watch, headphone, perfume, …)
  → fires searchKeyWord(text) immediately
```

`search_gifts` is **always registered** — from `data.tools` first, then a hardcoded fallback
if the backend omits it. Both paths use the same `_searchGiftsCallback`.

---

## Key controllers

### AssistantController
`lib/modules/assistant/assistant_controller.dart`

| Concern | Detail |
|---|---|
| Session start | `startAssistant(context, {showOverlay})` → `/customer/assistant/start` → Anam + OpenAI in parallel |
| Mic | PCM16 @ 24 kHz via `record`; gated by `_isAssistantSpeaking` to prevent echo feedback |
| OpenAI Realtime | `RealtimeWS` WebSocket; session includes `language: en` so Whisper always returns English |
| Anam WebRTC | `AnamClient.talk()` streams avatar video to `RTCVideoRenderer` |
| Tools | `_searchGiftsCallback` + `_endConversationCallback`; hardcoded fallbacks guarantee registration |
| Cooldown | 3-minute cooldown enforced via `Settings.lastChatBotTime` |
| Cleanup | `finalizeAndClose(reason)` → `disposeSession()` — tears down WS, WebRTC, mic, overlay |

### ConversationController
`lib/controller/chatbot/conversation_controller.dart`

| Field | Type | Purpose |
|---|---|---|
| `giftProducts` | `RxList<GiftItem>` | Rendered as gift cards; populated by `searchKeyWord` |
| `isFetching` | `RxBool` | Guards against duplicate in-flight fetches |
| `searchQurery` | `RxString` | Last query string |
| `totalPage` | `RxInt` | Total pages from the API (for future load-more) |

`searchKeyWord(query)` calls **`RestService.giftKeyWordSearch()`** with the AI query. The `GiftCardKeywordSearchInputModel` is built with `keyword`, `page`, and `countryCode: "US"`. The response `List<GiftItem>` is assigned directly to `giftProducts`. Presentation logic (price formatting, emojis) is now handled by getters within the `GiftItem` model itself.

### RealtimeWS
`lib/controller/real_time_ai/realtime_ws.dart`

Thin WebSocket client for the OpenAI Realtime API:
- `sendSessionUpdate` — configures PCM16 24 kHz audio, server VAD (threshold: 0.8), registered tools, multilingual transcription
- `appendInputAudio` — streams raw PCM chunks from the mic
- Dispatches: audio delta/done, `speech_started`, assistant/user transcripts, tool calls, `response.done`

---

## API endpoints  
Base URL: `https://core-api.govava.com`

| Endpoint | Method | Purpose |
|---|---|---|
| `/customer/assistant/start` | POST | Start session → ephemeral token, avatar ID, tools, system prompt |
| `/customer/assistant/refresh/{id}` | POST | Refresh ephemeral token before expiry |
| `/customer/assistant/context/{id}` | POST | Save running transcript / finalise session |
| `/customer/assistant/memory` | GET | Fetch AI memory snapshot |
| `/customer/search/keyword_search` | POST | Search products by keyword — body: `{keyword, page, countryCode, category?, type?}` |

### Keyword Search Request/Response
- **Input:** `GiftCardKeywordSearchInputModel` (keyword, page, countryCode)
- **Response:** `GiftCardKeywordSearchResponseModel` → `GiftKeywordResponse` → `List<GiftItem>`
- **GiftItem actual API field names (verified 2026-06-03):**
  - `productname` (lowercase n) → mapped to `productName`
  - `imageurl` (all lowercase, single string) → wrapped in `productImages` list
  - `price` / `saleprice` → mapped to `price`; formatted by `_formatPrice()` ("18.0" → "$18")
  - `category` is an **object** `{primary, secondary}` → `primary` value → `categoryName`
  - `productId` is a **string** like "etsy-1484215870" (not int)
- **Pagination:** The actual API response does NOT return `TotalMatches`, `TotalPages`, or `PageNumber` in the `response` object. The API returns up to 60 items per page (`size: 60` in `serverless_body`). Pagination fields in `GiftKeywordResponse` remain null and default to page 1.
- **Caller:** `RestService.giftKeyWordSearch()` in `lib/services/rest_services.dart`

---

## Theme & Documentation Architecture (2026-06-03)

We implemented a centralized theming architecture to avoid scattered hex codes and font initializers:
- `lib/core/theme/app_colors.dart` establishes the unified palette (Govava reds, deep-space navies, alerts).
- `lib/core/theme/app_text_styles.dart` replaces individual `GoogleFonts.poppins` calls by abstracting standard weights (`regular`, `medium`, `semiBold`, `bold`).

Extensive inline English comments have been added to core components (`RestService`, `RealTimeConversationServices`, `BottomController`, and `ConversationController`) outlining state management hooks, API logic flows, and pagination constraints. 

All older text styling definitions inside `app_configuration.dart` have been deprecated and internally routed to `AppTextStyles` functions. `HomeScreen` and `AvatarChatScreen` fully embrace this approach.

---

## Multilingual support & VAD tuning (2026-06-03)

Removed the hardcoded `language: 'en'` constraint to allow users to speak in Hindi,
Gujarati, and other languages naturally. The LLM handles cross-lingual translation
internally and issues English `search_gifts` queries regardless of input language.

Server VAD `threshold` was increased to `0.8` (from 0.5) and `silence_duration_ms`
to `1000` to prevent Whisper from hallucinating words (like "Thank you") on background
noise, which previously caused the AI to receive garbage input and close the session.
The mic gate now tracks exact AI audio byte duration to perfectly block speaker echo.

---

## Language enforcement fix (2026-06-03)

AI was responding in whatever language the user spoke — including from the very
first message — causing mixed-language sessions (user in Hebrew, AI in Gujarati).

Fixed by prepending a client-side language rule via `_withLanguageInstruction()` in
`AssistantController` before passing the system prompt to `RealtimeWS.connect()`:

```
LANGUAGE RULE: Always respond in English by default. Only switch to a different
language if the user EXPLICITLY requests it. Remember the chosen language for the
rest of the session once they ask for a switch.
```

The rule is prepended in both `_connectAndConfigureOpenAI` and `_reconnectOpenAI`
so it survives token refreshes mid-session. Transcription remains multilingual
(no `language: 'en'`) so users can speak in their native language and be understood.

---

## Gift search field-name fix (2026-06-03)

`GiftItem.fromJson()` was using assumed camelCase field names that don't match the
real `/customer/search/keyword_search` response. Corrected field mapping:

| Wrong (assumed) | Correct (actual API) |
|---|---|
| `productName` | `productname` (lowercase n) |
| `productImages` / `productImage` | `imageurl` (all lowercase, single string) |
| `minPrice` | `price` (top-level field, string or number) |
| `category` (string) | `category.primary` (nested object `{primary, secondary}`) |
| `productId` (int) | `productId` (string like "etsy-1484215870") |

`_formatPrice()` in `ConversationController` now strips trailing ".0" so "18.0"
displays as "$18" instead of "$18.0". `productId` field type changed to `String?`.

---

## Coding conventions

| Rule | Detail |
|---|---|
| Color opacity | `.withValues(alpha: x)` — not `.withOpacity()` |
| SVG tint | `colorFilter: ColorFilter.mode(...)` — not `.color` on SvgPicture |
| Pop scope | `onPopInvokedWithResult` — not `onPopInvoked` |
| Comments | Inline English on every class, method, and non-obvious variable |
| Logic | No business logic in View files — controllers only |
| Imports | Barrel via `lib/core/utils/import_to_export.dart` |
| Function names | `customNetworkDialog()` lowerCamelCase (Dart top-level functions) |

---

## Known TODOs

| File | TODO |
|---|---|
| `home_controller.dart` | Replace mock trending products with real API |
| Dashboard tabs | Browse, Favourites, Account screens are placeholders |
| Auth flow | App opens directly to `AvatarChatScreen`; sign-in not yet wired |
| `conversation_controller.dart` | Add load-more pagination (page > 1) when user scrolls gift cards |

---

## UI updates & Chat removal (Latest Changes)

- The real-time visual chat transcript (`_ChatArea` and `_Bubble`) has been removed entirely from `AvatarChatScreen` to focus purely on the voice avatar interaction.
- `_GiftCardsRow` was converted to `_GiftCardsGrid` using `GridView.builder` wrapped in an `Expanded` widget, allowing suggested gifts to fill the remaining screen space.
- When a user presses **Start Chat** to begin a new session, `ConversationController.giftProducts` is immediately cleared (`.clear()`) so previous search results disappear from the UI.

---

## Model-Driven UI Refactoring (Latest Change)

- Refactored the gift product handling to be strongly-typed for better code safety and readability.
- `ConversationController.giftProducts` is now `RxList<GiftItem>` instead of `RxList<Map<String, dynamic>>`.
- The manual `_itemToProductMap` logic was removed from the controller.
- Presentation logic (e.g., price formatting, category-based emoji) has been encapsulated as getters (`formattedPrice`, `emoji`, `imageUrl`) within the `GiftItem` model itself.
- `AvatarChatScreen`'s `_GiftCard` widget now directly consumes a `GiftItem` object, preventing potential runtime errors from typos in map keys.

---

## Product Details & Grid UI Refinements (Latest Change)

- Added interactivity to `_GiftCard` grid items; tapping them now calls `_showProductDetails()`.
- Implemented a customized, dark-themed `showModalBottomSheet` for product details, displaying the product image, title, price pill, and a gradient "Buy Now" button.
- Removed old external branding references. The modal description strictly uses the branding **"AI Avatar Chat"**.
- Re-aligned padding, borders, and drop shadows in the grid cards for a more premium, card-like feel.
