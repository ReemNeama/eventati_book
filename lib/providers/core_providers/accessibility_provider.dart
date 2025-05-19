import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/utils/core/constants.dart';
import 'package:eventati_book/utils/logger.dart';

/// Model class for accessibility settings
class AccessibilitySettings {
  /// Text scale factor for dynamic text sizing
  final double textScaleFactor;

  /// Whether high contrast mode is enabled
  final bool highContrastEnabled;

  /// Whether to use system text scale factor
  final bool useSystemTextScale;

  /// Whether to reduce animations
  final bool reduceAnimations;

  /// Whether to enable haptic feedback
  final bool enableHapticFeedback;

  /// Constructor
  AccessibilitySettings({
    this.textScaleFactor = 1.0,
    this.highContrastEnabled = false,
    this.useSystemTextScale = true,
    this.reduceAnimations = false,
    this.enableHapticFeedback = true,
  });

  /// Create a copy with some values changed
  AccessibilitySettings copyWith({
    double? textScaleFactor,
    bool? highContrastEnabled,
    bool? useSystemTextScale,
    bool? reduceAnimations,
    bool? enableHapticFeedback,
  }) {
    return AccessibilitySettings(
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      highContrastEnabled: highContrastEnabled ?? this.highContrastEnabled,
      useSystemTextScale: useSystemTextScale ?? this.useSystemTextScale,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'textScaleFactor': textScaleFactor,
      'highContrastEnabled': highContrastEnabled,
      'useSystemTextScale': useSystemTextScale,
      'reduceAnimations': reduceAnimations,
      'enableHapticFeedback': enableHapticFeedback,
    };
  }

  /// Create from JSON
  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      textScaleFactor: json['textScaleFactor'] ?? 1.0,
      highContrastEnabled: json['highContrastEnabled'] ?? false,
      useSystemTextScale: json['useSystemTextScale'] ?? true,
      reduceAnimations: json['reduceAnimations'] ?? false,
      enableHapticFeedback: json['enableHapticFeedback'] ?? true,
    );
  }
}

/// Provider for managing accessibility settings
///
/// The AccessibilityProvider is responsible for:
/// * Managing text scale factor for dynamic text sizing
/// * Managing high contrast mode
/// * Managing other accessibility settings
/// * Persisting settings between app sessions
///
/// This provider uses SharedPreferences for persistent storage of accessibility settings.
class AccessibilityProvider extends ChangeNotifier {
  /// Current accessibility settings
  AccessibilitySettings _settings = AccessibilitySettings();

  /// Whether the provider is loading
  bool _isLoading = false;

  /// Error message if any
  String? _error;

  /// Constructor
  AccessibilityProvider() {
    _loadSettings();
  }

  /// Get current accessibility settings
  AccessibilitySettings get settings => _settings;

  /// Get text scale factor
  double get textScaleFactor => _settings.textScaleFactor;

  /// Get whether high contrast mode is enabled
  bool get highContrastEnabled => _settings.highContrastEnabled;

  /// Get whether to use system text scale factor
  bool get useSystemTextScale => _settings.useSystemTextScale;

  /// Get whether to reduce animations
  bool get reduceAnimations => _settings.reduceAnimations;

  /// Get whether to enable haptic feedback
  bool get enableHapticFeedback => _settings.enableHapticFeedback;

  /// Get whether the provider is loading
  bool get isLoading => _isLoading;

  /// Get error message if any
  String? get error => _error;

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(
        AppConstants.accessibilitySettingsKey,
      );

      if (settingsJson != null) {
        final Map<String, dynamic> settingsData = jsonDecode(settingsJson);
        _settings = AccessibilitySettings.fromJson(settingsData);
      } else {
        // Initialize with default settings
        _settings = AccessibilitySettings();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load accessibility settings: $e';
      Logger.e(_error!, tag: 'AccessibilityProvider');
      notifyListeners();
    }
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings.toJson());
      await prefs.setString(
        AppConstants.accessibilitySettingsKey,
        settingsJson,
      );
    } catch (e) {
      _error = 'Failed to save accessibility settings: $e';
      Logger.e(_error!, tag: 'AccessibilityProvider');
      notifyListeners();
    }
  }

  /// Update text scale factor
  Future<void> updateTextScaleFactor(double factor) async {
    if (factor < 0.5 || factor > 2.0) {
      _error = 'Text scale factor must be between 0.5 and 2.0';
      notifyListeners();
      return;
    }

    _settings = _settings.copyWith(textScaleFactor: factor);
    notifyListeners();
    await _saveSettings();
  }

  /// Toggle high contrast mode
  Future<void> toggleHighContrastMode(bool enabled) async {
    _settings = _settings.copyWith(highContrastEnabled: enabled);
    notifyListeners();
    await _saveSettings();
  }

  /// Toggle use of system text scale factor
  Future<void> toggleUseSystemTextScale(bool enabled) async {
    _settings = _settings.copyWith(useSystemTextScale: enabled);
    notifyListeners();
    await _saveSettings();
  }

  /// Toggle reduce animations
  Future<void> toggleReduceAnimations(bool enabled) async {
    _settings = _settings.copyWith(reduceAnimations: enabled);
    notifyListeners();
    await _saveSettings();
  }

  /// Toggle haptic feedback
  Future<void> toggleHapticFeedback(bool enabled) async {
    _settings = _settings.copyWith(enableHapticFeedback: enabled);
    notifyListeners();
    await _saveSettings();
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _settings = AccessibilitySettings();
    notifyListeners();
    await _saveSettings();
  }
}
