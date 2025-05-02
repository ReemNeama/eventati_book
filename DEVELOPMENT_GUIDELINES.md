# Eventati Book Development Guidelines

This document outlines the coding standards, best practices, and guidelines for the Eventati Book project. Following these guidelines will help maintain code quality, consistency, and prevent common issues.

## Table of Contents

1. [Code Organization](#code-organization)
2. [Naming Conventions](#naming-conventions)
3. [Styling Guidelines](#styling-guidelines)
4. [Widget Best Practices](#widget-best-practices)
5. [State Management](#state-management)
6. [Common Issues to Avoid](#common-issues-to-avoid)
7. [Performance Considerations](#performance-considerations)
8. [Testing Guidelines](#testing-guidelines)
9. [Pre-Commit Checklist](#pre-commit-checklist)

## Code Organization

### Project Structure

Maintain the following folder structure:

```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── styles/         # Theme and styling
├── utils/          # Utility functions
├── widgets/        # Reusable UI components
└── main.dart       # Application entry point
```

### File Organization

- **One class per file**: Each Dart file should contain only one main class.
- **Group related files**: Keep related files in the same directory.
- **Feature-based organization**: Organize screens and widgets by feature (e.g., `auth`, `event_planning`).

### Import Order

Follow this order for imports:
1. Dart SDK imports
2. Flutter framework imports
3. Third-party package imports
4. Project imports (sorted alphabetically)

Example:
```dart
// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Third-party imports
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports
import 'package:eventati_book/models/user.dart';
import 'package:eventati_book/providers/auth_provider.dart';
import 'package:eventati_book/utils/constants.dart';
```

## Naming Conventions

- **Files**: Use snake_case for file names (e.g., `auth_provider.dart`, `login_screen.dart`).
- **Classes**: Use PascalCase for class names (e.g., `AuthProvider`, `LoginScreen`).
- **Variables and methods**: Use camelCase for variables and methods (e.g., `userName`, `loginUser()`).
- **Constants**: Use SCREAMING_SNAKE_CASE for constants (e.g., `MAX_LOGIN_ATTEMPTS`).
- **Private members**: Prefix with underscore (e.g., `_privateVariable`, `_privateMethod()`).

## Styling Guidelines

### Use Centralized Styling

- Always use the centralized styling system:
  - `AppColors` and `AppColorsDark` for colors
  - `AppTheme` for theme configuration
  - `AppConstants` for dimensions and other constants

### Color Usage

- **Never hardcode colors**: Always use colors from `AppColors` or `AppColorsDark`.
- **Use theme-aware colors**: Check the current theme and use appropriate colors.
- **Avoid deprecated color methods**:
  - Use `Color.withAlpha()` instead of `Color.withOpacity()`
  - Use `Color.fromRGBO()` instead of creating colors with opacity directly

Example:
```dart
// GOOD
final isDarkMode = Theme.of(context).brightness == Brightness.dark;
final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
final colorWithAlpha = primaryColor.withAlpha(25);

// BAD
final color = Colors.blue;
final colorWithOpacity = Colors.blue.withOpacity(0.5);
```

### Text Styling

- Use the theme's text styles when possible:
```dart
Text(
  'Hello World',
  style: Theme.of(context).textTheme.bodyLarge,
)
```

- For custom text styles, create reusable styles in a central location.

### Dimensions and Spacing

- Use constants for dimensions and spacing:
```dart
// GOOD
padding: const EdgeInsets.all(AppConstants.mediumPadding),

// BAD
padding: const EdgeInsets.all(16.0),
```

## Widget Best Practices

### Extract Reusable Widgets

- Create reusable widgets for UI elements that appear multiple times.
- Place shared widgets in the `widgets` directory.
- Place screen-specific widgets in a subdirectory within the screen's directory.

### Widget Organization

- Use named constructors for widget variants.
- Keep widget methods organized by purpose.
- Use `const` constructors when possible.

### Responsive Design

- Avoid hardcoded dimensions.
- Use flexible widgets like `Expanded`, `Flexible`, and `FractionallySizedBox`.
- Test on different screen sizes.

## State Management

### Provider Guidelines

- Create providers for distinct features or data domains.
- Keep provider methods focused and single-purpose.
- Document provider methods with dartdoc comments.

### State Updates

- Call `notifyListeners()` only when state actually changes.
- Batch state changes to minimize rebuilds.
- Use `Consumer` widgets to limit rebuilds to specific parts of the UI.

## Common Issues to Avoid

### Imports

- **Remove unused imports**: Regularly check and remove unused imports.
- **Avoid wildcard imports**: Don't use `import 'package:foo/foo.dart' as foo;`

### Deprecated APIs

- Avoid using deprecated Flutter APIs.
- Replace deprecated methods with their recommended alternatives.
- Common deprecated methods to avoid:
  - `Color.withOpacity()` → Use `Color.withAlpha()` instead
  - `TextTheme` constructors → Use `TextTheme.copyWith()` instead
  - `RaisedButton`, `FlatButton` → Use `ElevatedButton`, `TextButton` instead

### Memory Leaks

- Dispose controllers, animations, and streams in the `dispose()` method.
- Cancel subscriptions when they're no longer needed.
- Use `mounted` check before calling `setState()` after async operations.

### UI Performance

- Avoid expensive operations in the build method.
- Use `const` constructors for widgets that don't change.
- Implement pagination for long lists.

## Performance Considerations

### Image Optimization

- Use appropriate image formats and sizes.
- Implement image caching.
- Consider using placeholder images during loading.

### List Optimization

- Use `ListView.builder()` for long lists.
- Implement pagination for API calls.
- Consider using `const` widgets for list items when possible.

### Build Optimization

- Minimize widget rebuilds.
- Use `const` constructors.
- Consider using `RepaintBoundary` for complex UI elements.

## Testing Guidelines

### Unit Tests

- Write tests for all business logic.
- Mock dependencies for isolated testing.
- Aim for high test coverage of models and providers.

### Widget Tests

- Test key user interactions.
- Verify widget behavior in different states.
- Test edge cases (empty states, error states).

### Integration Tests

- Test critical user flows end-to-end.
- Verify app behavior across multiple screens.

## Pre-Commit Checklist

Before committing code, ensure:

1. **No unused imports**: Remove all unused imports.
2. **No deprecated APIs**: Replace all deprecated method calls.
3. **Consistent styling**: Follow the project's styling guidelines.
4. **Extract reusable widgets**: Create widgets for duplicated UI elements.
5. **Proper error handling**: Handle all potential errors.
6. **Documentation**: Add comments for complex logic.
7. **Tests**: Write tests for new functionality.
8. **Performance**: Check for potential performance issues.
9. **Accessibility**: Ensure UI is accessible.
10. **Responsive design**: Test on different screen sizes.

---

By following these guidelines, we can maintain a high-quality, consistent codebase that is easy to understand, extend, and maintain.
