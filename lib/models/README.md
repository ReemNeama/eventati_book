# Models Directory

This directory contains all the data models used in the Eventati Book application.

## Organization

The models are organized into the following subfolders for better maintainability:

- **event_models/**: Event-related models
  - event_template.dart
  - wizard_state.dart

- **user_models/**: User-related models
  - user.dart

- **planning_models/**: Planning tool models
  - budget_item.dart
  - guest.dart
  - milestone.dart
  - milestone_factory.dart
  - task.dart
  - vendor_message.dart

- **service_models/**: Service-related models
  - booking.dart
  - catering_package.dart
  - catering_service.dart
  - menu_item.dart
  - photographer.dart
  - photographer_package.dart
  - planner.dart
  - planner_package.dart
  - venue.dart
  - venue_package.dart

- **feature_models/**: Feature-specific models
  - saved_comparison.dart
  - suggestion.dart

- **service_options/**: Service options models
  - venue_options.dart
  - catering_options.dart
  - photography_options.dart
  - planner_options.dart

## Usage

Some model files have been moved to their respective subfolders, while others still exist in the root models directory for backward compatibility. We recommend using the models.dart barrel file for imports to benefit from the new organization:

```dart
import 'package:eventati_book/models/models.dart';

// Now you can use any model
final venue = Venue(...);
final user = User(...);
```

Each subfolder also has its own barrel file for more specific imports if needed:

```dart
import 'package:eventati_book/models/service_models/service_models.dart';

// Now you can use any service model
final venue = Venue(...);
final photographer = Photographer(...);
```

## Migration Progress

We have completed migrating imports to use the new subfolder structure:

1. ✅ venue.dart - Removed (was re-exporting from service_models/venue.dart)
2. ✅ venue_package.dart - Removed (was re-exporting from service_models/venue_package.dart)
3. ✅ photographer.dart - Removed (was re-exporting from service_models/photographer.dart)
4. ✅ photographer_package.dart - Removed (was re-exporting from service_models/photographer_package.dart)
5. ✅ planner.dart - Removed (was re-exporting from service_models/planner.dart)
6. ✅ planner_package.dart - Removed (was re-exporting from service_models/planner_package.dart)
7. ✅ catering_service.dart - Re-exporting from service_models/catering_service.dart
8. ✅ catering_package.dart - Re-exporting from service_models/catering_package.dart
9. ✅ menu_item.dart - Removed (was re-exporting from service_models/menu_item.dart)
10. ✅ booking.dart - Removed (was re-exporting from service_models/booking.dart)
11. ✅ user.dart - Re-exporting from user_models/user.dart
12. ✅ event_template.dart - Re-exporting from event_models/event_template.dart
13. ✅ wizard_state.dart - Re-exporting from event_models/wizard_state.dart
14. ✅ budget_item.dart - Re-exporting from planning_models/budget_item.dart
15. ✅ guest.dart - Re-exporting from planning_models/guest.dart
16. ✅ milestone.dart - Re-exporting from planning_models/milestone.dart
17. ✅ milestone_factory.dart - Re-exporting from planning_models/milestone_factory.dart
18. ✅ task.dart - Re-exporting from planning_models/task.dart
19. ✅ vendor_message.dart - Re-exporting from planning_models/vendor_message.dart
20. ✅ suggestion.dart - Re-exporting from feature_models/suggestion.dart
21. ✅ saved_comparison.dart - Re-exporting from feature_models/saved_comparison.dart

## Future Improvements

Now that all model files have been updated to re-export from their respective subfolders, the next steps are:

1. Gradually update imports throughout the codebase to use the models.dart barrel file
2. Once all imports have been updated, remove the re-export files from the root directory
3. Consider adding more comprehensive documentation for each model class
