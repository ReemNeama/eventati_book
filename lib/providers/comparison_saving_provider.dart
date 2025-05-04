import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/auth_provider.dart';
import 'package:eventati_book/utils/constants.dart';

/// Provider to manage saved comparisons
class ComparisonSavingProvider extends ChangeNotifier {
  /// List of saved comparisons
  List<SavedComparison> _savedComparisons = [];

  /// Whether the provider is loading data
  bool _isLoading = false;

  /// Error message if any
  String? _error;

  /// Auth provider for user information
  final AuthProvider _authProvider;

  /// Constructor
  ComparisonSavingProvider(this._authProvider) {
    loadSavedComparisons();
  }

  /// Getters
  List<SavedComparison> get savedComparisons => _savedComparisons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get saved comparisons for a specific service type
  List<SavedComparison> getSavedComparisonsByType(String serviceType) {
    return _savedComparisons
        .where((comparison) => comparison.serviceType == serviceType)
        .toList();
  }

  /// Get saved comparisons for a specific event
  List<SavedComparison> getSavedComparisonsByEvent(String eventId) {
    return _savedComparisons
        .where((comparison) => comparison.eventId == eventId)
        .toList();
  }

  /// Save a new comparison
  Future<bool> saveComparison({
    required String serviceType,
    required List<String> serviceIds,
    required List<String> serviceNames,
    required String title,
    String notes = '',
    String? eventId,
    String? eventName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Generate a unique ID
      final id = const Uuid().v4();

      // Create the saved comparison
      final savedComparison = SavedComparison(
        id: id,
        userId: _authProvider.user?.id ?? 'anonymous',
        serviceType: serviceType,
        serviceIds: serviceIds,
        serviceNames: serviceNames,
        createdAt: DateTime.now(),
        title: title,
        notes: notes,
        eventId: eventId,
        eventName: eventName,
      );

      // Add to the list
      _savedComparisons.add(savedComparison);

      // Save to shared preferences
      await _saveSavedComparisons();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save comparison: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing saved comparison
  Future<bool> updateSavedComparison(SavedComparison updatedComparison) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Find the index of the comparison to update
      final index = _savedComparisons.indexWhere(
        (comparison) => comparison.id == updatedComparison.id,
      );

      if (index == -1) {
        _error = 'Comparison not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Update the comparison
      _savedComparisons[index] = updatedComparison;

      // Save to shared preferences
      await _saveSavedComparisons();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update comparison: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a saved comparison
  Future<bool> deleteSavedComparison(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Remove the comparison
      _savedComparisons.removeWhere((comparison) => comparison.id == id);

      // Save to shared preferences
      await _saveSavedComparisons();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete comparison: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete all saved comparisons
  Future<bool> deleteAllSavedComparisons() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear the list
      _savedComparisons.clear();

      // Save to shared preferences
      await _saveSavedComparisons();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete all comparisons: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load saved comparisons from shared preferences
  Future<void> loadSavedComparisons() async {
    try {
      _error = null; // Clear any previous errors
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(AppConstants.savedComparisonsKey);

      // Initialize with empty list
      _savedComparisons = [];

      if (jsonData != null && jsonData.isNotEmpty) {
        try {
          final jsonList = jsonDecode(jsonData) as List;

          // Parse each comparison, skipping any that fail to parse
          for (var item in jsonList) {
            try {
              final comparison = SavedComparison.fromJson(item);
              // Only add if ID is not empty (valid comparison)
              if (comparison.id.isNotEmpty) {
                _savedComparisons.add(comparison);
              }
            } catch (parseError) {
              // Skip this item but continue processing others
              debugPrint('Error parsing comparison: $parseError');
            }
          }

          // Filter comparisons for the current user
          if (_authProvider.user != null) {
            _savedComparisons =
                _savedComparisons
                    .where(
                      (comparison) =>
                          comparison.userId == _authProvider.user!.id ||
                          comparison.userId == 'anonymous',
                    )
                    .toList();
          }

          // Sort by creation date (newest first)
          _savedComparisons.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } catch (parseError) {
          _error = 'Failed to parse saved comparisons: $parseError';
          // Continue with empty list
          _savedComparisons = [];
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load saved comparisons: $e';
      _isLoading = false;
      _savedComparisons = []; // Ensure we have an empty list rather than null
      notifyListeners();
    }
  }

  /// Refresh data - useful for manual refresh
  Future<void> refreshData() async {
    await loadSavedComparisons();
  }

  /// Save saved comparisons to shared preferences
  Future<void> _saveSavedComparisons() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Filter out any invalid comparisons before saving
      final validComparisons =
          _savedComparisons
              .where((c) => c.id.isNotEmpty && c.serviceType.isNotEmpty)
              .toList();

      final jsonList = validComparisons.map((c) => c.toJson()).toList();
      final jsonData = jsonEncode(jsonList);

      final success = await prefs.setString(
        AppConstants.savedComparisonsKey,
        jsonData,
      );

      if (!success) {
        _error = 'Failed to save comparisons: SharedPreferences returned false';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to save comparisons: $e';
      notifyListeners();
    }
  }
}
