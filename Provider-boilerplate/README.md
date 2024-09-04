# Provider & GetIt-boilerplate

A well-structured Flutter project boilerplate combining Provider for state management and GetIt for dependency injection. This boilerplate is designed to help you kickstart your Flutter application with a clean architecture, making it easier to manage state and dependencies in a scalable way.


## Introduction

This boilerplate provides a solid foundation for implementing state management using Provider and dependency injection using GetIt. It follows best practices to simplify the management of state, business logic, and dependencies in your Flutter application.


## Features

- Clean and scalable architecture using the Provider pattern
- Well-organized folder structure
- Pre-configured dependencies
- Ready-to-use examples and templates
- Easy integration with new and existing Flutter projects


## Folder Structre
Here's an overview of the folder structure used in this boilerplate:
```
lib/
├── main.dart
├── helper/
│   ├── routes.dart
│   └── service_locator.dart
├── models/
│   └── user_model.dart
├── providers/
│   └── auth_provider.dart
├── screens/
│   ├── home_screen.dart
│   └── login_screen.dart
├── services/
│   └── api_service.dart
└── widgets/
    └── custom_button.dart                   
```

## Getting Started

To get started with this boilerplate, you need to have Flutter installed on your system. If you don't have it installed yet, follow the official Flutter installation guide here.

## Installation

Clone the repository:
```
git clone https://github.com/DevCodeSpace/MyCodeSpace/Provider-GetIt-boilerplate
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

**Step 1 :- Setting Up GetIt for Dependency Injection**

- In the `lib/helper/service_locator.dart` file, you can register your services and providers. This file is where you define which services will be available globally across your app.

**Example:**

```dart
import 'package:get_it/get_it.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Register services
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Register providers
  getIt.registerLazySingleton<AuthProvider>(() => AuthProvider());
}

```

**Step 2: Adding a New Service**

- To add a new service, create a new Dart file in the `lib/services/` directory, define your service class, and then register it in service_locator.dart.

**Example:**

```dart
// lib/services/new_service.dart
class NewService {
  Future<String> getData() async {
    return "Some Data";
  }
}
```
- Register the new service in service_locator.dart:

```dart
getIt.registerLazySingleton<NewService>(() => NewService());
```

**Step 3: Create a New Provider**

- To create a new Provider, create a Dart file in the `lib/providers/` directory.
- Providers will use the services injected via GetIt and manage the application state.

**Example:**

```dart
// lib/providers/new_provider.dart
import 'package:flutter/material.dart';
import '../services/new_service.dart';
import '../helper/service_locator.dart';

class NewProvider with ChangeNotifier {
  final NewService _newService = GetIt.instance<NewService>();

  String _data = "";
  bool _isLoading = false;

  String get data => _data;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _data = await _newService.getData();

    _isLoading = false;
    notifyListeners();
  }
}
```

**Step 4 :-  Create or Update a Screen:**

- Navigate to the `lib/screens/` directory.
- Create a new screen Dart file or update an existing one.
- Inject the newly created Provider using the `ChangeNotifierProvider` widget.
- Use `Consumer` or `Provider.of` to react to state changes within the UI.

**Example:**

```dart
// lib/screens/new_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/new_provider.dart';

class NewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final newProvider = Provider.of<NewProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('New Screen')),
      body: Center(
        child: newProvider.isLoading
            ? CircularProgressIndicator()
            : Text(newProvider.data),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => newProvider.loadData(),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
```

**Step 4 :-  Define Routes:**

- Update the `/helper/routes.dart` file to include a route for the new screen, if applicable.
**Example:**

```dart
import 'package:flutter/material.dart';
import '../screens/feature_screen.dart';

class Routes {
  static const String feature = '/feature';

  static Map<String, Widget Function(BuildContext)> get routes {
    return {
      Routes.feature: (context) => FeatureScreen(),
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
