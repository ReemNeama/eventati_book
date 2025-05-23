# Utils Directory

This directory contains utility functions and constants used throughout the Eventati Book application.

## Organization

The utils are organized into the following subfolders for better maintainability:

- **core/**: Core utilities used across the application
  - constants.dart: Application-wide constants
  - extensions.dart: Extension methods for built-in types

- **formatting/**: Utilities for formatting data
  - date_utils.dart: Date formatting and manipulation
  - number_utils.dart: Number formatting
  - string_utils.dart: String manipulation and formatting

- **service/**: Service-related utilities
  - analytics_utils.dart: Analytics tracking utilities
  - file_utils.dart: File handling utilities
  - service_utils.dart: Service-specific utilities
  - validation_utils.dart: Form validation utilities

- **ui/**: UI-related utilities
  - accessibility_utils.dart: Accessibility helpers
  - empty_state_utils.dart: Empty state handling
  - error_handling_utils.dart: Error handling utilities
  - form_utils.dart: Form-related utilities
  - navigation_utils.dart: Navigation helpers
  - responsive_constants.dart: Constants for responsive design
  - responsive_utils.dart: Responsive design utilities
  - ui_utils.dart: General UI utilities

## Special Utilities in Root Directory

Only the following utility files exist in the root utils directory:
- service_options_factory.dart: Factory for creating service options (will be moved to an appropriate subfolder in the future)
- utils.dart: Main barrel file that exports all utilities

## Usage

Import the main barrel file to access all utilities:

```dart
import 'package:eventati_book/utils/utils.dart';

// Now you can use any utility
final formattedDate = DateUtils.formatDate(DateTime.now());
final isValidEmail = ValidationUtils.isValidEmail('user@example.com');
```

For more specific imports, use the subfolder barrel files:

```dart
import 'package:eventati_book/utils/formatting/index.dart';

// Now you can use any formatting utility
final formattedDate = DateUtils.formatDate(DateTime.now());
final formattedPrice = NumberUtils.formatCurrency(100);
```

## Utility Guidelines

1. **Pure Functions**: Utilities should be pure functions without side effects
2. **Stateless**: Utilities should not maintain state
3. **Reusability**: Create utilities that can be reused across the application
4. **Documentation**: Document utility functions with clear descriptions
5. **Testing**: Write unit tests for utility functions
6. **Naming**: Use descriptive names that indicate the utility's purpose
7. **Organization**: Place utilities in the appropriate subfolder based on functionality

## Migration Progress

All utility functions have been migrated from the root directory to their respective subfolders, except for service_options_factory.dart which will be moved in the future. When adding new utility functions, please add them directly to the appropriate subfolder rather than the root directory.
