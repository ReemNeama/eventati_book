# Notification System Architecture

This document provides a detailed view of the notification system architecture in Eventati Book.

## Notification System Components

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

## UI Components

### NotificationBadge

The `NotificationBadge` widget displays a badge with the number of unread notifications in the app bar. When tapped, it shows the `NotificationCenter` dropdown.

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

The `NotificationCenter` widget displays a dropdown with recent notifications. It allows users to:
- View recent notifications
- Mark notifications as read
- Delete notifications
- Navigate to the full notification list

```dart
class NotificationCenter extends StatelessWidget {
  // ...
}
```

### NotificationListScreen

The `NotificationListScreen` displays all notifications for the user. It allows users to:
- View all notifications
- Mark notifications as read
- Delete notifications
- Pull to refresh notifications

```dart
class NotificationListScreen extends StatefulWidget {
  // ...
}
```

### NotificationPreferencesScreen

The `NotificationPreferencesScreen` allows users to manage their notification preferences:
- Enable/disable all notifications
- Configure notification channels (push, email, in-app)
- Configure notification topics (booking, payment, event, etc.)

```dart
class NotificationPreferencesScreen extends StatefulWidget {
  // ...
}
```

## State Management

### NotificationProvider

The `NotificationProvider` manages the notification state in the app:
- Loads notifications from the database
- Tracks unread notification count
- Provides methods to mark notifications as read
- Provides methods to delete notifications
- Subscribes to notification updates

```dart
class NotificationProvider extends ChangeNotifier {
  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _notifications.where((n) => !n.read).length;
  
  // ...
}
```

## Services

### NotificationService

The `NotificationService` is the main service for handling notification operations:
- Get notifications for the current user
- Mark notifications as read
- Delete notifications
- Create different types of notifications (booking, payment, etc.)

```dart
class NotificationService {
  Future<List<Notification>> getNotifications() async { ... }
  Future<List<Notification>> getUnreadNotifications() async { ... }
  Future<void> markAsRead(String notificationId) async { ... }
  Future<void> markAllAsRead() async { ... }
  Future<void> deleteNotification(String notificationId) async { ... }
  Future<void> createBookingConfirmationNotification(Booking booking) async { ... }
  // ...
}
```

### EmailService

The `EmailService` is responsible for sending email notifications:
- Send booking confirmation emails
- Send booking update emails
- Send booking reminder emails
- Send booking cancellation emails
- Send generic email notifications

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
- Schedule booking reminders
- Check for upcoming bookings and send reminders
- Cancel booking reminders

```dart
class ReminderService {
  Future<void> scheduleBookingReminders(Booking booking) async { ... }
  Future<void> checkAndSendBookingReminders() async { ... }
  Future<void> cancelBookingReminders(String bookingId) async { ... }
  // ...
}
```

## Database

### NotificationDatabaseService

The `NotificationDatabaseService` handles database operations for notifications:
- Get notifications for a user
- Get unread notifications for a user
- Create a new notification
- Mark a notification as read
- Mark all notifications as read
- Delete a notification
- Get a stream of notifications for a user

```dart
class NotificationDatabaseService {
  Future<List<Notification>> getNotifications(String userId) async { ... }
  Future<List<Notification>> getUnreadNotifications(String userId) async { ... }
  Future<String> createNotification(Notification notification) async { ... }
  Future<void> markAsRead(String notificationId) async { ... }
  Future<void> markAllAsRead(String userId) async { ... }
  Future<void> deleteNotification(String notificationId) async { ... }
  Stream<List<Notification>> getNotificationsStream(String userId) { ... }
  // ...
}
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

## Edge Functions

### send-email

The `send-email` Edge Function is responsible for sending email notifications:
- Connects to an SMTP server
- Sends emails to users
- Logs email sending status
- Handles authentication and authorization

```typescript
// Function code in supabase/functions/send-email/index.ts
```

## Integration with Other Systems

The notification system integrates with:
- **BookingService**: For sending booking-related notifications
- **PaymentService**: For sending payment-related notifications
- **EventService**: For sending event-related notifications
- **TaskService**: For sending task-related notifications
