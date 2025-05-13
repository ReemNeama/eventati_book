import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/services/interfaces/messaging_service_interface.dart';
import 'package:eventati_book/services/notification/email_service.dart';
import 'package:eventati_book/services/notification/notification_service.dart';
import 'package:eventati_book/services/supabase/database/booking_database_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling reminders
class ReminderService {
  /// Supabase client
  final SupabaseClient _supabase;
  
  /// Booking database service
  final BookingDatabaseService _bookingDatabaseService;
  
  /// Notification service
  final NotificationService _notificationService;
  
  /// Email service
  final EmailService _emailService;
  
  /// Messaging service
  final MessagingServiceInterface _messagingService;
  
  /// Constructor
  ReminderService({
    SupabaseClient? supabase,
    BookingDatabaseService? bookingDatabaseService,
    NotificationService? notificationService,
    EmailService? emailService,
    MessagingServiceInterface? messagingService,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _bookingDatabaseService = bookingDatabaseService ?? BookingDatabaseService(),
       _notificationService = notificationService ?? NotificationService(
         messagingService: messagingService ?? throw ArgumentError('Messaging service is required'),
       ),
       _emailService = emailService ?? EmailService(),
       _messagingService = messagingService ?? throw ArgumentError('Messaging service is required');
  
  /// Schedule reminders for a booking
  Future<void> scheduleBookingReminders(Booking booking) async {
    try {
      // Get the current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Schedule reminders at different intervals
      await _scheduleBookingReminder(booking, 7); // 7 days before
      await _scheduleBookingReminder(booking, 3); // 3 days before
      await _scheduleBookingReminder(booking, 1); // 1 day before
      
      Logger.i('Booking reminders scheduled for booking ${booking.id}', tag: 'ReminderService');
    } catch (e) {
      Logger.e('Error scheduling booking reminders: $e', tag: 'ReminderService');
    }
  }
  
  /// Schedule a booking reminder for a specific number of days before the event
  Future<void> _scheduleBookingReminder(Booking booking, int daysBeforeEvent) async {
    try {
      // Calculate the reminder date
      final reminderDate = booking.bookingDateTime.subtract(Duration(days: daysBeforeEvent));
      
      // Skip if the reminder date is in the past
      if (reminderDate.isBefore(DateTime.now())) {
        Logger.i('Skipping reminder for booking ${booking.id} as reminder date is in the past', tag: 'ReminderService');
        return;
      }
      
      // Create a unique ID for the reminder
      final reminderId = '${booking.id}_${daysBeforeEvent}days';
      
      // Schedule the local notification
      await _messagingService.scheduleNotification(
        id: reminderId.hashCode,
        title: 'Upcoming Booking Reminder',
        body: 'Your booking for ${booking.serviceName} is in $daysBeforeEvent ${daysBeforeEvent == 1 ? 'day' : 'days'} on ${_formatDate(booking.bookingDateTime)}.',
        scheduledDate: reminderDate,
        payload: booking.id,
      );
      
      Logger.i('Scheduled reminder for booking ${booking.id} $daysBeforeEvent days before', tag: 'ReminderService');
    } catch (e) {
      Logger.e('Error scheduling booking reminder: $e', tag: 'ReminderService');
    }
  }
  
  /// Check for upcoming bookings and send reminders
  Future<void> checkAndSendBookingReminders() async {
    try {
      // Get the current user ID
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // Get all upcoming bookings for the user
      final bookings = await _bookingDatabaseService.getUpcomingBookings(userId);
      
      // Process each booking
      for (final booking in bookings) {
        // Calculate days until the booking
        final daysUntilBooking = booking.bookingDateTime.difference(DateTime.now()).inDays;
        
        // Send reminders based on the days until booking
        if (daysUntilBooking == 7 || daysUntilBooking == 3 || daysUntilBooking == 1) {
          // Create notification
          await _notificationService.createBookingReminderNotification(booking, daysUntilBooking);
          
          // Send email reminder
          await _emailService.sendBookingReminderEmail(booking, daysUntilBooking);
          
          Logger.i('Sent reminder for booking ${booking.id} $daysUntilBooking days before', tag: 'ReminderService');
        }
      }
    } catch (e) {
      Logger.e('Error checking and sending booking reminders: $e', tag: 'ReminderService');
    }
  }
  
  /// Cancel reminders for a booking
  Future<void> cancelBookingReminders(String bookingId) async {
    try {
      // Cancel reminders at different intervals
      await _cancelBookingReminder(bookingId, 7);
      await _cancelBookingReminder(bookingId, 3);
      await _cancelBookingReminder(bookingId, 1);
      
      Logger.i('Booking reminders cancelled for booking $bookingId', tag: 'ReminderService');
    } catch (e) {
      Logger.e('Error cancelling booking reminders: $e', tag: 'ReminderService');
    }
  }
  
  /// Cancel a booking reminder for a specific number of days before the event
  Future<void> _cancelBookingReminder(String bookingId, int daysBeforeEvent) async {
    try {
      // Create a unique ID for the reminder
      final reminderId = '${bookingId}_${daysBeforeEvent}days';
      
      // Cancel the local notification
      await _messagingService.cancelNotification(reminderId.hashCode);
      
      Logger.i('Cancelled reminder for booking $bookingId $daysBeforeEvent days before', tag: 'ReminderService');
    } catch (e) {
      Logger.e('Error cancelling booking reminder: $e', tag: 'ReminderService');
    }
  }
  
  /// Format a date for display in notifications
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year at $hour:$minute';
  }
}
