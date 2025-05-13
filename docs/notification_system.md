# Notification System

This document provides an overview of the notification system in Eventati Book.

## Overview

The notification system provides a way to send and manage notifications to users. It supports:

- In-app notifications
- Email notifications
- Push notifications
- Scheduled reminders

## Architecture

The notification system follows a layered architecture:

1. **UI Layer**: Widgets and screens for displaying and managing notifications
2. **State Management Layer**: Providers for managing notification state
3. **Service Layer**: Services for handling notification operations
4. **Database Layer**: Services for handling database operations

### Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                           UI Layer                              │
│                                                                 │
│  ┌───────────────────┐  ┌────────────────────┐  ┌────────────┐  │
│  │  NotificationBadge│  │  NotificationCenter│  │ Screens    │  │
│  └───────────────────┘  └────────────────────┘  └────────────┘  │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    State Management Layer                       │
│                                                                 │
│                  ┌───────────────────────┐                      │
│                  │  NotificationProvider │                      │
│                  └───────────────────────┘                      │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                         Service Layer                           │
│                                                                 │
│  ┌───────────────────┐  ┌────────────────────┐  ┌────────────┐  │
│  │ NotificationService│ │    EmailService    │  │ReminderSvc │  │
│  └───────────────────┘  └────────────────────┘  └────────────┘  │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Database Layer                           │
│                                                                 │
│              ┌───────────────────────────────────┐              │
│              │    NotificationDatabaseService    │              │
│              └───────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────────┘
```

## Data Models

### Notification

The `Notification` model represents a notification in the system:

```dart
class Notification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;
  final String? relatedEntityId;
  
  // ...
}
```

### NotificationType

The `NotificationType` enum represents the different types of notifications:

```dart
enum NotificationType {
  bookingConfirmation,
  bookingUpdate,
  bookingReminder,
  bookingCancellation,
  paymentConfirmation,
  paymentReminder,
  eventReminder,
  taskReminder,
  system,
  marketing,
}
```

### NotificationSettings

The `NotificationSettings` model represents user notification preferences:

```dart
class NotificationSettings {
  final bool allNotificationsEnabled;
  final Map<String, bool> topicSettings;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool inAppNotificationsEnabled;
  
  // ...
}
```

## Database Schema

The notification system uses the following tables in Supabase:

### notifications

Stores all notifications:

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type INTEGER NOT NULL,
  data JSONB,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  related_entity_id TEXT
);
```

### user_notification_settings

Stores user notification preferences:

```sql
CREATE TABLE user_notification_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  all_notifications_enabled BOOLEAN DEFAULT TRUE,
  topic_settings JSONB DEFAULT '{}',
  push_notifications_enabled BOOLEAN DEFAULT TRUE,
  email_notifications_enabled BOOLEAN DEFAULT TRUE,
  in_app_notifications_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### email_logs

Logs all email notifications sent:

```sql
CREATE TABLE email_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient TEXT NOT NULL,
  subject TEXT NOT NULL,
  status TEXT NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  error_message TEXT
);
```

## Services

### NotificationService

The `NotificationService` is the main service for handling notification operations:

```dart
class NotificationService {
  Future<List<Notification>> getNotifications() async { ... }
  Future<List<Notification>> getUnreadNotifications() async { ... }
  Future<void> markAsRead(String notificationId) async { ... }
  Future<void> markAllAsRead() async { ... }
  Future<void> deleteNotification(String notificationId) async { ... }
  Future<void> createBookingConfirmationNotification(Booking booking) async { ... }
  Future<void> createBookingReminderNotification(Booking booking, int daysBeforeEvent) async { ... }
  // ...
}
```

### EmailService

The `EmailService` is responsible for sending email notifications:

```dart
class EmailService {
  Future<void> sendBookingConfirmationEmail(Booking booking) async { ... }
  Future<void> sendBookingUpdateEmail(Booking booking, String updateMessage) async { ... }
  Future<void> sendBookingReminderEmail(Booking booking, int daysBeforeEvent) async { ... }
  Future<void> sendBookingCancellationEmail(Booking booking) async { ... }
  Future<void> sendEmailNotification({...}) async { ... }
  // ...
}
```

### ReminderService

The `ReminderService` is responsible for scheduling and sending reminders:

```dart
class ReminderService {
  Future<void> scheduleBookingReminders(Booking booking) async { ... }
  Future<void> checkAndSendBookingReminders() async { ... }
  Future<void> cancelBookingReminders(String bookingId) async { ... }
  // ...
}
```

## UI Components

### NotificationBadge

The `NotificationBadge` widget displays a badge with the number of unread notifications:

```dart
class NotificationBadge extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final Color? iconColor;
  final Color? badgeColor;
  
  // ...
}
```

### NotificationCenter

The `NotificationCenter` widget displays a dropdown with recent notifications:

```dart
class NotificationCenter extends StatelessWidget {
  // ...
}
```

### NotificationListScreen

The `NotificationListScreen` displays all notifications for the user:

```dart
class NotificationListScreen extends StatefulWidget {
  // ...
}
```

### NotificationPreferencesScreen

The `NotificationPreferencesScreen` allows users to manage their notification preferences:

```dart
class NotificationPreferencesScreen extends StatefulWidget {
  // ...
}
```

## Integration with Other Systems

The notification system integrates with:

- **BookingService**: For sending booking-related notifications
- **PaymentService**: For sending payment-related notifications
- **EventService**: For sending event-related notifications
- **TaskService**: For sending task-related notifications

## Edge Functions

The notification system uses the following Supabase Edge Functions:

### send-email

Function for sending email notifications:

```typescript
// Function code in supabase/functions/send-email/index.ts
```

## Testing

The notification system is thoroughly tested with:

- Unit tests for models and services
- Widget tests for UI components
- Integration tests for critical flows

## Future Improvements

- Add support for SMS notifications
- Implement notification templates
- Add support for rich notifications with images and actions
- Implement notification analytics
- Add support for notification categories and filtering
