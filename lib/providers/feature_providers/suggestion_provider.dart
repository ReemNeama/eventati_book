import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/models/models.dart';

/// Provider to manage suggestions based on the wizard state
///
/// Note: The current implementation uses SharedPreferences for local storage,
/// which has limitations for complex data structures. This will be replaced
/// with Firebase Firestore in the future for better persistence and synchronization.
class SuggestionProvider extends ChangeNotifier {
  /// All available suggestions (predefined + custom)
  List<Suggestion> _allSuggestions = [];

  /// Filtered suggestions based on the current wizard state
  List<Suggestion> _filteredSuggestions = [];

  /// Whether the provider is loading data
  bool _isLoading = false;

  /// Error message if any
  String? _error;

  /// Selected category filter (null means all categories)
  SuggestionCategory? _selectedCategory;

  /// Get all available suggestions
  List<Suggestion> get allSuggestions => _allSuggestions;

  /// Get filtered suggestions
  List<Suggestion> get filteredSuggestions => _filteredSuggestions;

  /// Check if the provider is loading
  bool get isLoading => _isLoading;

  /// Get the error message if any
  String? get error => _error;

  /// Get the selected category filter
  SuggestionCategory? get selectedCategory => _selectedCategory;

  /// Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load predefined suggestions
      final predefinedSuggestions =
          SuggestionTemplates.getPredefinedSuggestions();

      // Load custom suggestions from shared preferences
      final customSuggestions = await _loadCustomSuggestions();

      // Combine all suggestions
      _allSuggestions = [...predefinedSuggestions, ...customSuggestions];
      _filteredSuggestions = List.from(_allSuggestions);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to initialize suggestions: $e';
      notifyListeners();
    }
  }

  /// Filter suggestions based on the wizard state
  void filterSuggestions(WizardState wizardState) {
    _isLoading = true;
    notifyListeners();

    try {
      // Filter suggestions that are relevant for the current wizard state
      final relevantSuggestions =
          _allSuggestions
              .where((suggestion) => suggestion.isRelevantFor(wizardState))
              .toList();

      // We'll sort based on the calculated score later, no need to calculate here

      // Sort by relevance score (highest first)
      relevantSuggestions.sort((a, b) {
        final scoreA = a.calculateRelevanceScore(wizardState);
        final scoreB = b.calculateRelevanceScore(wizardState);
        return scoreB.compareTo(scoreA);
      });

      // Apply category filter if selected
      if (_selectedCategory != null) {
        _filteredSuggestions =
            relevantSuggestions
                .where((suggestion) => suggestion.category == _selectedCategory)
                .toList();
      } else {
        _filteredSuggestions = relevantSuggestions;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to filter suggestions: $e';
      notifyListeners();
    }
  }

  /// Set the category filter and apply it
  void setCategoryFilter(SuggestionCategory? category) {
    _selectedCategory = category;

    // Apply the filter to the current suggestions
    applyCurrentCategoryFilter();

    notifyListeners();
  }

  /// Apply the current category filter to all suggestions
  void applyCurrentCategoryFilter() {
    try {
      if (_selectedCategory != null) {
        // Filter by selected category
        _filteredSuggestions =
            _allSuggestions
                .where((suggestion) => suggestion.category == _selectedCategory)
                .toList();
      } else {
        // No category filter, show all suggestions
        _filteredSuggestions = List.from(_allSuggestions);
      }

      // Sort by relevance score (highest first)
      _filteredSuggestions.sort(
        (a, b) => b.baseRelevanceScore.compareTo(a.baseRelevanceScore),
      );
    } catch (e) {
      _error = 'Failed to apply category filter: $e';
    }
  }

  /// Add a custom suggestion
  Future<bool> addCustomSuggestion(Suggestion suggestion) async {
    try {
      // Add to all suggestions
      _allSuggestions.add(suggestion);

      // Add to filtered suggestions if it matches the current category filter
      if (_selectedCategory == null ||
          suggestion.category == _selectedCategory) {
        _filteredSuggestions.add(suggestion);

        // Sort filtered suggestions by relevance score (if we have a wizard state)
        if (_filteredSuggestions.isNotEmpty) {
          _filteredSuggestions.sort(
            (a, b) => b.baseRelevanceScore.compareTo(a.baseRelevanceScore),
          );
        }
      }

      // Save custom suggestions
      await _saveCustomSuggestions();

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add custom suggestion: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update a suggestion
  Future<bool> updateSuggestion(Suggestion updatedSuggestion) async {
    try {
      // Find the suggestion index
      final index = _allSuggestions.indexWhere(
        (s) => s.id == updatedSuggestion.id,
      );

      if (index == -1) {
        _error = 'Suggestion not found';
        notifyListeners();
        return false;
      }

      // Update the suggestion
      _allSuggestions[index] = updatedSuggestion;

      // If it's a custom suggestion, save to shared preferences
      if (updatedSuggestion.isCustom) {
        await _saveCustomSuggestions();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update suggestion: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a suggestion
  Future<bool> deleteSuggestion(String suggestionId) async {
    try {
      // Find the suggestion
      final suggestion = _allSuggestions.firstWhere(
        (s) => s.id == suggestionId,
      );

      // Only custom suggestions can be deleted
      if (!suggestion.isCustom) {
        _error = 'Only custom suggestions can be deleted';
        notifyListeners();
        return false;
      }

      // Remove from all suggestions
      _allSuggestions.removeWhere((s) => s.id == suggestionId);

      // Remove from filtered suggestions if present
      _filteredSuggestions.removeWhere((s) => s.id == suggestionId);

      // Save custom suggestions
      await _saveCustomSuggestions();

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete suggestion: $e';
      notifyListeners();
      return false;
    }
  }

  /// Load custom suggestions from shared preferences
  Future<List<Suggestion>> _loadCustomSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('custom_suggestions');

      if (jsonData == null) {
        return [];
      }

      final jsonList = jsonDecode(jsonData) as List;

      final suggestions =
          jsonList
              .map((json) => Suggestion.fromJson(json))
              .where(
                (s) => s.isCustom,
              ) // Ensure only custom suggestions are loaded
              .toList();

      return suggestions;
    } catch (e) {
      _error = 'Failed to load custom suggestions: $e';
      notifyListeners();
      return [];
    }
  }

  /// Save custom suggestions to shared preferences
  Future<void> _saveCustomSuggestions() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Filter only custom suggestions
      final customSuggestions =
          _allSuggestions.where((s) => s.isCustom).toList();

      // Convert to JSON
      final jsonList = customSuggestions.map((s) => s.toJson()).toList();
      final jsonData = jsonEncode(jsonList);

      // Save to shared preferences
      await prefs.setString('custom_suggestions', jsonData);
    } catch (e) {
      _error = 'Failed to save custom suggestions: $e';
      notifyListeners();
    }
  }
}
