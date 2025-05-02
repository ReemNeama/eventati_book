# Development Instructions

This document outlines the key instructions and guidelines to follow when developing the Eventati Book application.

## Code Style and Formatting

1. **Use Dart Formatter**: Always run the Dart formatter on your code before committing changes.
   ```
   dart format lib/
   ```

2. **Follow Naming Conventions**:
   - Use `camelCase` for variables and methods
   - Use `PascalCase` for classes and enums
   - Use `snake_case` for file names
   - Use descriptive names that clearly indicate purpose

3. **When Naming Conflicts Occur**: Always use the more descriptive name. For example, if one file uses `userButton` and another uses `userProfileButton`, standardize on the more descriptive `userProfileButton`.

## Code Organization

1. **Create Barrel Files**: For modules with 4 or more imports, create a barrel file to export all components.
   ```dart
   // lib/widgets/buttons/buttons.dart
   export 'primary_button.dart';
   export 'secondary_button.dart';
   // Add comments to clarify what each export provides
   ```

2. **Organize by Feature**: Group related files by feature rather than by type.

3. **Use Providers in main.dart**: Register all core providers in main.dart for better organization.

4. **Use tempDB for Mock Data**: Store all temporary/mock data in the tempDB folder with proper documentation.

## Responsive Design

1. **Every Page Must Be Responsive**: Ensure all screens adapt to different screen sizes.

2. **Use Responsive Widgets**: Utilize the responsive widgets in the `widgets/responsive` folder.

3. **Test on Multiple Screen Sizes**: Verify layouts on phone, tablet, and desktop sizes.

4. **Support Both Orientations**: Ensure the app works well in both portrait and landscape modes.

## Styling and UI

1. **Use Centralized Styles**: Always use the styles defined in the `styles` folder.

2. **Use Utils for Common Operations**: Leverage utility functions from the `utils` folder.

3. **Extract Reusable Widgets**: Create shared widgets for repeated UI elements.

## Documentation

1. **Comment Everything**: Add clear comments to all code sections.

2. **Document Public APIs**: Add documentation comments to all public methods and classes.

3. **Update Development Tracker**: Keep the development tracker up to date with completed tasks.

## Testing

1. **Write Unit Tests**: Add tests for all business logic.

2. **Test Edge Cases**: Ensure your code handles edge cases gracefully.

3. **Run Tests Before Committing**: Verify all tests pass before committing changes.

## Performance

1. **Optimize Resource Usage**: Be mindful of memory and CPU usage.

2. **Lazy Load When Possible**: Use lazy loading for providers and heavy resources.

3. **Minimize Rebuilds**: Use const constructors and efficient state management.

By following these instructions, we'll maintain a high-quality, maintainable, and consistent codebase.
