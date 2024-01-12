# Flutter Geoform Library

## Overview

Flutter Geoform is a comprehensive library designed for Flutter applications that require interactive map functionalities. It integrates map visualization, form handling, marker management, and more, offering a modular and easy-to-use solution for geo-spatial data handling in Flutter apps.

## Features

- **Map Interaction**: Seamless integration with Flutter Map for interactive map handling.
- **Marker Management**: Customizable markers with extended functionalities, including animations and centroid calculations.
- **Geoform Bloc**: Utilizes the Bloc pattern for efficient state management in Flutter applications.
- **Customizable UI Components**: Includes a set of widgets for displaying map-related information and controls at the bottom of the app.
- **Overlay Support**: Provides overlay functionality to highlight selected map elements.
- **Geoform Context and Functions**: Simplifies interaction with the map and markers through a dedicated context and utility functions.

## Getting Started

This section provides a step-by-step guide to implementing Geoform in your Flutter application.

### Step 1: Setting Up

Ensure you have Flutter installed on your system. Add the Flutter Geoform library to your project by including it in your `pubspec.yaml` file

### Step 2: Importing the library

Import the necessary components of the Flutter Geoform library in your Dart file:

```dart
import 'package:flutter_geoform/flutter_geoform.dart';
```

### Step 3: Initializing Geoform

Create a Geoform widget and embed it in your application. Configure the necessary parameters like title, formBuilder, markerBuilder, etc.

```dart
class MyGeoformPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Geoform<MyDataType, MyMarkerType>(
      title: 'My Geoform Map',
      formBuilder: (context, geoformContext) {
        // Implement your form builder logic here
      },
      markerBuilder: (markerData) {
        // Implement your marker builder logic here
      },
      // Additional configurations...
    );
  }
}
```

### Step 4: Configuring Markers and Forms

Define how your markers should be built and how forms should be rendered when a marker is selected. Implement custom logic as needed for your application's requirements.

### Step 5: Handling Events and Interactions

Utilize the callbacks provided by Geoform for handling user interactions such as selecting a marker, submitting a form, or interacting with the map.

### Step 6: Customizing the UI

If needed, customize the UI components such as the bottom panel or action buttons. Use the provided builders and styles to match the look and feel of your application.

### Step 7: Running and Testing

Run your application and test the Geoform functionality. Ensure that map interactions, marker placements, and form submissions are working as expected.

## Example

Here's an example of a simple implementation:

```dart
Geoform<MyDataType, MyMarkerType>(
  title: 'My Geoform Map',
  formBuilder: (context, geoformContext) {
    return MyCustomForm(geoformContext);
  },
  markerBuilder: (markerData) {
    return MyCustomMarker(markerData);
  },
  onMarkerSelected: (marker) {
    print('Marker selected: ${marker.id}');
  },
  // Additional configurations...
);
```

Replace MyDataType and MyMarkerType with your specific data types, and customize the form and marker builders as per your application's requirements.
