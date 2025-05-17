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
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

          body {
            font-family: 'Poppins', Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
          }

          .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
          }

          .header {
            background-color: #4a2511;
            color: white;
            padding: 30px 20px;
            text-align: center;
          }

          .header h1 {
            margin: 0;
            font-weight: 600;
            font-size: 28px;
          }

          .content {
            padding: 30px;
            background-color: #ffffff;
          }

          .greeting {
            font-size: 18px;
            margin-bottom: 20px;
          }

          .confirmation-message {
            font-size: 16px;
            margin-bottom: 25px;
          }

          .details {
            margin: 25px 0;
            padding: 20px;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            background-color: #f9f9f9;
          }

          .details p {
            margin: 10px 0;
          }

          .highlight {
            color: #4a2511;
            font-weight: 600;
          }

          .button {
            display: inline-block;
            background-color: #4a2511;
            color: white !important;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 500;
            margin: 15px 0;
            transition: background-color 0.3s;
          }

          .button:hover {
            background-color: #5d3015;
          }

          .thank-you {
            margin: 25px 0 15px 0;
            font-size: 16px;
          }

          .contact-info {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
          }

          .footer {
            padding: 20px;
            text-align: center;
            font-size: 14px;
            color: #777;
            background-color: #f9f9f9;
            border-top: 1px solid #e0e0e0;
          }

          .social-links {
            margin: 15px 0;
          }

          .social-links a {
            display: inline-block;
            margin: 0 8px;
            color: #4a2511;
            text-decoration: none;
          }

          @media only screen and (max-width: 600px) {
            .container {
              width: 100%;
              border-radius: 0;
            }

            .content {
              padding: 20px;
            }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Booking Confirmation</h1>
          </div>
          <div class="content">
            <p class="greeting">Dear ${userName.isEmpty ? 'Valued Customer' : userName},</p>

            <p class="confirmation-message">
              Great news! Your booking for <span class="highlight">${booking.serviceName}</span> has been confirmed and is now ready to go.
            </p>

            <div class="details">
              <p><strong>Date and Time:</strong> $formattedDate</p>
              <p><strong>Duration:</strong> ${booking.duration} hours</p>
              <p><strong>Total Price:</strong> \$${booking.totalPrice.toStringAsFixed(2)}</p>
              ${booking.specialRequests.isNotEmpty ? '<p><strong>Special Requests:</strong> ${booking.specialRequests}</p>' : ''}
              ${booking.eventName != null ? '<p><strong>Event:</strong> ${booking.eventName}</p>' : ''}
              ${booking.serviceOptions['location'] != null ? '<p><strong>Location:</strong> ${booking.serviceOptions['location']}</p>' : ''}
            </div>

            <p class="thank-you">Thank you for choosing Eventati Book for your event planning needs!</p>

            ${addToCalendarUrl != null ? '<p style="text-align: center;"><a href="$addToCalendarUrl" class="button">Add to Calendar</a></p>' : ''}

            <div class="contact-info">
              <p>If you have any questions or need to make changes to your booking, please don't hesitate to contact our customer support team at <a href="mailto:support@eventatibook.com">support@eventatibook.com</a> or call us at (555) 123-4567.</p>
            </div>
          </div>
          <div class="footer">
            <div class="social-links">
              <a href="https://facebook.com/eventatibook">Facebook</a> |
              <a href="https://twitter.com/eventatibook">Twitter</a> |
              <a href="https://instagram.com/eventatibook">Instagram</a>
            </div>
            <p>Best regards,<br>The Eventati Book Team</p>
            <p>© ${DateTime.now().year} Eventati Book. All rights reserved.</p>
            <p style="font-size: 12px; color: #999;">
              This email was sent to you because you made a booking on Eventati Book.
              <br>
              To unsubscribe from promotional emails, <a href="#" style="color: #999;">click here</a>.
            </p>
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
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap');

          body {
            font-family: 'Poppins', Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
          }

          .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
          }

          .header {
            background-color: #4a2511;
            color: white;
            padding: 30px 20px;
            text-align: center;
          }

          .header h1 {
            margin: 0;
            font-weight: 600;
            font-size: 28px;
          }

          .content {
            padding: 30px;
            background-color: #ffffff;
          }

          .greeting {
            font-size: 18px;
            margin-bottom: 20px;
          }

          .reminder {
            background-color: #d1ecf1;
            padding: 20px;
            border-left: 4px solid #17a2b8;
            margin: 25px 0;
            border-radius: 0 8px 8px 0;
          }

          .reminder p {
            margin: 0;
            font-size: 18px;
          }

          .countdown {
            font-size: 24px;
            font-weight: 600;
            color: #17a2b8;
            display: inline-block;
            margin: 0 5px;
          }

          .details {
            margin: 25px 0;
            padding: 20px;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            background-color: #f9f9f9;
          }

          .details p {
            margin: 10px 0;
          }

          .highlight {
            color: #4a2511;
            font-weight: 600;
          }

          .button {
            display: inline-block;
            background-color: #4a2511;
            color: white !important;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 500;
            margin: 15px 0;
            transition: background-color 0.3s;
          }

          .button:hover {
            background-color: #5d3015;
          }

          .checklist {
            margin: 25px 0;
            padding: 0;
            list-style-type: none;
          }

          .checklist li {
            margin-bottom: 10px;
            padding-left: 30px;
            position: relative;
          }

          .checklist li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: #4a2511;
            font-weight: bold;
          }

          .contact-info {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
          }

          .footer {
            padding: 20px;
            text-align: center;
            font-size: 14px;
            color: #777;
            background-color: #f9f9f9;
            border-top: 1px solid #e0e0e0;
          }

          .social-links {
            margin: 15px 0;
          }

          .social-links a {
            display: inline-block;
            margin: 0 8px;
            color: #4a2511;
            text-decoration: none;
          }

          .weather-forecast {
            margin: 25px 0;
            padding: 15px;
            background-color: #f0f8ff;
            border-radius: 8px;
            border: 1px solid #d1e3ff;
          }

          @media only screen and (max-width: 600px) {
            .container {
              width: 100%;
              border-radius: 0;
            }

            .content {
              padding: 20px;
            }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Your Booking is Coming Up!</h1>
          </div>
          <div class="content">
            <p class="greeting">Dear ${userName.isEmpty ? 'Valued Customer' : userName},</p>

            <div class="reminder">
              <p>This is a friendly reminder that your booking for <span class="highlight">${booking.serviceName}</span> is coming up in <span class="countdown">$daysBeforeEvent</span> ${daysBeforeEvent == 1 ? 'day' : 'days'}!</p>
            </div>

            <div class="details">
              <p><strong>Date and Time:</strong> $formattedDate</p>
              <p><strong>Duration:</strong> ${booking.duration} hours</p>
              <p><strong>Location:</strong> ${booking.serviceOptions['location'] ?? 'Not specified'}</p>
              ${booking.specialRequests.isNotEmpty ? '<p><strong>Special Requests:</strong> ${booking.specialRequests}</p>' : ''}
              ${booking.eventName != null ? '<p><strong>Event:</strong> ${booking.eventName}</p>' : ''}
              <p><strong>Booking Reference:</strong> ${booking.id.substring(0, 8).toUpperCase()}</p>
            </div>

            <h3>Pre-Event Checklist:</h3>
            <ul class="checklist">
              <li>Confirm your attendance</li>
              <li>Review booking details</li>
              <li>Plan your transportation to the venue</li>
              <li>Prepare any necessary items or documents</li>
              ${booking.eventName != null ? '<li>Review your event planning checklist in the Eventati Book app</li>' : ''}
            </ul>

            ${booking.serviceOptions['location'] != null ? '''
            <div class="weather-forecast">
              <h3>Weather Forecast:</h3>
              <p>We recommend checking the weather forecast for your event day to be prepared.</p>
              <p style="text-align: center;">
                <a href="https://weather.com/weather/tenday/l/${booking.serviceOptions['location']?.replaceAll(' ', '+')}" class="button">Check Weather</a>
              </p>
            </div>
            ''' : ''}

            <p style="font-size: 18px; margin-top: 30px;">We look forward to seeing you soon!</p>

            <div class="contact-info">
              <p>If you need to make any changes to your booking, please contact us as soon as possible at <a href="mailto:support@eventatibook.com">support@eventatibook.com</a> or call us at (555) 123-4567.</p>
            </div>
          </div>
          <div class="footer">
            <div class="social-links">
              <a href="https://facebook.com/eventatibook">Facebook</a> |
              <a href="https://twitter.com/eventatibook">Twitter</a> |
              <a href="https://instagram.com/eventatibook">Instagram</a>
            </div>
            <p>Best regards,<br>The Eventati Book Team</p>
            <p>© ${DateTime.now().year} Eventati Book. All rights reserved.</p>
            <p style="font-size: 12px; color: #999;">
              This email was sent to you because you have an upcoming booking with Eventati Book.
              <br>
              To unsubscribe from reminder emails, <a href="#" style="color: #999;">click here</a>.
            </p>
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
