// =========================================================
// EVENTATI BOOK PROVIDERS BARREL FILE
// =========================================================
// This file exports all state management providers to simplify imports.
// Providers are organized into logical categories for better maintainability.
//
// USAGE:
//   import 'package:eventati_book/providers/providers.dart';
//
// ORGANIZATION:
//   Providers are organized into subfolders by responsibility area
// =========================================================

// -------------------------
// CORE PROVIDERS
// -------------------------
// Fundamental providers that don't depend on other providers
// These handle authentication, navigation, and core application state
export 'core_providers/core_providers.dart';
// Includes:
// - AuthProvider: Authentication state management
// - WizardProvider: Event wizard state management

// -------------------------
// FEATURE PROVIDERS
// -------------------------
// Providers that implement specific application features
// These handle feature-specific state and business logic
export 'feature_providers/feature_providers.dart';
// Includes:
// - MilestoneProvider: Milestone and achievement tracking
// - SuggestionProvider: Suggestions based on wizard state
// - ServiceRecommendationProvider: Service recommendations
// - ComparisonProvider: Service comparison
// - ComparisonSavingProvider: Saved comparisons

// -------------------------
// PLANNING PROVIDERS
// -------------------------
// Providers related to event planning tools
// These handle state management for planning features
export 'planning_providers/planning_providers.dart';

// Includes:
// - BudgetProvider: Budget management
// - GuestListProvider: Guest list management
// - MessagingProvider: Vendor messaging
// - TaskProvider: Tasks and checklists
// - BookingProvider: Service bookings
