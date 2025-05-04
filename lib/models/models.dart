// Barrel file for models
// This file exports all models to simplify imports

// Note: We've organized models into subfolders for better maintainability
// We recommend using this barrel file for imports to benefit from the new organization

// Event-related models
export 'event_models/event_models.dart';
export 'event_models/event_template.dart';
export 'event_models/wizard_state.dart';

// User-related models
export 'user_models/user_models.dart';
export 'user_models/user.dart';

// Planning tool models
export 'planning_models/planning_models.dart';
export 'planning_models/budget_item.dart';
export 'planning_models/guest.dart';
export 'planning_models/milestone.dart';
export 'planning_models/milestone_factory.dart';
export 'planning_models/task.dart';
export 'planning_models/vendor_message.dart';

// Service models
export 'service_models/service_models.dart';

// Feature models
export 'feature_models/feature_models.dart';
export 'feature_models/saved_comparison.dart';
export 'feature_models/suggestion.dart';

// Service options models
export 'service_options/service_options.dart';

// Backward compatibility re-exports
export 'barrel_model.dart';
