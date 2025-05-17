// =========================================================
// EVENTATI BOOK MODELS BARREL FILE
// =========================================================
// This file exports all models to simplify imports throughout the application.
// Models are organized into logical categories for better maintainability.
//
// USAGE:
//   import 'package:eventati_book/models/models.dart';
//
// ORGANIZATION:
//   Models are organized into subfolders by domain/feature area
// =========================================================

// -------------------------
// EVENT MODELS
// -------------------------
// Models related to events and the event creation wizard
export 'event_models/event_models.dart'; // Barrel file for event models
export 'event_models/event_template.dart'; // Template for creating events
export 'event_models/wizard_state.dart'; // State management for the event wizard
export 'event_models/wizard_connection.dart'; // Connections between wizard and planning tools

// -------------------------
// USER MODELS
// -------------------------
// Models related to user data and authentication
export 'user_models/user_models.dart'; // Barrel file for user models
export 'user_models/user.dart'; // User profile and authentication data

// -------------------------
// PLANNING TOOL MODELS
// -------------------------
// Models used in event planning tools (budget, guest list, etc.)
export 'planning_models/planning_models.dart'; // Barrel file for planning models
export 'planning_models/budget_item.dart'; // Budget item for financial planning
export 'planning_models/guest.dart'; // Guest information for guest lists
export 'planning_models/milestone.dart'; // Milestone tracking
export 'planning_models/milestone_factory.dart'; // Factory for creating milestones
export 'planning_models/task.dart'; // Tasks for checklists and timelines
export 'planning_models/task_category.dart'; // Task categories
export 'planning_models/vendor_message.dart'; // Messages exchanged with vendors

// -------------------------
// SERVICE MODELS
// -------------------------
// Models for various services (venues, catering, etc.)
export 'service_models/service_models.dart'; // Barrel file for all service models
// Individual service models are exported through service_models.dart

// -------------------------
// FEATURE MODELS
// -------------------------
// Models for specific features like comparisons and suggestions
export 'feature_models/feature_models.dart'; // Barrel file for feature models
export 'feature_models/saved_comparison.dart'; // Saved service comparisons
export 'feature_models/suggestion.dart'; // Suggestions based on user preferences

// -------------------------
// SERVICE OPTIONS MODELS
// -------------------------
// Models for service filtering and configuration options
export 'service_options/service_options.dart'; // Barrel file for service options

// -------------------------
// NOTIFICATION MODELS
// -------------------------
// Models for notifications and notification preferences
export 'notification_models/notification_models.dart'; // Barrel file for notification models
export 'notification_models/notification.dart'; // Notification data model
export 'notification_models/notification_settings.dart'; // User notification preferences
export 'notification_models/notification_topic.dart'; // Notification topics

// -------------------------
// LEGACY EXPORTS
// -------------------------
// Backward compatibility re-exports (will be removed in future)
export 'barrel_model.dart'; // Legacy barrel file
