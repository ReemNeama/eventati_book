import 'package:eventati_book/models/user_models/email_preferences.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing user email preferences
class EmailPreferencesService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for email preferences
  static const _emailPreferencesTable = 'user_email_preferences';

  /// Constructor
  EmailPreferencesService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get email preferences for a user
  Future<EmailPreferences> getEmailPreferences(String userId) async {
    try {
      final response =
          await _supabase
              .from(_emailPreferencesTable)
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (response == null) {
        // If no preferences exist, create default preferences
        const defaultPreferences = EmailPreferences.defaultPreferences;
        await saveEmailPreferences(userId, defaultPreferences);
        return defaultPreferences;
      }

      return EmailPreferences.fromJson(response);
    } catch (e) {
      Logger.e(
        'Error getting email preferences: $e',
        tag: 'EmailPreferencesService',
      );
      // Return default preferences if there's an error
      return EmailPreferences.defaultPreferences;
    }
  }

  /// Save email preferences for a user
  Future<void> saveEmailPreferences(
    String userId,
    EmailPreferences preferences,
  ) async {
    try {
      final existingPreferences =
          await _supabase
              .from(_emailPreferencesTable)
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      final preferencesData = {
        'user_id': userId,
        'receive_booking_confirmations':
            preferences.receiveBookingConfirmations,
        'receive_booking_updates': preferences.receiveBookingUpdates,
        'receive_booking_reminders': preferences.receiveBookingReminders,
        'receive_promotional_emails': preferences.receivePromotionalEmails,
        'receive_newsletters': preferences.receiveNewsletters,
        'receive_recommendations': preferences.receiveRecommendations,
        'receive_account_emails': preferences.receiveAccountEmails,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existingPreferences == null) {
        // Insert new preferences
        preferencesData['created_at'] = DateTime.now().toIso8601String();
        await _supabase.from(_emailPreferencesTable).insert(preferencesData);
      } else {
        // Update existing preferences
        await _supabase
            .from(_emailPreferencesTable)
            .update(preferencesData)
            .eq('user_id', userId);
      }

      Logger.i(
        'Email preferences saved for user $userId',
        tag: 'EmailPreferencesService',
      );
    } catch (e) {
      Logger.e(
        'Error saving email preferences: $e',
        tag: 'EmailPreferencesService',
      );
      throw Exception('Failed to save email preferences: $e');
    }
  }

  /// Check if a user has opted in to a specific email type
  Future<bool> hasOptedIn(String userId, EmailType emailType) async {
    try {
      final preferences = await getEmailPreferences(userId);

      switch (emailType) {
        case EmailType.bookingConfirmation:
          return preferences.receiveBookingConfirmations;
        case EmailType.bookingUpdate:
          return preferences.receiveBookingUpdates;
        case EmailType.bookingReminder:
          return preferences.receiveBookingReminders;
        case EmailType.promotional:
          return preferences.receivePromotionalEmails;
        case EmailType.newsletter:
          return preferences.receiveNewsletters;
        case EmailType.recommendation:
          return preferences.receiveRecommendations;
        case EmailType.account:
          return preferences.receiveAccountEmails;
      }
    } catch (e) {
      Logger.e(
        'Error checking email opt-in status: $e',
        tag: 'EmailPreferencesService',
      );
      // Default to true for essential emails, false for marketing
      return emailType == EmailType.account ||
          emailType == EmailType.bookingConfirmation ||
          emailType == EmailType.bookingUpdate;
    }
  }

  /// Update a specific email preference
  Future<void> updateEmailPreference(
    String userId,
    EmailType emailType,
    bool optIn,
  ) async {
    try {
      final preferences = await getEmailPreferences(userId);
      EmailPreferences updatedPreferences;

      switch (emailType) {
        case EmailType.bookingConfirmation:
          updatedPreferences = preferences.copyWith(
            receiveBookingConfirmations: optIn,
          );
          break;
        case EmailType.bookingUpdate:
          updatedPreferences = preferences.copyWith(
            receiveBookingUpdates: optIn,
          );
          break;
        case EmailType.bookingReminder:
          updatedPreferences = preferences.copyWith(
            receiveBookingReminders: optIn,
          );
          break;
        case EmailType.promotional:
          updatedPreferences = preferences.copyWith(
            receivePromotionalEmails: optIn,
          );
          break;
        case EmailType.newsletter:
          updatedPreferences = preferences.copyWith(receiveNewsletters: optIn);
          break;
        case EmailType.recommendation:
          updatedPreferences = preferences.copyWith(
            receiveRecommendations: optIn,
          );
          break;
        case EmailType.account:
          // Account emails cannot be disabled
          updatedPreferences = preferences;
          break;
      }

      await saveEmailPreferences(userId, updatedPreferences);

      Logger.i(
        'Email preference updated for user $userId: $emailType -> $optIn',
        tag: 'EmailPreferencesService',
      );
    } catch (e) {
      Logger.e(
        'Error updating email preference: $e',
        tag: 'EmailPreferencesService',
      );
      throw Exception('Failed to update email preference: $e');
    }
  }
}

/// Enum representing different types of emails
enum EmailType {
  /// Booking confirmation emails
  bookingConfirmation,

  /// Booking update emails
  bookingUpdate,

  /// Booking reminder emails
  bookingReminder,

  /// Promotional emails
  promotional,

  /// Newsletter emails
  newsletter,

  /// Recommendation emails
  recommendation,

  /// Account-related emails (required)
  account,
}
