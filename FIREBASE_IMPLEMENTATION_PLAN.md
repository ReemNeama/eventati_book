# Firebase Implementation Plan for Eventati Book

This document outlines the plan for implementing Firebase as the backend for the Eventati Book application. It includes the files that need to be modified or created, dependencies to add, and implementation steps.

## Keeping This Plan Updated

**IMPORTANT**: As the project evolves, please keep this plan up-to-date by following these guidelines:

1. **When adding new files to the project**:
   - Add them to the appropriate section in "Files to Modify or Create"
   - Note any Firebase-related functionality they will need

2. **When modifying existing files**:
   - If the changes affect how data is stored or accessed, update the relevant sections

3. **When adding new features**:
   - Consider how they will interact with Firebase
   - Update the data structure sections as needed
   - Add any new security rules that might be required

4. **When planning sprints**:
   - Review this document to identify Firebase-related tasks that should be included

This will ensure a smooth transition to Firebase when the project is ready for backend integration.

## Firebase Services to Implement

1. **Firebase Authentication** - For user authentication
2. **Cloud Firestore** - For storing and syncing data
3. **Firebase Storage** - For storing images and files
4. **Firebase Cloud Messaging** - For push notifications
5. **Firebase Analytics** - For tracking user behavior
6. **Firebase Crashlytics** - For crash reporting

## Files to Modify or Create

### 1. Firebase Authentication

**Files to Create:**
- `lib/services/firebase_auth_service.dart` - Service for handling Firebase authentication
- `lib/services/auth_service_interface.dart` - Interface for authentication services (for dependency injection)

**Files to Modify:**
- `lib/providers/auth_provider.dart` - Update to use Firebase Auth instead of local auth
- `lib/screens/authentications/login_screen.dart` - Update to use Firebase Auth
- `lib/screens/authentications/register_screen.dart` - Update to use Firebase Auth
- `lib/screens/authentications/forgetpassword_screen.dart` - Update to use Firebase password reset
- `lib/screens/authentications/verification_screen.dart` - Update for email verification
- `lib/main.dart` - Initialize Firebase Auth

### 2. Cloud Firestore

**Files to Create:**
- `lib/services/firestore_service.dart` - Service for Firestore operations
- `lib/services/database_service_interface.dart` - Interface for database services

**Files to Modify:**
- `lib/providers/wizard_provider.dart` - Update to use Firestore for wizard state
- `lib/providers/milestone_provider.dart` - Update to use Firestore for milestones
- `lib/providers/guest_list_provider.dart` - Update to use Firestore for guest list
- `lib/providers/budget_provider.dart` - Update to use Firestore for budget items
- `lib/providers/task_provider.dart` - Update to use Firestore for tasks
- `lib/providers/vendor_message_provider.dart` - Update to use Firestore for messages
- `lib/providers/suggestion_provider.dart` - Update to use Firestore for suggestions
- Replace all `lib/tempDB/*.dart` files with Firestore implementations

### 3. Firebase Storage

**Files to Create:**
- `lib/services/firebase_storage_service.dart` - Service for Firebase Storage operations

**Files to Modify:**
- `lib/utils/file_utils.dart` - Update to use Firebase Storage
- `lib/screens/profile/profile_screen.dart` - Update profile image upload
- `lib/widgets/event_planning/guest_list/guest_form_screen.dart` - Update for guest photo uploads
- Any screens that handle file uploads

### 4. Firebase Cloud Messaging

**Files to Create:**
- `lib/services/firebase_messaging_service.dart` - Service for FCM operations
- `lib/services/notification_service.dart` - Service for handling notifications

**Files to Modify:**
- `lib/main.dart` - Initialize FCM
- `lib/providers/notification_provider.dart` - Update to use FCM
- `lib/screens/profile/notification_settings_screen.dart` - Add FCM token management

### 5. Firebase Analytics

**Files to Create:**
- `lib/services/analytics_service.dart` - Service for analytics operations

**Files to Modify:**
- `lib/utils/analytics_utils.dart` - Update to use Firebase Analytics
- `lib/main.dart` - Initialize Firebase Analytics
- Various screen files to add analytics events

### 6. Firebase Crashlytics

**Files to Create:**
- `lib/services/crashlytics_service.dart` - Service for Crashlytics operations

**Files to Modify:**
- `lib/main.dart` - Initialize Crashlytics and set up error handling
- `lib/utils/error_utils.dart` - Update to report errors to Crashlytics

## Implementation Steps

### 1. Setup Firebase Project

