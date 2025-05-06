import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/utils/constants/app_constants.dart';

/// Provider for managing feature flags
///
/// The FeatureProvider is responsible for:
/// * Tracking which features are enabled
/// * Storing and retrieving feature flags from SharedPreferences
/// * Enabling and disabling features
///
/// Usage example:
/// ```dart
/// // Access the provider from the widget tree
/// final featureProvider = Provider.of<FeatureProvider>(context);
///
/// // Check if a feature is enabled
/// if (featureProvider.isFeatureEnabled('premium_comparison')) {
///   // Show premium comparison feature
/// } else {
///   // Show basic comparison feature
/// }
///
/// // Enable a feature
/// await featureProvider.enableFeature('premium_comparison');
/// ```
class FeatureProvider extends ChangeNotifier {
  /// Map of feature keys to their enabled status
  Map<String, bool> _features = {};

  /// Flag indicating if the provider is currently loading data
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _error;

  /// Default features that are always enabled
  final Map<String, bool> _defaultFeatures = {
    'basic_booking': true,
    'basic_comparison': true,
    'basic_search': true,
    'basic_filter': true,
    'basic_sort': true,
    'basic_event_planning': true,
    'basic_guest_list': true,
    'basic_timeline': true,
    'basic_budget': true,
  };

  /// Premium features that require a subscription
  final List<String> _premiumFeatures = [
    'premium_booking',
    'premium_comparison',
    'premium_search',
    'premium_filter',
    'premium_sort',
    'premium_event_planning',
    'premium_guest_list',
    'premium_timeline',
    'premium_budget',
    'premium_vendor_communication',
    'premium_analytics',
    'premium_export',
    'premium_import',
    'premium_templates',
    'premium_themes',
  ];

  /// Beta features that are only available to beta testers
  final List<String> _betaFeatures = [
    'ai_suggestions',
    'ai_planning',
    'ai_budget',
    'ai_timeline',
    'ai_guest_list',
    'ai_vendor_matching',
    'ai_theme_generation',
    'ai_menu_planning',
    'ai_seating_arrangement',
    'ai_speech_writing',
  ];

  /// Creates a new FeatureProvider
  ///
  /// Automatically loads feature flags from SharedPreferences
  FeatureProvider() {
    _loadFeatures();
  }

  /// Returns whether a feature is enabled
  bool isFeatureEnabled(String featureKey) {
    // Default features are always enabled
    if (_defaultFeatures.containsKey(featureKey) &&
        _defaultFeatures[featureKey] == true) {
      return true;
    }

    // Check if the feature is explicitly enabled
    return _features[featureKey] == true;
  }

  /// Returns a list of all enabled features
  List<String> get enabledFeatures {
    final List<String> enabled = [];

    // Add default features
    _defaultFeatures.forEach((key, value) {
      if (value) {
        enabled.add(key);
      }
    });

    // Add explicitly enabled features
    _features.forEach((key, value) {
      if (value && !enabled.contains(key)) {
        enabled.add(key);
      }
    });

    return enabled;
  }

  /// Returns a list of all premium features
  List<String> get premiumFeatures => _premiumFeatures;

  /// Returns a list of all beta features
  List<String> get betaFeatures => _betaFeatures;

  /// Indicates if the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the current error message, if any
  String? get error => _error;

  /// Loads feature flags from SharedPreferences
  ///
  /// This is called automatically when the provider is created.
  Future<void> _loadFeatures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final featuresJson = prefs.getString(AppConstants.featuresKey);

      if (featuresJson != null) {
        final Map<String, dynamic> featuresData = jsonDecode(featuresJson);
        _features = Map<String, bool>.from(featuresData);
      } else {
        // Initialize with default features
        _features = Map<String, bool>.from(_defaultFeatures);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load features: $e';
      notifyListeners();
    }
  }

  /// Saves feature flags to SharedPreferences
  ///
  /// This is called automatically after any operation that modifies the features.
  Future<void> _saveFeatures() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final featuresJson = jsonEncode(_features);
      await prefs.setString(AppConstants.featuresKey, featuresJson);
    } catch (e) {
      _error = 'Failed to save features: $e';
      notifyListeners();
    }
  }

  /// Enables a feature
  ///
  /// Sets the feature to enabled and saves it to SharedPreferences.
  /// Returns true if successful, false otherwise.
  Future<bool> enableFeature(String featureKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _features[featureKey] = true;
      await _saveFeatures();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to enable feature: $e';
      notifyListeners();

      return false;
    }
  }

  /// Disables a feature
  ///
  /// Sets the feature to disabled and saves it to SharedPreferences.
  /// Returns true if successful, false otherwise.
  Future<bool> disableFeature(String featureKey) async {
    // Don't allow disabling default features
    if (_defaultFeatures.containsKey(featureKey) &&
        _defaultFeatures[featureKey] == true) {
      _error = 'Cannot disable default feature: $featureKey';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _features[featureKey] = false;
      await _saveFeatures();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to disable feature: $e';
      notifyListeners();

      return false;
    }
  }

  /// Enables multiple features
  ///
  /// Sets multiple features to enabled and saves them to SharedPreferences.
  /// Returns true if successful, false otherwise.
  Future<bool> enableFeatures(List<String> featureKeys) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (final featureKey in featureKeys) {
        _features[featureKey] = true;
      }

      await _saveFeatures();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to enable features: $e';
      notifyListeners();

      return false;
    }
  }

  /// Disables multiple features
  ///
  /// Sets multiple features to disabled and saves them to SharedPreferences.
  /// Returns true if successful, false otherwise.
  Future<bool> disableFeatures(List<String> featureKeys) async {
    // Filter out default features
    final nonDefaultFeatures =
        featureKeys
            .where(
              (featureKey) =>
                  !(_defaultFeatures.containsKey(featureKey) &&
                      _defaultFeatures[featureKey] == true),
            )
            .toList();

    if (nonDefaultFeatures.isEmpty) {
      _error = 'Cannot disable default features';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (final featureKey in nonDefaultFeatures) {
        _features[featureKey] = false;
      }

      await _saveFeatures();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to disable features: $e';
      notifyListeners();

      return false;
    }
  }

  /// Resets all features to their default values
  ///
  /// Clears all feature flags and saves the default features to SharedPreferences.
  /// Returns true if successful, false otherwise.
  Future<bool> resetFeatures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _features = Map<String, bool>.from(_defaultFeatures);
      await _saveFeatures();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to reset features: $e';
      notifyListeners();

      return false;
    }
  }
}
