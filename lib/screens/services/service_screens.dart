// =========================================================
// EVENTATI BOOK SERVICE SCREENS BARREL FILE
// =========================================================
// This file exports all service-related screens to simplify imports.
// Service screens are organized by service type for better maintainability.
//
// USAGE:
//   import 'package:eventati_book/screens/services/service_screens.dart';
//
// ORGANIZATION:
//   Screens are organized into subfolders by service type
// =========================================================

// -------------------------
// COMMON SERVICE SCREENS
// -------------------------
// Screens that apply to all service types
export 'common/index.dart';
// Includes:
// - ServicesScreen: Main entry point for browsing services

// -------------------------
// VENUE SCREENS
// -------------------------
// Screens for browsing and viewing venue services
export 'venue/index.dart';
// Includes:
// - VenueListScreen: List of available venues
// - VenueDetailsScreen: Detailed view of a specific venue

// -------------------------
// CATERING SCREENS
// -------------------------
// Screens for browsing and viewing catering services
export 'catering/index.dart';
// Includes:
// - CateringListScreen: List of available catering services
// - CateringDetailsScreen: Detailed view of a specific catering service

// -------------------------
// PHOTOGRAPHER SCREENS
// -------------------------
// Screens for browsing and viewing photography services
export 'photographer/index.dart';
// Includes:
// - PhotographerListScreen: List of available photographers
// - PhotographerDetailsScreen: Detailed view of a specific photographer

// -------------------------
// PLANNER SCREENS
// -------------------------
// Screens for browsing and viewing event planner services
export 'planner/index.dart';
// Includes:
// - PlannerListScreen: List of available event planners
// - PlannerDetailsScreen: Detailed view of a specific event planner

// -------------------------
// COMPARISON SCREENS
// -------------------------
// Screens for comparing different services
export 'comparison/index.dart';
// Includes:
// - ServiceComparisonScreen: Compare multiple services
// - SavedComparisonsScreen: View previously saved comparisons

// -------------------------
// NAVIGATION FLOW
// -------------------------
// The typical navigation flow for services is:
// 1. ServicesScreen (main entry point)
// 2. Service List Screen (e.g., VenueListScreen)
// 3. Service Details Screen (e.g., VenueDetailsScreen)
// 4. Service Comparison Screen (optional)
// 5. Booking Form Screen (when ready to book)
