# Eventati Book Style Guide

This style guide outlines the coding standards and best practices for the Eventati Book project.

## General Principles

- **Consistency**: Follow existing patterns in the codebase
- **Readability**: Write code that is easy to read and understand
- **Maintainability**: Write code that is easy to maintain and extend
- **Performance**: Write code that is efficient and performant

## Code Organization

- Organize code into the following directories:
  - `lib/models`: Data models
  - `lib/providers`: State management
  - `lib/services`: Business logic and API calls
  - `lib/screens`: Full-page UI components
  - `lib/widgets`: Reusable UI components
  - `lib/utils`: Utility functions and constants
  - `lib/styles`: Styling constants and themes

- Create barrel files (index.dart) for directories with 4+ files
- Group related functionality in subdirectories

## Styling

### Text Styles

- **Always use TextStyles constants** from `lib/styles/text_styles.dart`
- Never use hardcoded TextStyle instances
- Use the appropriate TextStyle for the context:
  - `TextStyles.title`: For large headers (24px, bold)
  - `TextStyles.subtitle`: For section headers (18px, semibold)
  - `TextStyles.sectionTitle`: For smaller headers (16px, semibold)
  - `TextStyles.bodyLarge`: For primary content (16px)
  - `TextStyles.bodyMedium`: For regular content (14px)
  - `TextStyles.bodySmall`: For secondary content (12px)
  - `TextStyles.caption`: For small labels (10px)
  - `TextStyles.buttonText`: For button text (16px, semibold)
  - `TextStyles.chip`: For chip text (12px, medium)
  - `TextStyles.price`: For price text (18px, bold)
  - `TextStyles.error`: For error messages (12px, red)
  - `TextStyles.success`: For success messages (12px, green)

- When you need to modify a TextStyle, use `copyWith`:
  ```dart
  TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)
  ```

### Colors

- **Always use AppColors constants** from `lib/styles/app_colors.dart`
- Never use hardcoded Colors instances
- Use the appropriate color for the context:
  - `AppColors.primary`: Primary brand color
  - `AppColors.hintColor`: Secondary brand color
  - `AppColors.background`: Background color
  - `AppColors.textPrimary`: Primary text color
  - `AppColors.textSecondary`: Secondary text color
  - `AppColors.error`: Error color
  - `AppColors.success`: Success color
  - `AppColors.warning`: Warning color
  - `AppColors.info`: Info color
  - `AppColors.disabled`: Disabled color
  - `AppColors.divider`: Divider color

- For dark mode, use AppColorsDark constants
- For semi-transparent colors, use Color.fromRGBO instead of withOpacity:
  ```dart
  // Instead of this:
  AppColors.primary.withOpacity(0.5)
  
  // Use this:
  Color.fromRGBO(
    AppColors.primary.r.toInt(),
    AppColors.primary.g.toInt(),
    AppColors.primary.b.toInt(),
    0.5,
  )
  ```

### Themes

- Use the AppTheme class for theme configuration
- Access the theme using `Theme.of(context)`
- Support both light and dark themes

## Widgets and UI

- Use const constructors where possible
- Extract reusable widgets to their own files
- Use named parameters for clarity
- Follow a consistent naming convention for widgets
- Use SizedBox for spacing instead of Padding when appropriate
- Use MediaQuery for responsive design

## State Management

- Use Provider for state management
- Keep providers focused on a single responsibility
- Use the ProvidersManager for registering providers

## Error Handling

- Use try-catch blocks for error handling
- Display user-friendly error messages
- Log errors for debugging
- Handle edge cases and empty states

## Documentation

- Document public APIs
- Add comments for complex logic
- Use /// for documentation comments
- Use // for implementation comments

## Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Test edge cases and error handling

## Supabase Integration

- Use the SupabaseClient for API calls
- Implement Row Level Security policies
- Handle errors from Supabase operations
- Use typed data models
