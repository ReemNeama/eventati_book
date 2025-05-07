# Firebase Services

This directory contains all Firebase-related services for the Eventati Book application.

## Directory Structure

```
firebase/
├── core/                  # Core Firebase services
│   ├── firebase_analytics_service.dart
│   ├── firebase_crashlytics_service.dart
│   ├── firebase_messaging_service.dart
│   └── core.dart          # Barrel file for core services
├── firestore/             # Firestore services for different data types
│   ├── booking_firestore_service.dart
│   ├── budget_firestore_service.dart
│   ├── event_firestore_service.dart
│   ├── guest_firestore_service.dart
│   ├── service_firestore_service.dart
│   ├── task_firestore_service.dart
│   ├── user_firestore_service.dart
│   └── firestore.dart     # Barrel file for Firestore services
├── utils/                 # Utility services
│   ├── data_migration_service.dart
│   ├── firestore_service.dart
│   └── utils.dart         # Barrel file for utility services
├── firebase.dart          # Main barrel file for all Firebase services
└── README.md              # This file
```

## Usage

Import the main barrel file to access all Firebase services:

```dart
import 'package:eventati_book/services/firebase/firebase.dart';
```

Or import specific service categories:

```dart
// Import only core services
import 'package:eventati_book/services/firebase/core/core.dart';

// Import only Firestore services
import 'package:eventati_book/services/firebase/firestore/firestore.dart';

// Import only utility services
import 'package:eventati_book/services/firebase/utils/utils.dart';
```

## Service Categories

### Core Services

Core Firebase services handle fundamental Firebase functionality:

- **FirebaseAnalyticsService**: Tracks user events and app usage
- **FirebaseCrashlyticsService**: Handles crash reporting and error logging
- **FirebaseMessagingService**: Manages push notifications and messaging

### Firestore Services

Firestore services handle data operations for specific data types:

- **BookingFirestoreService**: Manages booking data
- **BudgetFirestoreService**: Manages budget data
- **EventFirestoreService**: Manages event data
- **GuestFirestoreService**: Manages guest data
- **ServiceFirestoreService**: Manages service provider data
- **TaskFirestoreService**: Manages task data
- **UserFirestoreService**: Manages user data

### Utility Services

Utility services provide supporting functionality:

- **DataMigrationService**: Handles data migration and sample data creation
- **FirestoreService**: Provides common Firestore operations used by other services
