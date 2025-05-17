import 'package:eventati_book/models/models.dart';

/// Class containing email templates for various notifications
class EmailTemplates {
  /// Get booking confirmation email template
  static String bookingConfirmation({
    required String userName,
    required Booking booking,
    required String formattedDate,
    String? addToCalendarUrl,
  }) {
    return '''
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #4a2511; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f9f9f9; }
          .footer { padding: 20px; text-align: center; font-size: 12px; color: #777; }
          .button { display: inline-block; background-color: #4a2511; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; }
          .details { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 4px; }
          .highlight { color: #4a2511; font-weight: bold; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Booking Confirmation</h1>
          </div>
          <div class="content">
            <p>Dear ${userName.isEmpty ? 'Valued Customer' : userName},</p>
            <p>Your booking for <span class="highlight">${booking.serviceName}</span> has been confirmed.</p>
            
            <div class="details">
              <p><strong>Date and Time:</strong> $formattedDate</p>
              <p><strong>Duration:</strong> ${booking.duration} hours</p>
              <p><strong>Total Price:</strong> \$${booking.totalPrice.toStringAsFixed(2)}</p>
              ${booking.specialRequests.isNotEmpty ? '<p><strong>Special Requests:</strong> ${booking.specialRequests}</p>' : ''}
              ${booking.eventName != null ? '<p><strong>Event:</strong> ${booking.eventName}</p>' : ''}
            </div>
            
            <p>Thank you for choosing Eventati Book!</p>
            
            ${addToCalendarUrl != null ? '<p><a href="$addToCalendarUrl" class="button">Add to Calendar</a></p>' : ''}
            
            <p>If you have any questions or need to make changes to your booking, please contact us.</p>
          </div>
          <div class="footer">
            <p>Best regards,<br>The Eventati Book Team</p>
            <p>© ${DateTime.now().year} Eventati Book. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  /// Get booking update email template
  static String bookingUpdate({
    required String userName,
    required Booking booking,
    required String updateMessage,
    required String formattedDate,
  }) {
    return '''
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #4a2511; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f9f9f9; }
          .footer { padding: 20px; text-align: center; font-size: 12px; color: #777; }
          .button { display: inline-block; background-color: #4a2511; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; }
          .details { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 4px; }
          .highlight { color: #4a2511; font-weight: bold; }
          .update-message { background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Booking Update</h1>
          </div>
          <div class="content">
            <p>Dear ${userName.isEmpty ? 'Valued Customer' : userName},</p>
            <p>Your booking for <span class="highlight">${booking.serviceName}</span> has been updated.</p>
            
            <div class="update-message">
              <p><strong>Update:</strong> $updateMessage</p>
            </div>
            
            <div class="details">
              <p><strong>Date and Time:</strong> $formattedDate</p>
              <p><strong>Duration:</strong> ${booking.duration} hours</p>
              <p><strong>Total Price:</strong> \$${booking.totalPrice.toStringAsFixed(2)}</p>
              ${booking.specialRequests.isNotEmpty ? '<p><strong>Special Requests:</strong> ${booking.specialRequests}</p>' : ''}
              ${booking.eventName != null ? '<p><strong>Event:</strong> ${booking.eventName}</p>' : ''}
            </div>
            
            <p>If you have any questions or concerns about this update, please contact us.</p>
          </div>
          <div class="footer">
            <p>Best regards,<br>The Eventati Book Team</p>
            <p>© ${DateTime.now().year} Eventati Book. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  /// Get booking reminder email template
  static String bookingReminder({
    required String userName,
    required Booking booking,
    required int daysBeforeEvent,
    required String formattedDate,
  }) {
    return '''
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #4a2511; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f9f9f9; }
          .footer { padding: 20px; text-align: center; font-size: 12px; color: #777; }
          .button { display: inline-block; background-color: #4a2511; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; }
          .details { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 4px; }
          .highlight { color: #4a2511; font-weight: bold; }
          .reminder { background-color: #d1ecf1; padding: 15px; border-left: 4px solid #17a2b8; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Booking Reminder</h1>
          </div>
          <div class="content">
            <p>Dear ${userName.isEmpty ? 'Valued Customer' : userName},</p>
            
            <div class="reminder">
              <p>This is a reminder that your booking for <span class="highlight">${booking.serviceName}</span> is in $daysBeforeEvent ${daysBeforeEvent == 1 ? 'day' : 'days'}.</p>
            </div>
            
            <div class="details">
              <p><strong>Date and Time:</strong> $formattedDate</p>
              <p><strong>Duration:</strong> ${booking.duration} hours</p>
              <p><strong>Location:</strong> ${booking.serviceOptions['location'] ?? 'Not specified'}</p>
              ${booking.specialRequests.isNotEmpty ? '<p><strong>Special Requests:</strong> ${booking.specialRequests}</p>' : ''}
              ${booking.eventName != null ? '<p><strong>Event:</strong> ${booking.eventName}</p>' : ''}
            </div>
            
            <p>We look forward to seeing you!</p>
            <p>If you need to make any changes to your booking, please contact us as soon as possible.</p>
          </div>
          <div class="footer">
            <p>Best regards,<br>The Eventati Book Team</p>
            <p>© ${DateTime.now().year} Eventati Book. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  /// Get booking cancellation email template
  static String bookingCancellation({
    required String userName,
    required Booking booking,
    required String formattedDate,
  }) {
    return '''
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #4a2511; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f9f9f9; }
          .footer { padding: 20px; text-align: center; font-size: 12px; color: #777; }
          .button { display: inline-block; background-color: #4a2511; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; }
          .details { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 4px; }
          .highlight { color: #4a2511; font-weight: bold; }
          .cancellation { background-color: #f8d7da; padding: 15px; border-left: 4px solid #dc3545; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Booking Cancellation</h1>
          </div>
          <div class="content">
            <p>Dear ${userName.isEmpty ? 'Valued Customer' : userName},</p>
            
            <div class="cancellation">
              <p>Your booking for <span class="highlight">${booking.serviceName}</span> on $formattedDate has been cancelled.</p>
            </div>
            
            <p>If you did not request this cancellation or have any questions, please contact us.</p>
          </div>
          <div class="footer">
            <p>Best regards,<br>The Eventati Book Team</p>
            <p>© ${DateTime.now().year} Eventati Book. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  /// Get email verification template
  static String emailVerification({
    required String userName,
    required String verificationLink,
  }) {
    return '''
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #4a2511; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f9f9f9; }
          .footer { padding: 20px; text-align: center; font-size: 12px; color: #777; }
          .button { display: inline-block; background-color: #4a2511; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; }
          .verification { margin: 30px 0; text-align: center; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Email Verification</h1>
          </div>
          <div class="content">
            <p>Dear ${userName.isEmpty ? 'Valued Customer' : userName},</p>
            <p>Thank you for registering with Eventati Book. To complete your registration, please verify your email address by clicking the button below:</p>
            
            <div class="verification">
              <a href="$verificationLink" class="button">Verify Email Address</a>
            </div>
            
            <p>If you did not create an account with Eventati Book, please ignore this email.</p>
            <p>This verification link will expire in 24 hours.</p>
          </div>
          <div class="footer">
            <p>Best regards,<br>The Eventati Book Team</p>
            <p>© ${DateTime.now().year} Eventati Book. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  /// Get password reset template
  static String passwordReset({
    required String userName,
    required String resetLink,
  }) {
    return '''
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #4a2511; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f9f9f9; }
          .footer { padding: 20px; text-align: center; font-size: 12px; color: #777; }
          .button { display: inline-block; background-color: #4a2511; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; }
          .reset { margin: 30px 0; text-align: center; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Password Reset</h1>
          </div>
          <div class="content">
            <p>Dear ${userName.isEmpty ? 'Valued Customer' : userName},</p>
            <p>We received a request to reset your password for your Eventati Book account. To reset your password, please click the button below:</p>
            
            <div class="reset">
              <a href="$resetLink" class="button">Reset Password</a>
            </div>
            
            <p>If you did not request a password reset, please ignore this email or contact us if you have concerns.</p>
            <p>This password reset link will expire in 1 hour.</p>
          </div>
          <div class="footer">
            <p>Best regards,<br>The Eventati Book Team</p>
            <p>© ${DateTime.now().year} Eventati Book. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }
}
