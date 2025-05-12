# Supabase Services

This directory contains services for interacting with Supabase backend.

## Structure

```
supabase/
├── core/                  # Core Supabase services
│   ├── supabase_auth_service.dart
│   ├── custom_analytics_service.dart
│   ├── posthog_crashlytics_service.dart
│   ├── custom_messaging_service.dart
│   ├── supabase_storage_service.dart
│   └── core.dart          # Barrel file for core services
├── database/              # Database services for different data types
│   ├── booking_database_service.dart
│   ├── budget_database_service.dart
│   ├── event_database_service.dart
│   ├── guest_database_service.dart
│   ├── service_database_service.dart
│   ├── task_database_service.dart
│   ├── user_database_service.dart
│   └── database.dart      # Barrel file for database services
├── utils/                 # Utility services
│   ├── database_service.dart
│   └── utils.dart         # Barrel file for utility services
├── supabase.dart          # Main barrel file for all Supabase services
└── README.md              # This file
```

## Usage

Import the main barrel file to access all Supabase services:

```dart
import 'package:eventati_book/services/supabase/supabase.dart';
```

Or import specific service categories:

```dart
// Import only core services
import 'package:eventati_book/services/supabase/core/core.dart';

// Import only database services
import 'package:eventati_book/services/supabase/database/database.dart';

// Import only utility services
import 'package:eventati_book/services/supabase/utils/utils.dart';
```

## Service Categories

### Core Services

Core Supabase services handle fundamental functionality:

- **SupabaseAuthService**: Handles authentication using Supabase Auth
- **CustomAnalyticsService**: Tracks user events and app usage
- **PostHogCrashlyticsService**: Handles crash reporting and error logging
- **CustomMessagingService**: Manages notifications and messaging
- **SupabaseStorageService**: Handles file storage and retrieval

### Database Services

Database services handle data operations for specific data types:

- **BookingDatabaseService**: Manages booking data
- **BudgetDatabaseService**: Manages budget data
- **EventDatabaseService**: Manages event data
- **GuestDatabaseService**: Manages guest data
- **ServiceDatabaseService**: Manages service provider data
- **TaskDatabaseService**: Manages task data
- **UserDatabaseService**: Manages user data

### Utility Services

Utility services provide common functionality:

- **DatabaseService**: Base service for database operations
