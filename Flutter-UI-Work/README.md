# GetX Boiler Plate

A simple and well-structured boilerplate for using the GetX pattern in Flutter projects. This boilerplate is designed to help you kickstart your Flutter application with the GetX pattern quickly and efficiently.

## Introduction

This boilerplate provides a solid foundation for implementing the GetX pattern in your Flutter projects. It follows best practices and aims to simplify the management of state and business logic in your application, ensuring a clean and scalable codebase.

## Features

- Clean and scalable architecture using the GetX pattern
- Well-organized folder structure
- Pre-configured dependencies
- Ready-to-use examples and templates
- Easy integration with new and existing Flutter projects
- Built-in support for API calls using the `http` package

## Folder Structure

Here's an overview of the folder structure used in this boilerplate:

```
lib/
├── Configuration/                         # Contains configuration files
│   └── app_configuration.dart             # App configuration settings
├── Controller/                            # Contains GetX controllers for state management
│   ├── home_controller.dart               # Controller for home screen logic
│   └── login_controller.dart              # Controller for login logic
├── Export/                                # Contains export files for easier imports
│   └── export.dart                        # Centralized export file
├── Helper/                                # Helper functions and utilities
│   ├── base_controller.dart               # Base controller class for shared functionality
│   ├── base_response_model.dart           # Model for handling API responses
│   ├── enum.dart                          # Enum definitions used across the app
│   ├── routes.dart                        # Application routes
│   └── settings.dart                      # Application settings and configurations
├── Model/                                 # Data models
│   ├── rest_service.dart                  # Service for handling REST API calls
│   └── service_configuration.dart         # Configuration settings for services
├── View/                                  # UI screens of the application
│   ├── home_page.dart                     # Home screen UI
│   └── login_page.dart                    # Login screen UI
└── main.dart                              # Entry point of the application
```

## Getting Started

To get started with this boilerplate, you need to have Flutter installed on your system. If you don't have it installed yet, follow the official Flutter installation guide here.

## Installation

Clone the repository:
```
git clone https://github.com/DevCodeSpace/MyCodeSpace/GetX-boilerplate
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

**Step 1:-** Create a New Service

- Navigate to the lib/Model/ directory.
- Create a new Dart file named api_service.dart.
- Implement the API service class with methods for making HTTP requests.

```dart
// lib/Model/rest_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class RestService {
  final String baseUrl = 'https://api.example.com';

  Future<String> fetchFeatureData() async {
    final response = await http.get(Uri.parse('$baseUrl/feature'));

    if (response.statusCode == 200) {
      // Parse the JSON response and return the data
      final data = jsonDecode(response.body);
      return data['result'];
    } else {
      throw Exception('Failed to load data');
    }
  }
}
```

**Step 1:-** Create a New Controller

- Navigate to the `lib/Controller/` directory.
- Create a new Dart file named after the feature (e.g.:- `feature_controller.dart` ).
- Implement the GetX controller class, including methods for making API calls and updating the state.

```dart
// lib/Controller/feature_controller.dart

import 'package:get/get.dart';
import 'package:your_project_name/Model/rest_service.dart'; // Replace with your actual path

class FeatureController extends GetxController {
  var data = ''.obs;
  var isLoading = false.obs;
  final RestService _restService = RestService();

  void loadFeatureData() async {
    try {
      isLoading(true);
      final result = await _restService.fetchFeatureData();
      data.value = result;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}

```

**Step 2:-** Create or Update a Screen

- Navigate to the `lib/View/` directory.
- Create a new screen Dart file or update an existing one.
- Inject the newly created controller using the `Get.put()` method and use `Obx` to reactively update the UI based on state changes.

``` dart
// lib/View/feature_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_project_name/Controller/feature_controller.dart'; // Replace with your actual path

class FeaturePage extends StatelessWidget {
  final FeatureController featureController = Get.put(FeatureController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature Page')),
      body: Center(
        child: Obx(() {
          if (featureController.isLoading.value) {
            return CircularProgressIndicator();
          } else {
            return Text(featureController.data.value);
          }
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: featureController.loadFeatureData,
        child: Icon(Icons.refresh),
      ),
    );
  }
}
```

**Step 3:-** Define Routes

- Update the `/Helper/routes.dart` file to include a route for the new screen.

```dart
// lib/Helper/routes.dart

import 'package:flutter/material.dart';
import 'package:your_project_name/View/feature_page.dart'; // Replace with your actual path

class Routes {
  static const String feature = '/feature';

  static List<GetPage<dynamic>> get getPages {
    return [
      GetPage(
        name: Routes.feature,
        page: () => const FeaturePage(),
        binding: BindingsBuilder.put(
          () => FeatureController(),
        ),
        transition: Transition.cupertino,
      ),
     
    ];
  }
}
```

**Step 4:-** Modify or Create Widgets

- If you need custom widgets for your new feature, navigate to the `lib/View/` directory.
- Create a new Dart file for the widget or update existing ones.
- Reuse existing widgets where applicable to maintain consistency.

```dart
// lib/View/custom_button.dart

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


This `README` file should help you document and structure your GetX-based Flutter project efficiently.
