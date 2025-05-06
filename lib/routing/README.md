# Routing System Documentation

## Overview

The Eventati Book routing system provides a centralized, type-safe approach to navigation throughout the application. It consists of several key components that work together to create a maintainable and consistent navigation experience.

## Key Components

### 1. Route Names (`route_names.dart`)

This file contains all the route names used in the application as static constants. Routes are organized by feature area:

```dart
// Main routes
static const String splash = '/';
static const String login = '/login';

// Service routes
static const String venueList = '/services/venues';
static const String venueDetails = '/services/venues/details';
```

### 2. Route Arguments (`route_arguments.dart`)

This file defines strongly-typed argument classes for each route that requires parameters:

```dart
/// Arguments for venue details screen
class VenueDetailsArguments extends RouteArguments {
  final String venueId;

  const VenueDetailsArguments({required this.venueId}) : super();
}
```

All argument classes extend the base `RouteArguments` class for consistency.

### 3. App Router (`app_router.dart`)

This file contains the central routing logic that maps route names to their corresponding screens:

```dart
static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.venueDetails:
      final args = settings.arguments as VenueDetailsArguments;
      return MaterialPageRoute(
        builder: (context) => VenueDetailsScreen(venue: _getVenueById(args.venueId)),
      );
    // Other routes...
    default:
      return MaterialPageRoute(
        builder: (context) => const ErrorScreen(message: 'Route not found'),
      );
  }
}
```

### 4. Navigation Utilities (`navigation_utils.dart`)

This file provides helper methods for navigation that abstract away the direct use of `Navigator`:

```dart
/// Navigate to a named route
static void navigateToNamed(
  BuildContext context,
  String routeName, {
  Object? arguments,
}) {
  Navigator.of(context).pushNamed(routeName, arguments: arguments);
}
```

## Usage Examples

### Basic Navigation

```dart
// Navigate to the venue list screen
NavigationUtils.navigateToNamed(
  context,
  RouteNames.venueList,
);
```

### Navigation with Arguments

```dart
// Navigate to venue details with venue ID
NavigationUtils.navigateToNamed(
  context,
  RouteNames.venueDetails,
  arguments: VenueDetailsArguments(venueId: '123'),
);
```

### Replacing the Current Screen

```dart
// Replace the current screen with the login screen
NavigationUtils.navigateToNamedAndReplace(
  context,
  RouteNames.login,
);
```

### Clearing the Navigation Stack

```dart
// Clear the stack and navigate to the home screen
NavigationUtils.navigateToNamedAndRemoveUntil(
  context,
  RouteNames.home,
);
```

## Best Practices

1. **Always use route constants**: Never use string literals for route names.
2. **Always use typed arguments**: Create a new argument class in `route_arguments.dart` for routes that need parameters.
3. **Use NavigationUtils**: Avoid using the Navigator directly.
4. **Keep route definitions organized**: Group related routes together in `route_names.dart`.
5. **Document complex navigation flows**: For multi-step flows, add comments explaining the sequence.

## Adding a New Route

To add a new route to the application:

1. Add a new route name constant in `route_names.dart`
2. If the route requires arguments, add a new argument class in `route_arguments.dart`
3. Add a new case in the switch statement in `app_router.dart`
4. Use `NavigationUtils` methods to navigate to the new route

## Troubleshooting

Common issues and their solutions:

- **"Route not found" error**: Check that the route name is correctly defined in `route_names.dart` and handled in `app_router.dart`.
- **"Type cast" error**: Ensure you're passing the correct argument type for the route.
- **Black screen after navigation**: Check that the screen widget is correctly implemented and exported.
