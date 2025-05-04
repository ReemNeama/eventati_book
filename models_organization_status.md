# Models Organization Status

## Current Structure

The models are now organized into the following subfolders:

- **event_models/**: Event-related models
  - event_template.dart
  - wizard_state.dart

- **user_models/**: User-related models
  - user.dart

- **planning_models/**: Planning tool models
  - budget_item.dart
  - guest.dart
  - milestone.dart
  - milestone_factory.dart (replaces milestone_templates.dart)
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

## Re-export Files

For backward compatibility, the following re-export files exist in the root models directory:

- budget_item.dart → planning_models/budget_item.dart
- catering_package.dart → service_models/catering_package.dart
- catering_service.dart → service_models/catering_service.dart
- event_template.dart → event_models/event_template.dart
- guest.dart → planning_models/guest.dart
- milestone.dart → planning_models/milestone.dart
- milestone_factory.dart → planning_models/milestone_factory.dart
- saved_comparison.dart → feature_models/saved_comparison.dart
- suggestion.dart → feature_models/suggestion.dart
- task.dart → planning_models/task.dart
- user.dart → user_models/user.dart
- vendor_message.dart → planning_models/vendor_message.dart
- wizard_state.dart → event_models/wizard_state.dart

## Barrel Files

Each subfolder has its own barrel file for simplified imports:

- event_models/event_models.dart
- user_models/user_models.dart
- planning_models/planning_models.dart
- service_models/service_models.dart
- feature_models/feature_models.dart
- service_options/service_options.dart

The main models.dart barrel file exports all subfolder barrel files.

## Import Updates

All files have been updated to use the models.dart barrel file instead of direct imports, including:

- All event planning screens (budget, guest list, milestones, messaging, timeline)
- All providers (budget, guest list, milestone, messaging, task, wizard)
- All widgets (milestone cards, vendor cards, etc.)
- All services (task template service)
- All tests (vendor message test)

Cross-model imports have been updated to use direct paths to avoid circular dependencies:

- lib/models/feature_models/suggestion.dart now imports from event_models/wizard_state.dart
- lib/models/planning_models/milestone.dart now imports from event_models/wizard_state.dart
- lib/models/planning_models/milestone_factory.dart now imports milestone.dart directly

## Documentation Updates

Comprehensive documentation has been added to the following model files:

- lib/models/planning_models/milestone_factory.dart
  - Added detailed class documentation
  - Added comprehensive method documentation
  - Documented all template categories and their purposes

## Barrel Files Reorganization

All barrel files (re-export files) have been moved from the root models directory to a dedicated `barrel_model` directory:

1. Created a new directory called "barrel_model" inside the models directory
2. Moved all the re-export files from the root models directory to the new barrel_model directory
3. Updated the export paths in the re-export files to correctly point to their respective model files
4. Created a barrel_model.dart file in the models directory that exports all the files from the barrel_model directory
5. Updated the models.dart file to export the barrel_model.dart file and directly export the model files
6. Updated all the imports in the codebase to use the models.dart barrel file instead of importing directly from the models directory

This reorganization keeps the models directory cleaner while maintaining backward compatibility for any code that imports directly from the models directory.

## Next Steps

1. Add more comprehensive documentation for remaining model classes
2. Create unit tests for all model classes to ensure proper functionality
3. Consider removing the barrel_model directory and barrel_model.dart file once all imports have been thoroughly tested and updated to use the models.dart barrel file directly
