# Providers Directory

This directory contains all the state management providers used in the Eventati Book application.

## Organization

The providers are organized into the following subfolders for better maintainability:

- **core_providers/**: Core providers that don't depend on other providers
  - auth_provider.dart: Authentication state management
  - wizard_provider.dart: Event wizard state management

- **feature_providers/**: Providers that add specific features to the application
  - milestone_provider.dart: Milestone and achievement tracking
  - suggestion_provider.dart: Suggestions based on wizard state
  - service_recommendation_provider.dart: Service recommendations
  - comparison_provider.dart: Service comparison
  - comparison_saving_provider.dart: Saved comparisons

- **planning_providers/**: Providers related to event planning tools
  - budget_provider.dart: Budget management
  - guest_list_provider.dart: Guest list management
  - messaging_provider.dart: Vendor messaging
  - task_provider.dart: Tasks and checklists
  - booking_provider.dart: Service bookings

## Usage

Import the main barrel file to access all providers:

```dart
import 'package:eventati_book/providers/providers.dart';

// Now you can use any provider
final authProvider = Provider.of<AuthProvider>(context);
```

## Usage Guidelines

Always use the main barrel file for imports to ensure consistent access to providers throughout the application.
