import 'package:flutter/foundation.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/services.dart';
import 'package:eventati_book/providers/core_providers/auth_provider.dart';

/// Provider for managing saved comparisons
class ComparisonSavingProvider extends ChangeNotifier {
  /// The comparison saving service
  final ComparisonSavingService _comparisonSavingService;

  /// The auth provider
  final AuthProvider _authProvider;

  /// List of saved comparisons
  List<SavedComparison> _savedComparisons = [];

  /// Whether the provider is loading data
  bool _isLoading = false;

  /// Error message if any
  String? _error;

  /// Constructor
  ComparisonSavingProvider({
    required ComparisonSavingService comparisonSavingService,
    required AuthProvider authProvider,
  }) : _comparisonSavingService = comparisonSavingService,
       _authProvider = authProvider {
    // Load saved comparisons when the provider is created
    refreshData();
  }

  /// Get the list of saved comparisons
  List<SavedComparison> get savedComparisons => _savedComparisons;

  /// Whether the provider is loading data
  bool get isLoading => _isLoading;

  /// Error message if any
  String? get error => _error;

  /// Refresh the list of saved comparisons
  Future<void> refreshData() async {
    // Check if the user is logged in
    final userId = _authProvider.currentUser?.id;
    if (userId == null) {
      _error = 'You must be logged in to view saved comparisons';
      notifyListeners();
      return;
    }

    // Set loading state
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load saved comparisons
      final comparisons = await _comparisonSavingService.getSavedComparisons(
        userId,
      );

      // Update state
      _savedComparisons = comparisons;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Update error state
      _error = 'Failed to load saved comparisons: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save a comparison
  Future<bool> saveComparison({
    required String serviceType,
    required List<dynamic> services,
    required String title,
    String notes = '',
    String? eventId,
    String? eventName,
  }) async {
    // Check if the user is logged in
    final userId = _authProvider.currentUser?.id;
    if (userId == null) {
      _error = 'You must be logged in to save comparisons';
      notifyListeners();
      return false;
    }

    // Set loading state
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Save the comparison
      await _comparisonSavingService.saveComparison(
        userId: userId,
        serviceType: serviceType,
        services: services,
        title: title,
        notes: notes,
        eventId: eventId,
        eventName: eventName,
      );

      // Refresh the list
      await refreshData();

      return true;
    } catch (e) {
      // Update error state
      _error = 'Failed to save comparison: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update a saved comparison
  Future<bool> updateSavedComparison(SavedComparison comparison) async {
    // Check if the user is logged in
    final userId = _authProvider.currentUser?.id;
    if (userId == null) {
      _error = 'You must be logged in to update comparisons';
      notifyListeners();
      return false;
    }

    // Set loading state
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update the comparison in the database
      // This is a placeholder - we'll need to implement this in the service
      // For now, we'll just refresh the list
      await refreshData();

      return true;
    } catch (e) {
      // Update error state
      _error = 'Failed to update comparison: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a saved comparison
  Future<bool> deleteSavedComparison(String comparisonId) async {
    // Check if the user is logged in
    final userId = _authProvider.currentUser?.id;
    if (userId == null) {
      _error = 'You must be logged in to delete comparisons';
      notifyListeners();
      return false;
    }

    // Set loading state
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Delete the comparison
      final success = await _comparisonSavingService.deleteSavedComparison(
        comparisonId,
      );

      if (success) {
        // Remove the comparison from the list
        _savedComparisons.removeWhere(
          (comparison) => comparison.id == comparisonId,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to delete comparison';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Update error state
      _error = 'Failed to delete comparison: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get saved comparisons by service type
  List<SavedComparison> getSavedComparisonsByType(String serviceType) {
    return _savedComparisons
        .where(
          (comparison) =>
              comparison.serviceType.toLowerCase() == serviceType.toLowerCase(),
        )
        .toList();
  }

  /// Get a saved comparison by ID
  SavedComparison? getSavedComparisonById(String comparisonId) {
    try {
      return _savedComparisons.firstWhere(
        (comparison) => comparison.id == comparisonId,
      );
    } catch (e) {
      return null;
    }
  }
}
