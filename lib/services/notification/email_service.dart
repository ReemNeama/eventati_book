import 'package:eventati_book/models/service_models/booking.dart';
import 'package:eventati_book/services/supabase/database/user_database_service.dart';
import 'package:eventati_book/services/notification/email_templates.dart';
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
  Future<void> sendBookingConfirmationEmail(
    Booking booking, {
    String? addToCalendarUrl,
  }) async {
    try {
      final user = await _userDatabaseService.getUser(booking.userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final email = user.email;
      if (email.isEmpty) {
        throw Exception('User email not found');
      }

      // Format the booking date and time
      final formattedDate = _formatDate(booking.bookingDateTime);

      // Create email content using template
      final subject = 'Booking Confirmation - ${booking.serviceName}';
      final content = EmailTemplates.bookingConfirmation(
        userName: user.displayName,
        booking: booking,
        formattedDate: formattedDate,
        addToCalendarUrl: addToCalendarUrl,
      );

      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);

      Logger.i(
        'Booking confirmation email sent to $email',
        tag: 'EmailService',
      );
    } catch (e) {
      Logger.e(
        'Error sending booking confirmation email: $e',
        tag: 'EmailService',
      );
    }
  }

  /// Send a booking update email
  Future<void> sendBookingUpdateEmail(
    Booking booking,
    String updateMessage,
  ) async {
    try {
      final user = await _userDatabaseService.getUser(booking.userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final email = user.email;
      if (email.isEmpty) {
        throw Exception('User email not found');
      }

      // Format the booking date and time
      final formattedDate = _formatDate(booking.bookingDateTime);

      // Create email content using template
      final subject = 'Booking Update - ${booking.serviceName}';
      final content = EmailTemplates.bookingUpdate(
        userName: user.displayName,
        booking: booking,
        updateMessage: updateMessage,
        formattedDate: formattedDate,
      );

      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);

      Logger.i('Booking update email sent to $email', tag: 'EmailService');
    } catch (e) {
      Logger.e('Error sending booking update email: $e', tag: 'EmailService');
    }
  }

  /// Send a booking reminder email
  Future<void> sendBookingReminderEmail(
    Booking booking,
    int daysBeforeEvent,
  ) async {
    try {
      final user = await _userDatabaseService.getUser(booking.userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final email = user.email;
      if (email.isEmpty) {
        throw Exception('User email not found');
      }

      // Format the booking date and time
      final formattedDate = _formatDate(booking.bookingDateTime);

      // Create email content using template
      final subject = 'Reminder: Upcoming Booking - ${booking.serviceName}';
      final content = EmailTemplates.bookingReminder(
        userName: user.displayName,
        booking: booking,
        daysBeforeEvent: daysBeforeEvent,
        formattedDate: formattedDate,
      );

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
      if (email.isEmpty) {
        throw Exception('User email not found');
      }

      // Format the booking date and time
      final formattedDate = _formatDate(booking.bookingDateTime);

      // Create email content using template
      final subject = 'Booking Cancellation - ${booking.serviceName}';
      final content = EmailTemplates.bookingCancellation(
        userName: user.displayName,
        booking: booking,
        formattedDate: formattedDate,
      );

      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);

      Logger.i(
        'Booking cancellation email sent to $email',
        tag: 'EmailService',
      );
    } catch (e) {
      Logger.e(
        'Error sending booking cancellation email: $e',
        tag: 'EmailService',
      );
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
      if (email.isEmpty) {
        throw Exception('User email not found');
      }

      // Create email content
      final content = '''
        <h1>$subject</h1>
        <p>Dear ${user.displayName.isEmpty ? 'Valued Customer' : user.displayName},</p>
        <p>$body</p>
        <p>Best regards,<br>The Eventati Book Team</p>
      ''';

      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);

      Logger.i(
        'Email notification sent to $email: $subject',
        tag: 'EmailService',
      );
    } catch (e) {
      Logger.e('Error sending email notification: $e', tag: 'EmailService');
    }
  }

  /// Send an email verification email
  Future<void> sendEmailVerification(String email, String userName) async {
    try {
      // Generate verification link using Supabase
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.eventati.book://verify-email',
      );

      // Create email content using template
      const subject = 'Verify Your Email Address';
      const verificationLink =
          'https://zyycmxzabfadkyzpsper.supabase.co/auth/v1/verify';

      final content = EmailTemplates.emailVerification(
        userName: userName,
        verificationLink: verificationLink,
      );

      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);

      Logger.i('Email verification sent to $email', tag: 'EmailService');
    } catch (e) {
      Logger.e('Error sending email verification: $e', tag: 'EmailService');
      throw Exception('Failed to send email verification: $e');
    }
  }

  /// Send a password reset email
  Future<void> sendPasswordReset(String email, String userName) async {
    try {
      // Generate password reset link using Supabase
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.eventati.book://reset-password',
      );

      // Create email content using template
      const subject = 'Reset Your Password';
      const resetLink =
          'https://zyycmxzabfadkyzpsper.supabase.co/auth/v1/verify?type=recovery';

      final content = EmailTemplates.passwordReset(
        userName: userName,
        resetLink: resetLink,
      );

      // Send email using Supabase Edge Function
      await _sendEmail(email, subject, content);

      Logger.i('Password reset email sent to $email', tag: 'EmailService');
    } catch (e) {
      Logger.e('Error sending password reset email: $e', tag: 'EmailService');
      throw Exception('Failed to send password reset email: $e');
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
        body: {'to': to, 'subject': subject, 'html': htmlContent},
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
