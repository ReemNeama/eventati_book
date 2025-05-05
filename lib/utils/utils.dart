// =========================================================
// EVENTATI BOOK UTILITIES BARREL FILE
// =========================================================
// This file exports all utility functions to simplify imports.
// Utilities are organized into logical categories for better maintainability.
//
// USAGE:
//   import 'package:eventati_book/utils/utils.dart';
//
// ORGANIZATION:
//   Utilities are organized into subfolders by functionality
// =========================================================

// -------------------------
// CATEGORY EXPORTS (PREFERRED)
// -------------------------
// These export all utilities in each category through index files
// For new code, prefer using these category exports

// Core utilities (constants, extensions, etc.)
export 'core/index.dart';

// Data formatting utilities (date, number, string formatting)
export 'formatting/index.dart';

// UI and interaction utilities (responsive design, forms, navigation)
export 'ui/index.dart';

// Service utilities (validation, file handling, analytics)
export 'service/index.dart';

// -------------------------
// DIRECT EXPORTS (LEGACY)
// -------------------------
// These direct exports are maintained for backward compatibility
// They will be removed once all imports are updated to use the new structure

// Core utilities
export 'core/constants.dart'; // Application-wide constants
export 'core/extensions.dart'; // Extension methods for built-in types

// Data formatting utilities
export 'formatting/date_utils.dart'; // Date formatting and manipulation
export 'formatting/number_utils.dart'; // Number formatting
export 'formatting/string_utils.dart'; // String manipulation and formatting

// UI and interaction utilities
export 'ui/ui_utils.dart'; // General UI utilities
export 'ui/responsive_utils.dart'; // Responsive design utilities
export 'ui/responsive_constants.dart'; // Constants for responsive design
export 'ui/form_utils.dart'; // Form-related utilities
export 'ui/navigation_utils.dart'; // Navigation helpers
export 'ui/error_handling_utils.dart'; // Error handling utilities
export 'ui/empty_state_utils.dart'; // Empty state handling
export 'ui/accessibility_utils.dart'; // Accessibility helpers

// Service utilities
export 'service/service_utils.dart'; // Service-specific utilities
export 'service/file_utils.dart'; // File handling utilities
export 'service/validation_utils.dart'; // Form validation utilities
export 'service/analytics_utils.dart'; // Analytics tracking utilities

// -------------------------
// SPECIAL UTILITIES
// -------------------------
// These utilities exist in the root directory and will be moved to appropriate
// subfolders in the future

export 'service_options_factory.dart'; // Factory for creating service options