- [ ] Create a new Firebase project in the Firebase Console
- [ ] Register the Android app
  - [ ] Package name: com.example.eventati_book (update with your actual package name)
  - [ ] Download google-services.json to android/app/
- [ ] Register the iOS app
  - [ ] Bundle ID: com.example.eventatiBook (update with your actual bundle ID)
  - [ ] Download GoogleService-Info.plist to ios/Runner/
- [ ] Configure Firebase project settings
  - [ ] Set up Authentication providers (Email/Password, Google, etc.)
  - [ ] Create Firestore database
  - [ ] Set up Storage buckets
  - [ ] Configure FCM

### 2. Add Firebase Dependencies

- [ ] Update pubspec.yaml to include Firebase dependencies:

```yaml
dependencies:
  # Firebase Core
  firebase_core: ^latest_version

  # Authentication
  firebase_auth: ^latest_version
  google_sign_in: ^latest_version  # For Google Sign-In (if needed)
  flutter_facebook_auth: ^latest_version  # For Facebook Login (if needed)
  sign_in_with_apple: ^latest_version  # For Apple Sign-In (if needed)

  # Database
  cloud_firestore: ^latest_version

  # Storage
  firebase_storage: ^latest_version

  # Messaging
  firebase_messaging: ^latest_version
  flutter_local_notifications: ^latest_version  # For handling notifications

  # Analytics
  firebase_analytics: ^latest_version

  # Crashlytics
  firebase_crashlytics: ^latest_version

  # Other Firebase services (as needed)
  firebase_remote_config: ^latest_version  # For remote configuration
  firebase_performance: ^latest_version  # For performance monitoring
```

- [ ] Run `flutter pub get` to install dependencies

### 3. Initialize Firebase

- [ ] Update `lib/main.dart` to initialize Firebase:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Initialize other Firebase services

  runApp(MyApp());
}
```

### 4. Implement Authentication

- [ ] Create `lib/services/auth_service_interface.dart` with authentication methods
- [ ] Create `lib/services/firebase_auth_service.dart` implementing the interface
- [ ] Update `lib/providers/auth_provider.dart` to use Firebase Auth
- [ ] Update authentication screens to use Firebase Auth
- [ ] Implement email verification
- [ ] Implement password reset
- [ ] Add social authentication (if needed)

### 5. Implement Firestore

- [ ] Create `lib/services/database_service_interface.dart` with database methods
- [ ] Create `lib/services/firestore_service.dart` implementing the interface
- [ ] Define Firestore collections and document structures:

```
users/
  {userId}/
    profile: { name, email, ... }
    settings: { theme, notifications, ... }
    custom_suggestions/
      {suggestionId}: {
        id: string,
        title: string,
        description: string,
        category: string,
        priority: string,
        baseRelevanceScore: number,
        conditions: array,
        applicableEventTypes: array,
        imageUrl: string (optional),
        actionUrl: string (optional),
        isCustom: boolean,
        createdAt: timestamp,
        updatedAt: timestamp
      }

events/
  {eventId}/
    details: { name, date, type, ... }
    wizard_state: { ... }
    milestones: [ ... ]
    budget/
      {budgetItemId}: { ... }
    guests/
      {guestId}: { ... }
    tasks/
      {taskId}: { ... }
    messages/
      {messageId}: { ... }
    suggestions/
      {suggestionId}: { ... }
    saved_comparisons/
      {comparisonId}: {
        id: string,
        userId: string,
        serviceType: string,
        serviceIds: array,
        serviceNames: array,
        createdAt: timestamp,
        title: string,
        notes: string,
        eventId: string (optional),
        eventName: string (optional)
      }

services/
  venues/
    {venueId}: { ... }
  caterers/
    {catererId}: { ... }
  photographers/
    {photographerId}: { ... }
  planners/
    {plannerId}: { ... }
