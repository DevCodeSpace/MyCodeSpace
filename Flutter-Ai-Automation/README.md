# Flutter AI Automation

> A collection of Flutter applications that explore practical AI-assisted workflows: live avatar conversations, restaurant ordering and printing, OMR sheet evaluation, and resume screening.

---

## Project Overview

This workspace brings together production-style Flutter apps focused on automation, AI integrations, responsive interfaces, and useful real-world workflows. Each app is self-contained and can be opened, configured, and run from its own project folder.

- **AI-powered workflows** - voice chat, document parsing, candidate screening, and answer-sheet evaluation.
- **Flutter-first delivery** - mobile and web-friendly codebases with Material UI, GetX state management, and responsive layouts.
- **API-backed automation** - REST, WebSocket, Firebase, WebRTC, file uploads, and printer bridge integrations.
- **Portfolio-ready documentation** - each project README explains the purpose, features, architecture, setup, and key dependencies.

---

## AI Avatar Chat - Gift Assistant

Live AI avatar assistant for gift discovery. Users speak with Ava, a real-time video avatar, while the app searches a gift catalog and renders shoppable recommendations.

<img src="Ai_Avatar/assets/images/govava_ai.png" alt="AI Avatar Gift Assistant" height="360" />

### Key Features

- **Real-time AI avatar** - Anam SDK powered WebRTC avatar video.
- **Voice conversation** - OpenAI Realtime WebSocket flow with microphone capture.
- **Tool calling** - AI-triggered `search_gifts` tool that fetches catalog results.
- **Gift recommendation UI** - shimmer loading, product cards, and detail bottom sheets.
- **Session lifecycle** - connect, disconnect, token refresh, mic gating, and call cleanup.

### Technical Highlights

- GetX controllers for session and gift-search state.
- Local Anam SDK package vendored under `packages/`.
- REST and WebSocket services split into clear modules.
- Dark, video-call inspired UI with responsive sizing.

Project README: [Ai_Avatar/README.md](Ai_Avatar/README.md)

---

## DineAssist AI - Restaurant Order System

Restaurant ordering app for table-based ordering, QR code access, bill generation, and thermal receipt printing through a Node.js print bridge.

<img src="Dineassist-Ai/assets/images/logo.png" alt="DineAssist AI" height="220" />

### Key Features

- **Table ordering workflow** - splash, table selection, menu browsing, and cart/order flow.
- **QR code generator** - create table/order access codes for restaurant usage.
- **Thermal printing** - ESC/POS printer support with native and web bridge services.
- **Web deployment path** - Flutter web build and Firebase deployment notes.
- **Network-aware printing** - WiFi scanning and local bridge URL configuration.

### Technical Highlights

- GetX routing, bindings, and controllers.
- REST service layer for restaurant data and order actions.
- Platform-specific printer services for native and web.
- Node.js bridge server for browser-to-printer communication.

Project README: [Dineassist-Ai/README.md](Dineassist-Ai/README.md)

---

## Smart OMR Evaluator

AI-assisted OMR checking tool for uploading scanned answer sheets, submitting an answer key, and reviewing evaluated results.

<img src="Smart_Omr_Evaluator/assets/images/logo.png" alt="Smart OMR Evaluator" height="220" />

### Key Features

- **Multi-file upload** - select multiple scanned OMR sheets.
- **Exam configuration** - enter exam name and answer-key JSON.
- **AI evaluation API** - uploads images to a backend for OMR result extraction.
- **Result display** - renders evaluated OMR responses after upload.
- **Modern UI** - animated upload states, icons, and responsive sections.

### Technical Highlights

- GetX controller for file selection, validation, upload, and result state.
- Dio-backed REST service.
- File picker support for image formats including JPG, PNG, WEBP, BMP, and HEIC.
- Flutter Animate and Lucide icons for polished interactions.

Project README: [Smart_Omr_Evaluator/README.md](Smart_Omr_Evaluator/README.md)

---

## AI Resume Screening System

Resume analysis tool that reads PDF resumes, extracts candidate details, sends structured candidate data to an AI service, and displays ranked screening results.

<img src="Ai_Resume_Screening_sSytem-Automation/assets/images/banner.png" alt="AI Resume Screening System" height="300" />

### Key Features

- **Bulk resume upload** - select multiple PDF resumes.
- **PDF text extraction** - parse candidate name, email, skills, and experience.
- **AI screening API** - submit normalized candidate data for analysis.
- **Candidate result cards** - show analysis results in a modern dashboard.
- **Animated interface** - immersive header, upload state, and result transitions.

### Technical Highlights

- Syncfusion PDF extraction for local resume parsing.
- GetX state management for selected files, loading state, and results.
- Dio service layer for backend analysis.
- Percent indicators and modern candidate cards for score visualization.

Project README: [Ai_Resume_Screening_sSytem-Automation/README.md](Ai_Resume_Screening_sSytem-Automation/README.md)

---

## Workspace Setup

Each project is a separate Flutter app. Run commands from the specific project folder:

```bash
cd <project-folder>
flutter pub get
flutter run
```

Recommended quality checks:

```bash
flutter analyze
flutter test
dart format .
```

---

## Projects At A Glance

| Project | Main Focus | Notable Integrations |
|---|---|---|
| `Ai_Avatar` | AI video avatar gift assistant | OpenAI Realtime, Anam SDK, WebRTC, REST |
| `Dineassist-Ai` | Restaurant ordering and printing | Firebase, QR, ESC/POS, Node print bridge |
| `Smart_Omr_Evaluator` | OMR answer-sheet evaluation | File upload, Dio API, image picking |
| `Ai_Resume_Screening_sSytem-Automation` | Resume screening automation | PDF parsing, AI API, result scoring |

---

Built with Flutter by DevCodeSpace.
