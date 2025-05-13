# Notification System

This directory contains the implementation of the notification system for Eventati Book.

## Overview

The notification system provides a way to send and manage notifications to users. It supports:

- In-app notifications
- Email notifications
- Push notifications (via Firebase Cloud Messaging)
- Scheduled reminders

## Components

### Services

- **NotificationService**: Main service for handling notification operations
- **EmailService**: Service for sending email notifications
- **ReminderService**: Service for scheduling and sending reminders

### Database

- **NotificationDatabaseService**: Service for handling database operations for notifications

### Models

- **Notification**: Model representing a notification
- **NotificationSettings**: Model representing user notification preferences
- **NotificationTopic**: Model representing notification topics

### UI Components

- **NotificationBadge**: Widget for displaying a badge with unread notification count
- **NotificationCenter**: Widget for displaying notifications in a dropdown
- **NotificationListScreen**: Screen for displaying all notifications
- **NotificationPreferencesScreen**: Screen for managing notification settings

## Database Schema

The notification system uses the following tables in Supabase:

- **notifications**: Stores all notifications
- **user_notification_settings**: Stores user notification preferences
- **email_logs**: Logs all email notifications sent

## Usage

### Sending a Notification

```dart
// Create a notification
final notification = Notification(
  userId: userId,
  title: 'Booking Confirmed',
  body: 'Your booking has been confirmed.',
  type: NotificationType.bookingConfirmation,
  data: {
    'bookingId': booking.id,
  },
  relatedEntityId: booking.id,
);

// Send the notification
await notificationService.createNotification(notification);
```

### Scheduling a Reminder

```dart
// Schedule a reminder for a booking
await reminderService.scheduleBookingReminders(booking);
```

### Sending an Email

```dart
// Send a booking confirmation email
await emailService.sendBookingConfirmationEmail(booking);
```

## Edge Functions

The notification system uses the following Supabase Edge Functions:

- **send-email**: Function for sending email notifications

## Integration with Other Systems

The notification system integrates with:

- **BookingService**: For sending booking-related notifications
- **PaymentService**: For sending payment-related notifications
- **EventService**: For sending event-related notifications
- **TaskService**: For sending task-related notifications

## Future Improvements

- Add support for SMS notifications
- Implement notification templates
- Add support for rich notifications with images and actions
- Implement notification analytics
- Add support for notification categories and filtering