```

- [ ] Update providers to use Firestore
- [ ] Implement data migration from local storage to Firestore
- [ ] Add offline support and caching

### 6. Implement Storage

- [ ] Create `lib/services/firebase_storage_service.dart`
- [ ] Define storage structure:

```
users/{userId}/profile_image
events/{eventId}/images/{imageId}
guests/{eventId}/{guestId}/photo
```

- [ ] Update file utils to use Firebase Storage
- [ ] Implement image upload and download functionality
- [ ] Add progress tracking for uploads

### 7. Implement Cloud Messaging

- [ ] Create `lib/services/firebase_messaging_service.dart`
- [ ] Create `lib/services/notification_service.dart`
- [ ] Configure FCM in main.dart
- [ ] Implement notification handling
- [ ] Add notification settings
- [ ] Create notification topics for different event types

### 8. Implement Analytics and Crashlytics

- [ ] Create `lib/services/analytics_service.dart`
- [ ] Create `lib/services/crashlytics_service.dart`
- [ ] Update `lib/utils/analytics_utils.dart` to use Firebase Analytics
- [ ] Add analytics events to key user actions
- [ ] Configure error reporting with Crashlytics

## Data Migration Strategy

### 1. User Data

- [ ] Create a migration service to move local user data to Firebase
- [ ] Implement data validation and conflict resolution
- [ ] Add progress tracking for migration

### 2. Event Data

- [ ] Define Firestore collections for events
- [ ] Create migration scripts for event data
- [ ] Implement synchronization for offline support

### 3. Service Data

- [ ] Define Firestore collections for services
- [ ] Create admin tools for service data management
- [ ] Implement caching for frequently accessed data

### 4. Planning Tools Data

- [ ] Define Firestore collections for budget, guest list, timeline, etc.
- [ ] Implement real-time updates for collaborative features
- [ ] Create backup and restore functionality

## Security Rules

### 1. Authentication Rules

- [ ] Define rules for user authentication
- [ ] Implement email verification requirements

### 2. Firestore Rules

- [ ] Define rules for data access and modification:

```
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Events can only be accessed by their owners
    match /events/{eventId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;

      // Nested collections follow the same rules
      match /{document=**} {
        allow read, write: if request.auth != null && get(/databases/$(database)/documents/events/$(eventId)).data.userId == request.auth.uid;
      }
    }

    // Services are readable by all authenticated users
    match /services/{serviceType}/{serviceId} {
      allow read: if request.auth != null;
      allow write: if false;  // Only admins can write (via Admin SDK)
    }
  }
}
```

### 3. Storage Rules

- [ ] Define rules for file uploads and downloads:

```
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /users/{userId}/profile_image {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Event images
    match /events/{eventId}/{allPaths=**} {
      allow read, write: if request.auth != null &&
        firestore.get(/databases/(default)/documents/events/$(eventId)).data.userId == request.auth.uid;
    }
  }
}
```

## Testing Strategy

### 1. Unit Tests

- [ ] Create tests for Firebase services
- [ ] Mock Firebase services for testing

### 2. Integration Tests

- [ ] Test Firebase integration with the app
- [ ] Verify data synchronization

### 3. Security Tests

- [ ] Test security rules
- [ ] Verify authentication flows

## Performance Considerations

- [ ] Implement efficient queries with proper indexing
- [ ] Use Firebase Performance Monitoring
- [ ] Implement caching for frequently accessed data
- [ ] Optimize image uploads and downloads
- [ ] Implement pagination for large data sets

## Tracking New Files

As new files are added to the project, record them here if they will need Firebase integration:

| File Path | Firebase Service Needed | Description |
|-----------|------------------------|-------------|
| lib/screens/event_wizard/create_suggestion_screen.dart | Firestore | Screen for creating custom suggestions |
| lib/widgets/event_wizard/suggestion_card.dart | Firestore | Card widget for displaying suggestions with custom indicator |
| lib/providers/suggestion_provider.dart | Firestore | Provider for managing suggestions, including custom suggestions persistence |
| lib/models/saved_comparison.dart | Firestore | Model for saved service comparisons |
| lib/providers/comparison_saving_provider.dart | Firestore | Provider for managing saved comparisons |
| lib/screens/services/saved_comparisons_screen.dart | Firestore | Screen for viewing and managing saved comparisons |
| | | |

This table helps track new files that will need Firebase integration but aren't yet included in the main sections above.

## Deployment Checklist

- [ ] Verify all Firebase services are properly configured
- [ ] Test authentication flows
- [ ] Verify data synchronization
- [ ] Test offline functionality
- [ ] Check security rules
- [ ] Monitor analytics and crash reports
- [ ] Set up Firebase App Distribution for beta testing

## Resources

- [Firebase Flutter Documentation](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

## Change Log

Keep track of significant updates to this plan:

| Date | Description of Change | Updated By |
|------|----------------------|------------|
| June 10, 2023 | Initial creation of Firebase implementation plan | Eventati Book Team |
| July 15, 2023 | Added custom suggestion creation files | Eventati Book Team |
| July 16, 2023 | Updated Firestore structure to include custom suggestions at user level | Eventati Book Team |
| July 20, 2023 | Added saved comparison feature files | Eventati Book Team |
| | | |

This change log helps track the evolution of the Firebase implementation plan and ensures everyone is aware of the latest changes.
