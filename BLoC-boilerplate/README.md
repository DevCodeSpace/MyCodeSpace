# BloC-boilerplate

A simple and well-structured boilerplate for using the BLoC (Business Logic Component) pattern in Flutter projects. This boilerplate is designed to help you kickstart your Flutter application with the Bloc pattern quickly and efficiently.

## Introduction

This boilerplate provides a solid foundation for implementing the Bloc pattern in your Flutter projects. It follows best practices and aims to simplify the management of state and business logic in your application, ensuring a clean and scalable codebase.


## Features

- Clean and scalable architecture using the Bloc pattern
- Well-organized folder structure
- Pre-configured dependencies
- Ready-to-use examples and templates
- Easy integration with new and existing Flutter projects
- Built-in support for API calls using the http package


## Folder Structre
Here's an overview of the folder structure used in this boilerplate:
```
lib/
├── const/                              # Contains constant values and theme data
│   └── primary_theme.dart              # Primary theme settings for the app
├── cubit/                              # Contains Cubits for state management
│   └── login_cubit.dart                # Cubit for handling login logic
├── helper/                             # Helper functions and utilities
│   ├── routes.dart                     # Application routes
│   └── settings.dart                   # Application settings and configurations
├── model/                              # Data models
│   └── response_model.dart             # Model for handling API responses
├── screens/                            # UI screens of the application
│   ├── home_screen.dart                # Home screen UI
│   └── login_screen.dart               # Login screen UI
├── services/                           # Service classes for business logic and data handling
│   └── http_caller.dart                # Service for making API calls
├── state/                              # Classes related to form validation and other state management
│   └── form_validate_state.dart        # State management for form validation
├── widget/                             # Reusable widgets
│   ├── error_message_box_widget.dart   # Widget for displaying error messages
│   ├── primary_button_widget.dart      # Widget for primary buttons
│   └── primary_textfield_widget.dart   # Widget for primary text fields
└── main.dart                           # Entry point of the application                          
```

## Getting Started

To get started with this boilerplate, you need to have Flutter installed on your system. If you don't have it installed yet, follow the official Flutter installation guide here.

## Installation

Clone the repository:
```
git clone https://github.com/DevCodeSpace/MyCodeSpace/BloC-boilerplate
```

### Install dependencies:
```
flutter pub get
```
### Run the application:
```
flutter run
```

## Usage

### Adding a New Cubit

To add a new Cubit, follow these steps:

**Step 1: Create a New State**

- Navigate to the `lib/state/` directory.
- Create a new Dart file named after the feature (e.g., `feature_state.dart`).
- Implement the State class along with the necessary states.

```dart 
import 'package:bloc/bloc.dart';

// Define states
class FeatureState {}

class FeatureInitial extends FeatureState {}

class FeatureLoaded extends FeatureState {
  final String data;
  FeatureLoaded(this.data);
}
```

**Step 1: Create a New Cubit**

- Navigate to the `lib/cubit/` directory.
- Create a new Dart file named after the feature (e.g., `feature_cubit.dart`).
- Implement the Cubit class along with the necessary methods.

**Example:**

```dart
// lib/cubit/feature_cubit.dart

import 'package:bloc/bloc.dart';

// Define Cubit
class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit() : super(FeatureInitial());

  void loadFeatureData() {
    // Your logic here
    emit(FeatureLoaded("Data Loaded"));
  }
}
```

**Step 3 :-**  Create or Update a Screen:

- Navigate to the `lib/screens/` directory.

- If necessary, create a new screen Dart file or update an existing one.

- Inject the newly created Cubit using the BlocProvider or CubitProvider widget, depending on your state management needs.

- Use CubitBuilder or BlocBuilder to react to state changes within the UI.

**Example:**

```dart
// lib/screens/feature_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_boiler_plate/cubit/feature_cubit.dart';

class FeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FeatureCubit(),
      child: Scaffold(
        appBar: AppBar(title: Text('Feature Screen')),
        body: BlocBuilder<FeatureCubit, FeatureState>(
          builder: (context, state) {
            if (state is FeatureInitial) {
              return Center(child: Text('Press the button to load data'));
            } else if (state is FeatureLoaded) {
              return Center(child: Text(state.data));
            }
            return Container();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.read<FeatureCubit>().loadFeatureData(),
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }
}
```

**Step 4 :-**  Define Routes:

- Update the `/helper/routes.dart` file to include a route for the new screen, if applicable.
**Example:**

```dart
// lib/cubit/feature_cubit.dart

import 'package:bloc_boiler_plate/screens/feature_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String login = '/feature';

  static Map<String, Widget Function(BuildContext)> get routes {
    return {
      Routes.login: (context) => const FeatureScreen(),
    };
  }
}
```

**Step 5 :-**  Modify or Create Widgets:

- If you need custom widgets for your new feature, navigate to the `lib/widget/` directory.

- Create a new Dart file for the widget or update existing ones.

- Reuse existing widgets where applicable to maintain consistency.

**Example:**

```dart
// lib/widget/custom_button.dart

import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  CustomButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
```
