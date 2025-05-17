/// Model representing user email preferences
class EmailPreferences {
  /// Whether to receive booking confirmation emails
  final bool receiveBookingConfirmations;

  /// Whether to receive booking update emails
  final bool receiveBookingUpdates;

  /// Whether to receive booking reminder emails
  final bool receiveBookingReminders;

  /// Whether to receive promotional emails
  final bool receivePromotionalEmails;

  /// Whether to receive newsletter emails
  final bool receiveNewsletters;

  /// Whether to receive event recommendation emails
  final bool receiveRecommendations;

  /// Whether to receive account-related emails (required)
  final bool receiveAccountEmails;

  /// Constructor
  const EmailPreferences({
    this.receiveBookingConfirmations = true,
    this.receiveBookingUpdates = true,
    this.receiveBookingReminders = true,
    this.receivePromotionalEmails = false,
    this.receiveNewsletters = false,
    this.receiveRecommendations = true,
    this.receiveAccountEmails = true,
  });

  /// Create a copy of this object with modified fields
  EmailPreferences copyWith({
    bool? receiveBookingConfirmations,
    bool? receiveBookingUpdates,
    bool? receiveBookingReminders,
    bool? receivePromotionalEmails,
    bool? receiveNewsletters,
    bool? receiveRecommendations,
    bool? receiveAccountEmails,
  }) {
    return EmailPreferences(
      receiveBookingConfirmations:
          receiveBookingConfirmations ?? this.receiveBookingConfirmations,
      receiveBookingUpdates:
          receiveBookingUpdates ?? this.receiveBookingUpdates,
      receiveBookingReminders:
          receiveBookingReminders ?? this.receiveBookingReminders,
      receivePromotionalEmails:
          receivePromotionalEmails ?? this.receivePromotionalEmails,
      receiveNewsletters: receiveNewsletters ?? this.receiveNewsletters,
      receiveRecommendations:
          receiveRecommendations ?? this.receiveRecommendations,
      receiveAccountEmails: receiveAccountEmails ?? this.receiveAccountEmails,
    );
  }

  /// Create from JSON
  factory EmailPreferences.fromJson(Map<String, dynamic> json) {
    return EmailPreferences(
      receiveBookingConfirmations:
          json['receive_booking_confirmations'] ?? true,
      receiveBookingUpdates: json['receive_booking_updates'] ?? true,
      receiveBookingReminders: json['receive_booking_reminders'] ?? true,
      receivePromotionalEmails: json['receive_promotional_emails'] ?? false,
      receiveNewsletters: json['receive_newsletters'] ?? false,
      receiveRecommendations: json['receive_recommendations'] ?? true,
      receiveAccountEmails: json['receive_account_emails'] ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'receive_booking_confirmations': receiveBookingConfirmations,
      'receive_booking_updates': receiveBookingUpdates,
      'receive_booking_reminders': receiveBookingReminders,
      'receive_promotional_emails': receivePromotionalEmails,
      'receive_newsletters': receiveNewsletters,
      'receive_recommendations': receiveRecommendations,
      'receive_account_emails': receiveAccountEmails,
    };
  }

  /// Default email preferences
  static const EmailPreferences defaultPreferences = EmailPreferences();
}
