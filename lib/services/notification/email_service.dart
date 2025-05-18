import 'dart:async';
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
    // Maximum number of retry attempts
    const maxRetries = 3;
    // Delay between retries (in seconds)
    const retryDelay = 2;

    // Validate input parameters
    if (to.isEmpty) {
      Logger.e('Email address is empty', tag: 'EmailService');
      throw Exception('Email address is empty');
    }

    if (subject.isEmpty) {
      Logger.w('Email subject is empty', tag: 'EmailService');
      // Continue with empty subject, but log a warning
    }

    if (htmlContent.isEmpty) {
      Logger.e('Email content is empty', tag: 'EmailService');
      throw Exception('Email content is empty');
    }

    // Prepare the request body
    final body = {'to': to, 'subject': subject, 'html': htmlContent};

    // Add tracking information
    final trackingId = DateTime.now().millisecondsSinceEpoch.toString();
    body['tracking_id'] = trackingId;

    // Log the email attempt
    Logger.i(
      'Attempting to send email to $to (Tracking ID: $trackingId)',
      tag: 'EmailService',
    );

    // Try to send the email with retries
    int attempts = 0;
    while (attempts < maxRetries) {
      attempts++;

      try {
        // Set a timeout for the function call
        const timeout = Duration(seconds: 10);

        // Create a completer to handle the timeout
        final completer = Completer<FunctionResponse>();

        // Set up the timeout
        Timer(timeout, () {
          if (!completer.isCompleted) {
            completer.completeError(
              TimeoutException('Email function call timed out'),
            );
          }
        });

        // Execute the function call
        _supabase.functions
            .invoke('send-email', body: body)
            .then(
              (response) {
                if (!completer.isCompleted) {
                  completer.complete(response);
                }
              },
              onError: (error) {
                if (!completer.isCompleted) {
                  completer.completeError(error);
                }
              },
            );

        // Wait for either the function to complete or the timeout
        final response = await completer.future;

        // Check the response status
        if (response.status != 200) {
          throw Exception('Failed to send email: ${response.data}');
        }

        // Log success and return
        Logger.i(
          'Email sent successfully to $to (Tracking ID: $trackingId)',
          tag: 'EmailService',
        );

        // Record the email in the database
        try {
          await _supabase.from('email_logs').insert({
            'recipient': to,
            'subject': subject,
            'status': 'sent',
            'tracking_id': trackingId,
            'sent_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          // Don't fail if we can't log the email
          Logger.w(
            'Failed to record email in database: $e',
            tag: 'EmailService',
          );
        }

        return;
      } catch (e) {
        // Log the error
        Logger.e(
          'Error sending email (Attempt $attempts/$maxRetries): $e',
          tag: 'EmailService',
        );

        // If this was the last attempt, rethrow the error
        if (attempts >= maxRetries) {
          // Record the failed email in the database
          try {
            await _supabase.from('email_logs').insert({
              'recipient': to,
              'subject': subject,
              'status': 'failed',
              'tracking_id': trackingId,
              'sent_at': DateTime.now().toIso8601String(),
              'error_message': e.toString(),
            });
          } catch (dbError) {
            // Don't fail if we can't log the error
            Logger.w(
              'Failed to record email error in database: $dbError',
              tag: 'EmailService',
            );
          }

          throw Exception(
            'Failed to send email after $maxRetries attempts: $e',
          );
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: retryDelay * attempts));

        Logger.i(
          'Retrying email to $to (Attempt ${attempts + 1}/$maxRetries)',
          tag: 'EmailService',
        );
      }
    }
  }
}
