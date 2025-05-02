# Code Review Checklist

Use this checklist before committing code to ensure quality and consistency.

## Quick Checks

- [ ] Run `flutter analyze` to check for issues
- [ ] Fix all warnings and errors
- [ ] Remove unused imports
- [ ] Remove commented-out code
- [ ] Format code with `flutter format .`

## Styling

- [ ] Use colors from `AppColors` and `AppColorsDark`
- [ ] Use `withAlpha()` instead of `withOpacity()`
- [ ] Use constants from `AppConstants` for dimensions
- [ ] Use theme text styles when possible
- [ ] Ensure consistent padding and margin values

## Widgets

- [ ] Extract reusable widgets for duplicated UI elements
- [ ] Place shared widgets in the appropriate directory
- [ ] Use `const` constructors when possible
- [ ] Implement responsive design (avoid hardcoded dimensions)
- [ ] Add proper error handling and loading states

## State Management

- [ ] Use providers for state management
- [ ] Keep provider methods focused and single-purpose
- [ ] Call `notifyListeners()` only when state changes
- [ ] Use `Consumer` widgets to limit rebuilds
- [ ] Dispose controllers and subscriptions

## Performance

- [ ] Avoid expensive operations in build methods
- [ ] Use `ListView.builder()` for long lists
- [ ] Implement pagination for API calls
- [ ] Use appropriate image formats and sizes
- [ ] Consider caching for frequently accessed data

## Documentation

- [ ] Add comments for complex logic
- [ ] Document public APIs with dartdoc comments
- [ ] Update README or documentation if needed
- [ ] Add TODOs for future improvements (but don't leave too many)

## Testing

- [ ] Write unit tests for business logic
- [ ] Write widget tests for UI components
- [ ] Test edge cases (empty states, error states)
- [ ] Verify behavior in both light and dark themes

## Accessibility

- [ ] Use semantic labels for important UI elements
- [ ] Ensure sufficient color contrast
- [ ] Support text scaling
- [ ] Test with screen readers if possible

## Common Issues to Check

### Deprecated APIs

- [ ] Replace `Color.withOpacity()` with `Color.withAlpha()`
- [ ] Replace old button widgets with new ones (`ElevatedButton`, `TextButton`)
- [ ] Update any other deprecated Flutter APIs

### Memory Leaks

- [ ] Dispose controllers in the `dispose()` method
- [ ] Cancel subscriptions when no longer needed
- [ ] Use `mounted` check before calling `setState()` after async operations

### UI Issues

- [ ] Test on different screen sizes
- [ ] Ensure proper overflow handling
- [ ] Check dark mode compatibility
- [ ] Verify text visibility against backgrounds

### Code Organization

- [ ] Follow project structure conventions
- [ ] Keep files focused on a single responsibility
- [ ] Use appropriate naming conventions
- [ ] Group related functionality together

## Final Verification

- [ ] Run the app and test the changes
- [ ] Check behavior in both light and dark themes
- [ ] Verify on different screen sizes if possible
- [ ] Ensure no regression in existing functionality
