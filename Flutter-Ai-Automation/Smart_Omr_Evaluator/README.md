# Smart OMR Evaluator

AI-assisted Flutter app for evaluating scanned OMR answer sheets. Users configure an exam, provide an answer key as JSON, upload multiple scanned sheets, and receive evaluated results from the backend.

<img src="assets/images/logo.png" alt="Smart OMR Evaluator logo" height="220" />

## Features

- **Exam setup** - enter an exam name and editable answer-key JSON.
- **Multi-image upload** - select one or more OMR sheet images.
- **Add/remove sheets** - manage selected files before submission.
- **Backend evaluation** - upload scanned sheets to an OMR checking API.
- **Result rendering** - show evaluated OMR responses in the app.
- **Modern interface** - animated upload area, Lucide icons, and polished light theme.

## Supported Upload Formats

- JPG / JPEG
- PNG
- WEBP
- BMP
- HEIC

## Architecture

```text
lib/
├── main.dart
├── configuration/
│   └── rest_service.dart
├── controller/
│   └── omr_controller.dart
├── model/
│   └── omr_result_model.dart
└── view/
    ├── orm_upload_screen.dart
    └── splash_screen.dart
```

### Flow

1. User enters the exam name and answer key.
2. User selects scanned OMR sheet images.
3. `OmrController` validates input and sends files to `OmrApiService`.
4. API results are parsed into `OMRResultResponse` models.
5. The result section updates reactively through GetX.

## Getting Started

### Prerequisites

- Flutter SDK with Dart `^3.11.5`
- Android Studio or Xcode for mobile builds
- Access to the configured OMR evaluation backend

### Run Locally

```bash
flutter pub get
flutter run
```

## Key Dependencies

| Package | Purpose |
|---|---|
| `get` | State management and dependency injection |
| `dio` | API calls and upload handling |
| `file_picker` | Multi-file image selection |
| `flutter_animate` | Entrance and interaction animations |
| `lucide_icons` | UI icon set |
| `google_fonts` | Typography |

## Quality

```bash
flutter analyze
flutter test
dart format .
```

## Notes

- The default answer key in `OmrController` is sample data and should be replaced for real exams.
- The project is private (`publish_to: none`).
