import 'package:flutter/material.dart';
import 'package:eventati_book/models/user_models/email_preferences.dart';
import 'package:eventati_book/services/notification/email_preferences_service.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for managing email preferences
class EmailPreferencesProvider extends ChangeNotifier {
  /// Email preferences service
  final EmailPreferencesService _service;

  /// Supabase client
  final SupabaseClient _supabase;

  /// Current user ID
  String? _userId;

  /// Current email preferences
  EmailPreferences? _preferences;

  /// Whether the provider is loading
  bool _isLoading = false;

  /// Error message if any
  String? _errorMessage;

  /// Constructor
  EmailPreferencesProvider({
    EmailPreferencesService? service,
    SupabaseClient? supabase,
  }) : _service = service ?? EmailPreferencesService(),
       _supabase = supabase ?? Supabase.instance.client;

  /// Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _isLoading = false;
        _errorMessage = 'No user logged in';
        notifyListeners();
        return;
      }

      _userId = user.id;

      // Load preferences
      await loadPreferences();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to initialize email preferences: $e';
      Logger.e(_errorMessage!, tag: 'EmailPreferencesProvider');
      notifyListeners();
    }
  }

  /// Load preferences for the current user
  Future<void> loadPreferences() async {
    if (_userId == null) {
      _errorMessage = 'No user logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _preferences = await _service.getEmailPreferences(_userId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load email preferences: $e';
      Logger.e(_errorMessage!, tag: 'EmailPreferencesProvider');
      notifyListeners();
    }
  }

  /// Save preferences for the current user
  Future<void> savePreferences(EmailPreferences preferences) async {
    if (_userId == null) {
      _errorMessage = 'No user logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.saveEmailPreferences(_userId!, preferences);
      _preferences = preferences;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to save email preferences: $e';
      Logger.e(_errorMessage!, tag: 'EmailPreferencesProvider');
      notifyListeners();
    }
  }

  /// Update a specific email preference
  Future<void> updatePreference(EmailType emailType, bool optIn) async {
    if (_userId == null) {
      _errorMessage = 'No user logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateEmailPreference(_userId!, emailType, optIn);
      await loadPreferences(); // Reload preferences
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update email preference: $e';
      Logger.e(_errorMessage!, tag: 'EmailPreferencesProvider');
      notifyListeners();
    }
  }

  /// Check if a user has opted in to a specific email type
  Future<bool> hasOptedIn(EmailType emailType) async {
    if (_userId == null) {
      return emailType == EmailType.account; // Default for required emails
    }

    try {
      return await _service.hasOptedIn(_userId!, emailType);
    } catch (e) {
      Logger.e(
        'Error checking email opt-in status: $e',
        tag: 'EmailPreferencesProvider',
      );
      // Default to true for essential emails, false for marketing
      return emailType == EmailType.account ||
          emailType == EmailType.bookingConfirmation ||
          emailType == EmailType.bookingUpdate;
    }
  }

  /// Get current email preferences
  EmailPreferences get preferences =>
      _preferences ?? EmailPreferences.defaultPreferences;

  /// Get whether the provider is loading
  bool get isLoading => _isLoading;

  /// Get error message if any
  String? get errorMessage => _errorMessage;

  /// Get whether booking confirmations are enabled
  bool get receiveBookingConfirmations =>
      _preferences?.receiveBookingConfirmations ?? true;

  /// Get whether booking updates are enabled
  bool get receiveBookingUpdates => _preferences?.receiveBookingUpdates ?? true;

  /// Get whether booking reminders are enabled
  bool get receiveBookingReminders =>
      _preferences?.receiveBookingReminders ?? true;

  /// Get whether promotional emails are enabled
  bool get receivePromotionalEmails =>
      _preferences?.receivePromotionalEmails ?? false;

  /// Get whether newsletter emails are enabled
  bool get receiveNewsletters => _preferences?.receiveNewsletters ?? false;

  /// Get whether recommendation emails are enabled
  bool get receiveRecommendations =>
      _preferences?.receiveRecommendations ?? true;

  /// Get whether account emails are enabled (always true)
  bool get receiveAccountEmails => _preferences?.receiveAccountEmails ?? true;
}
