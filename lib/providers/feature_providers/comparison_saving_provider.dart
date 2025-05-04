import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/utils/constants.dart';

/// Provider for managing saved service comparisons.
///
/// The ComparisonSavingProvider is responsible for:
/// * Saving service comparisons for future reference
/// * Loading previously saved comparisons from persistent storage
/// * Updating and deleting saved comparisons
/// * Filtering comparisons by service type or event
/// * Ensuring comparisons are associated with the current user
///
/// This provider allows users to save their service comparisons for later review,
/// making it easier to make final decisions about which services to book.
/// Comparisons are stored in SharedPreferences and are associated with the current
/// user's ID to ensure privacy and data separation.
///
/// Usage example:
/// ```dart
/// // Access the provider from the widget tree
/// final savingProvider = Provider.of<ComparisonSavingProvider>(context);
///
/// // Save a new comparison
/// await savingProvider.saveComparison(
///   serviceType: 'Venue',
///   serviceIds: ['venue1', 'venue2', 'venue3'],
///   serviceNames: ['Grand Hall', 'Beach Resort', 'Mountain Lodge'],
///   title: 'My Venue Comparison',
///   notes: 'Comparing venues for my wedding',
///   eventId: 'wedding123',
///   eventName: 'My Wedding',
/// );
///
/// // Get all saved comparisons
/// final allComparisons = savingProvider.savedComparisons;
///
/// // Get comparisons for a specific service type
/// final venueComparisons = savingProvider.getSavedComparisonsByType('Venue');
///
/// // Get comparisons for a specific event
/// final weddingComparisons = savingProvider.getSavedComparisonsByEvent('wedding123');
///
/// // Update an existing comparison
/// final updatedComparison = existingComparison.copyWith(
///   title: 'Updated Title',
///   notes: 'Updated notes',
/// );
/// await savingProvider.updateSavedComparison(updatedComparison);
///
/// // Delete a comparison
/// await savingProvider.deleteSavedComparison('comparison123');
///
/// // Refresh data (e.g., after user login)
/// await savingProvider.refreshData();
/// ```
class ComparisonSavingProvider extends ChangeNotifier {
  /// List of all saved comparisons for the current user
  ///
  /// This list contains all SavedComparison objects that have been loaded from
  /// persistent storage. It's filtered to only include comparisons belonging to
  /// the current user or anonymous comparisons.
  List<SavedComparison> _savedComparisons = [];

  /// Flag indicating if the provider is currently loading data
  ///
  /// This is used to show loading indicators in the UI while operations
  /// like loading, saving, updating, or deleting are in progress.
  bool _isLoading = false;

  /// Error message if an operation fails
  ///
  /// This stores any error messages that occur during operations like
  /// loading, saving, updating, or deleting comparisons.
  String? _error;

  /// Reference to the AuthProvider for accessing user information
  ///
  /// This is used to associate saved comparisons with the current user
  /// and to filter comparisons when loading from persistent storage.
  final AuthProvider _authProvider;

  /// Creates a new ComparisonSavingProvider with the specified AuthProvider
  ///
  /// [_authProvider] The AuthProvider to use for user information
  ///
  /// This constructor automatically loads saved comparisons from persistent
  /// storage when the provider is created.
  ComparisonSavingProvider(this._authProvider) {
    loadSavedComparisons();
  }

  /// Returns the list of all saved comparisons for the current user
  ///
  /// This list is sorted by creation date (newest first) and filtered
  /// to only include comparisons belonging to the current user or
  /// anonymous comparisons.
  List<SavedComparison> get savedComparisons => _savedComparisons;

  /// Indicates if the provider is currently loading data
  ///
  /// UI components can use this to show loading indicators.
  bool get isLoading => _isLoading;

  /// Returns the error message if an operation has failed, null otherwise
  ///
  /// UI components can use this to display error messages to the user.
  String? get error => _error;

  /// Returns saved comparisons filtered by service type
  ///
  /// [serviceType] The type of service to filter by (e.g., 'Venue', 'Catering')
  ///
  /// This method filters the list of saved comparisons to include only those
  /// for the specified service type. This is useful when displaying comparisons
  /// in service-specific screens or when organizing comparisons by category.
  ///
  /// Returns a new list containing only comparisons of the specified service type.
  List<SavedComparison> getSavedComparisonsByType(String serviceType) {
    return _savedComparisons
        .where((comparison) => comparison.serviceType == serviceType)
        .toList();
  }

