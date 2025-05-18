# Code Review Checklist

This checklist should be used when reviewing code for the Eventati Book project.

## Style and Formatting

- [ ] Code follows the project's style guide
- [ ] Code is properly formatted (run `flutter format .` before submitting)
- [ ] No hardcoded TextStyle instances (use TextStyles constants)
- [ ] No hardcoded Colors instances (use AppColors constants)
- [ ] No withOpacity or withAlpha calls (use Color.fromRGBO)
- [ ] Imports are properly organized (dart, flutter, third-party, project)
- [ ] No unused imports
- [ ] No commented-out code

## Architecture and Structure

- [ ] Code follows the project's architecture (providers, models, services, UI)
- [ ] Business logic is separated from UI
- [ ] Reusable widgets are extracted to their own files
- [ ] Constants are defined in appropriate files
- [ ] No hardcoded strings (use constants or localization)

## Performance and Efficiency

- [ ] No unnecessary rebuilds (use const constructors where appropriate)
- [ ] Heavy computations are not done in the build method
- [ ] Lists use ListView.builder or similar for efficiency
- [ ] Images are properly cached
- [ ] Proper use of FutureBuilder and StreamBuilder

## Error Handling and Edge Cases

- [ ] Proper error handling for async operations
- [ ] Empty states are handled
- [ ] Loading states are handled
- [ ] Edge cases are considered (e.g., no internet connection)
- [ ] Form validation is implemented where needed

## Accessibility and Usability

- [ ] UI is responsive (works on different screen sizes)
- [ ] Text has sufficient contrast
- [ ] Touch targets are at least 48x48 pixels
- [ ] Semantic labels are provided for important widgets
- [ ] UI is consistent with the rest of the app

## Testing

- [ ] Unit tests are added for new functionality
- [ ] Existing tests pass
- [ ] Edge cases are tested
- [ ] UI tests are added for new screens or widgets

## Documentation

- [ ] Code is well-commented where necessary
- [ ] Complex logic is explained
- [ ] Public APIs are documented
- [ ] README is updated if needed

## Supabase Integration

- [ ] Proper use of Supabase client
- [ ] Row Level Security policies are implemented
- [ ] Data is properly typed
- [ ] Error handling for Supabase operations
- [ ] No hardcoded Supabase URLs or keys

## Style Usage

- [ ] TextStyles constants are used instead of hardcoded TextStyle
- [ ] AppColors constants are used instead of hardcoded Colors
- [ ] Color.fromRGBO is used instead of withOpacity or withAlpha
- [ ] Dark mode is properly supported where needed
- [ ] UI is consistent with the app's design language
