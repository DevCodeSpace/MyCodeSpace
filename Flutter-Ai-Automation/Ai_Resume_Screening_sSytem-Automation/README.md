# AI Resume Screening System

Flutter app for bulk resume screening. It extracts candidate data from PDF resumes, sends normalized candidate profiles to an AI analysis API, and displays screening results in modern candidate cards.

<img src="assets/images/banner.png" alt="AI Resume Screening banner" height="300" />

## Features

- **Bulk PDF upload** - select multiple resumes in one flow.
- **Local PDF parsing** - extract text from PDF files before calling the API.
- **Candidate extraction** - parse name, email, skills, and experience from resume text.
- **AI analysis API** - submit structured candidate data for screening.
- **Screening results** - render analyzed candidates with polished result cards.
- **Animated dashboard** - immersive banner, upload state, and result transitions.

## Architecture

```text
lib/
├── main.dart
├── controller/
│   └── resume_controller.dart
├── model/
│   └── resume_result_model.dart
├── services/
│   └── resume_api_service.dart
└── views/
    ├── resume_screen.dart
    ├── splash_screen.dart
    └── widgets/
        └── modern_card.dart
```

### Flow

1. User selects multiple PDF resumes.
2. `ResumeController` reads file bytes and extracts text with Syncfusion PDF tools.
3. The controller parses candidate name, email, skills, and experience.
4. Candidate payloads are sent to `ResumeApiService`.
5. API responses become `ResumeResultModel` objects and display in result cards.

## Getting Started

### Prerequisites

- Flutter SDK with Dart `^3.11.5`
- Android Studio or Xcode for mobile builds
- Access to the configured resume analysis backend

### Run Locally

```bash
flutter pub get
flutter run
```

## Key Dependencies

| Package | Purpose |
|---|---|
| `get` | State management and dependency injection |
| `dio` | API communication |
| `file_picker` | PDF selection |
| `syncfusion_flutter_pdf` | PDF text extraction |
| `percent_indicator` | Score/progress visualization |
| `flutter_animate` | UI animation |
| `font_awesome_flutter` | Icons |
| `google_fonts` | Typography |

## Quality

```bash
flutter analyze
flutter test
dart format .
```

## Notes

- Resume parsing uses heuristics and may need tuning for highly custom PDF layouts.
- The project is private (`publish_to: none`).
