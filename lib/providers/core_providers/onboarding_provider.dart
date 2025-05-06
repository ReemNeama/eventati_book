import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/utils/constants/app_constants.dart';

/// Provider for managing onboarding state
///
/// The OnboardingProvider is responsible for:
/// * Tracking whether the user has completed the onboarding process
/// * Storing and retrieving onboarding status from SharedPreferences
/// * Marking onboarding as complete
/// * Resetting onboarding status for testing purposes
///
/// Usage example:
/// ```dart
/// // Access the provider from the widget tree
/// final onboardingProvider = Provider.of<OnboardingProvider>(context);
///
/// // Check if onboarding is completed
/// if (onboardingProvider.hasCompletedOnboarding) {
///   // Navigate to home screen
/// } else {
///   // Navigate to onboarding screen
/// }
///
/// // Mark onboarding as complete
/// await onboardingProvider.completeOnboarding();
/// ```
class OnboardingProvider extends ChangeNotifier {
  /// Flag indicating if the user has completed the onboarding process
  bool _hasCompletedOnboarding = false;

  /// Flag indicating if the provider is currently loading data
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _error;

  /// Creates a new OnboardingProvider
  ///
  /// Automatically loads onboarding status from SharedPreferences
  OnboardingProvider() {
    _loadOnboardingStatus();
  }

  /// Returns whether the user has completed the onboarding process
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  /// Indicates if the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the current error message, if any
  String? get error => _error;

  /// Loads the onboarding status from SharedPreferences
  ///
  /// This is called automatically when the provider is created.
  Future<void> _loadOnboardingStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding =
          prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load onboarding status: $e';
      notifyListeners();
    }
  }

  /// Marks the onboarding process as complete
  ///
  /// Saves the status to SharedPreferences and updates the provider state.
  /// Returns true if successful, false otherwise.
  Future<bool> completeOnboarding() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.onboardingCompletedKey, true);

      _hasCompletedOnboarding = true;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to complete onboarding: $e';
      notifyListeners();

      return false;
    }
  }

  /// Resets the onboarding status
  ///
  /// This is primarily used for testing purposes.
  /// Returns true if successful, false otherwise.
  Future<bool> resetOnboarding() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.onboardingCompletedKey, false);

      _hasCompletedOnboarding = false;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to reset onboarding: $e';
      notifyListeners();

      return false;
    }
  }
}