  /// Returns saved comparisons filtered by event ID
  ///
  /// [eventId] The ID of the event to filter by
  ///
  /// This method filters the list of saved comparisons to include only those
  /// associated with a specific event. This is useful when displaying all
  /// comparisons related to a particular event the user is planning.
  ///
  /// Returns a new list containing only comparisons for the specified event.
  List<SavedComparison> getSavedComparisonsByEvent(String eventId) {
    return _savedComparisons
        .where((comparison) => comparison.eventId == eventId)
        .toList();
  }

  /// Saves a new service comparison
  ///
  /// [serviceType] The type of service being compared (e.g., 'Venue', 'Catering')
  /// [serviceIds] List of unique identifiers for the services being compared
  /// [serviceNames] List of display names for the services being compared
  /// [title] User-defined title for the comparison
  /// [notes] Optional user notes about the comparison
  /// [eventId] Optional ID of the event this comparison is associated with
  /// [eventName] Optional name of the event this comparison is associated with
  ///
  /// This method creates a new SavedComparison object with a unique ID and
  /// the current user's ID, adds it to the list of saved comparisons, and
  /// persists it to SharedPreferences.
  ///
  /// Returns true if the comparison was successfully saved, false otherwise.
  /// Sets the error property and notifies listeners if an error occurs.
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

  /// Updates an existing saved comparison
  ///
  /// [updatedComparison] The SavedComparison object with updated values
  ///
  /// This method finds an existing comparison by ID and replaces it with
  /// the updated version. It then persists the changes to SharedPreferences.
  /// The updated comparison must have the same ID as an existing comparison.
  ///
  /// Returns true if the comparison was successfully updated, false otherwise.
  /// Sets the error property and notifies listeners if an error occurs.
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

  /// Deletes a saved comparison by ID
  ///
  /// [id] The unique identifier of the comparison to delete
  ///
  /// This method removes a comparison from the list of saved comparisons
  /// and persists the change to SharedPreferences.
  ///
  /// Returns true if the comparison was successfully deleted, false otherwise.
  /// Sets the error property and notifies listeners if an error occurs.
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

  /// Deletes all saved comparisons for the current user
  ///
  /// This method clears the list of saved comparisons and persists
  /// the change to SharedPreferences. This is useful when the user
  /// wants to start fresh or when they're cleaning up their data.
  ///
  /// Returns true if all comparisons were successfully deleted, false otherwise.
  /// Sets the error property and notifies listeners if an error occurs.
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

  /// Loads saved comparisons from SharedPreferences
  ///
  /// This method retrieves saved comparisons from SharedPreferences,
  /// deserializes them from JSON, filters them to include only those
  /// belonging to the current user or anonymous comparisons, and sorts
  /// them by creation date (newest first).
  ///
  /// It handles errors gracefully by:
  /// 1. Skipping individual comparisons that fail to parse
  /// 2. Continuing with an empty list if the entire JSON data fails to parse
  /// 3. Setting the error property and notifying listeners if an error occurs
  ///
  /// This method is called automatically when the provider is created and
  /// can be called manually to refresh the data.
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

  /// Refreshes the saved comparisons data
  ///
  /// This method reloads saved comparisons from SharedPreferences.
  /// It's useful for manual refresh operations, such as when the user
  /// pulls to refresh or when they log in/out and need to see updated data.
  ///
  /// This is a convenience method that simply calls loadSavedComparisons().
  Future<void> refreshData() async {
    await loadSavedComparisons();
  }

  /// Saves the current list of comparisons to SharedPreferences
  ///
  /// This private method serializes the list of saved comparisons to JSON
  /// and stores it in SharedPreferences. It filters out any invalid comparisons
  /// before saving to ensure data integrity.
  ///
  /// This method is called automatically by the CRUD operations (save, update, delete)
  /// and should not need to be called directly.
  ///
  /// Sets the error property and notifies listeners if an error occurs.
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
