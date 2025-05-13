import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/services/supabase/database/user_database_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling email notifications
class EmailService {
  /// Supabase client
  final SupabaseClient _supabase;
  
  /// User database service
  final UserDatabaseService _userDatabaseService;
  
  /// Constructor
  EmailService({
    SupabaseClient? supabase,
    UserDatabaseService? userDatabaseService,
  }) : _supabase = supabase ?? Supabase.instance.client,
       _userDatabaseService = userDatabaseService ?? UserDatabaseService();
  
  /// Send a booking confirmation email
  Future<void> sendBookingConfirmationEmail(Booking booking) async {
    try {
      final user = await _userDatabaseService.getUser(booking.userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('User email not found');
      }
      
      // Format the booking date and time
      final formattedDate = _formatDate(booking.bookingDateTime);
      
      // Create email content
      final subject = 'Booking Confirmation - ${booking.serviceName}';
      final content = '''
        <h1>Booking Confirmation</h1>
        <p>Dear ${user.displayName ?? 'Valued Customer'},</p>
        <p>Your booking for <strong>${booking.serviceName}</strong> has been confirmed.</p>
        <p><strong>Date and Time:</strong> $formattedDate</p>
        <p><strong>Duration:</strong> ${booking.duration} hours</p>
        <p><strong>Total Price:</strong> \$${booking.totalPrice.toStringAsFixed(2)}</p>
        <p>Thank you for choosing Eventati Book!</p>
        <p>If you have any questions or need to make changes to your booking, please contact us.</p>
        <p>Best regards,<br>The Eventati Book Team</p>
      ''';
      
      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);
      
      Logger.i('Booking confirmation email sent to $email', tag: 'EmailService');
    } catch (e) {
      Logger.e('Error sending booking confirmation email: $e', tag: 'EmailService');
    }
  }
  
  /// Send a booking update email
  Future<void> sendBookingUpdateEmail(Booking booking, String updateMessage) async {
    try {
      final user = await _userDatabaseService.getUser(booking.userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('User email not found');
      }
      
      // Format the booking date and time
      final formattedDate = _formatDate(booking.bookingDateTime);
      
      // Create email content
      final subject = 'Booking Update - ${booking.serviceName}';
      final content = '''
        <h1>Booking Update</h1>
        <p>Dear ${user.displayName ?? 'Valued Customer'},</p>
        <p>Your booking for <strong>${booking.serviceName}</strong> has been updated.</p>
        <p><strong>Update:</strong> $updateMessage</p>
        <p><strong>Date and Time:</strong> $formattedDate</p>
        <p><strong>Duration:</strong> ${booking.duration} hours</p>
        <p><strong>Total Price:</strong> \$${booking.totalPrice.toStringAsFixed(2)}</p>
        <p>If you have any questions or concerns about this update, please contact us.</p>
        <p>Best regards,<br>The Eventati Book Team</p>
      ''';
      
      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);
      
      Logger.i('Booking update email sent to $email', tag: 'EmailService');
    } catch (e) {
      Logger.e('Error sending booking update email: $e', tag: 'EmailService');
    }
  }
  
  /// Send a booking reminder email
  Future<void> sendBookingReminderEmail(Booking booking, int daysBeforeEvent) async {
    try {
      final user = await _userDatabaseService.getUser(booking.userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('User email not found');
      }
      
      // Format the booking date and time
      final formattedDate = _formatDate(booking.bookingDateTime);
      
      // Create email content
      final subject = 'Reminder: Upcoming Booking - ${booking.serviceName}';
      final content = '''
        <h1>Booking Reminder</h1>
        <p>Dear ${user.displayName ?? 'Valued Customer'},</p>
        <p>This is a reminder that your booking for <strong>${booking.serviceName}</strong> is in $daysBeforeEvent ${daysBeforeEvent == 1 ? 'day' : 'days'}.</p>
        <p><strong>Date and Time:</strong> $formattedDate</p>
        <p><strong>Duration:</strong> ${booking.duration} hours</p>
        <p><strong>Location:</strong> ${booking.data?['location'] ?? 'Not specified'}</p>
        <p>We look forward to seeing you!</p>
        <p>If you need to make any changes to your booking, please contact us as soon as possible.</p>
        <p>Best regards,<br>The Eventati Book Team</p>
      ''';
      
      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);
      
      Logger.i('Booking reminder email sent to $email', tag: 'EmailService');
    } catch (e) {
      Logger.e('Error sending booking reminder email: $e', tag: 'EmailService');
    }
  }
  
  /// Send a booking cancellation email
  Future<void> sendBookingCancellationEmail(Booking booking) async {
    try {
      final user = await _userDatabaseService.getUser(booking.userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('User email not found');
      }
      
      // Format the booking date and time
      final formattedDate = _formatDate(booking.bookingDateTime);
      
      // Create email content
      final subject = 'Booking Cancellation - ${booking.serviceName}';
      final content = '''
        <h1>Booking Cancellation</h1>
        <p>Dear ${user.displayName ?? 'Valued Customer'},</p>
        <p>Your booking for <strong>${booking.serviceName}</strong> on $formattedDate has been cancelled.</p>
        <p>If you did not request this cancellation or have any questions, please contact us.</p>
        <p>Best regards,<br>The Eventati Book Team</p>
      ''';
      
      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);
      
      Logger.i('Booking cancellation email sent to $email', tag: 'EmailService');
    } catch (e) {
      Logger.e('Error sending booking cancellation email: $e', tag: 'EmailService');
    }
  }
  
  /// Send a generic email notification
  Future<void> sendEmailNotification({
    required String userId,
    required String subject,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final user = await _userDatabaseService.getUser(userId);
      if (user == null) {
        throw Exception('User not found');
      }
      
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('User email not found');
      }
      
      // Create email content
      final content = '''
        <h1>$subject</h1>
        <p>Dear ${user.displayName ?? 'Valued Customer'},</p>
        <p>$body</p>
        <p>Best regards,<br>The Eventati Book Team</p>
      ''';
      
      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);
      
      Logger.i('Email notification sent to $email: $subject', tag: 'EmailService');
    } catch (e) {
      Logger.e('Error sending email notification: $e', tag: 'EmailService');
    }
  }
  
  /// Format a date for display in emails
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year at $hour:$minute';
  }
  
  /// Send an email using Supabase Edge Function
  Future<void> _sendEmail(String to, String subject, String htmlContent) async {
    try {
      // Call the Supabase Edge Function to send the email
      final response = await _supabase.functions.invoke(
        'send-email',
        body: {
          'to': to,
          'subject': subject,
          'html': htmlContent,
        },
      );
      
      if (response.status != 200) {
        throw Exception('Failed to send email: ${response.data}');
      }
      
      Logger.i('Email sent successfully to $to', tag: 'EmailService');
    } catch (e) {
      Logger.e('Error sending email: $e', tag: 'EmailService');
      throw Exception('Failed to send email: $e');
    }
  }
}
