import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/models/models.dart';

/// Provider for managing event planning suggestions based on the wizard state.
///
/// The SuggestionProvider is responsible for:
/// * Managing predefined and custom suggestions for event planning
/// * Filtering suggestions based on the current wizard state
/// * Calculating relevance scores for suggestions
/// * Allowing users to create, update, and delete custom suggestions
/// * Persisting custom suggestions between app sessions
///
/// Suggestions are filtered and sorted based on their relevance to the current
/// event being planned. The provider also supports filtering by category to help
/// users find specific types of suggestions.
///
/// Note: The current implementation uses SharedPreferences for local storage,
/// which has limitations for complex data structures. This will be replaced
/// with Supabase in the future for better persistence and synchronization.
///
/// Usage example:
/// ```dart
/// // Access the provider from the widget tree
/// final suggestionProvider = Provider.of<SuggestionProvider>(context);
///
/// // Initialize the provider (typically done in main.dart or when entering the suggestions screen)
/// await suggestionProvider.initialize();
///
/// // Filter suggestions based on the current wizard state
/// final wizardProvider = Provider.of<WizardProvider>(context, listen: false);
/// if (wizardProvider.state != null) {
///   suggestionProvider.filterSuggestions(wizardProvider.state!);
/// }
///
/// // Filter suggestions by category
/// suggestionProvider.setCategoryFilter(SuggestionCategory.venue);
///
/// // Get filtered suggestions
/// final suggestions = suggestionProvider.filteredSuggestions;
///
/// // Add a custom suggestion
/// final newSuggestion = Suggestion(
///   id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
///   title: 'My Custom Suggestion',
///   description: 'This is a custom suggestion I created',
///   category: SuggestionCategory.venue,
///   priority: SuggestionPriority.medium,
///   baseRelevanceScore: 70,
///   conditions: [],
///   applicableEventTypes: ['wedding', 'business', 'celebration'],
///   isCustom: true,
/// );
/// await suggestionProvider.addCustomSuggestion(newSuggestion);
/// ```
class SuggestionProvider extends ChangeNotifier {
  /// Complete list of all available suggestions, including both predefined and custom
  List<Suggestion> _allSuggestions = [];

  /// List of suggestions filtered based on the current wizard state and category filter
  List<Suggestion> _filteredSuggestions = [];

  /// Flag indicating if the provider is currently loading data
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _error;

  /// The currently selected category filter, or null if no category filter is applied
  SuggestionCategory? _selectedCategory;

  /// Returns the complete list of all available suggestions
  ///
  /// This includes both predefined suggestions from SuggestionTemplates and
  /// custom suggestions created by the user.
  List<Suggestion> get allSuggestions => _allSuggestions;

  /// Returns the list of suggestions filtered by the current wizard state and category
  ///
  /// These suggestions are filtered based on their relevance to the current
  /// wizard state and the selected category filter (if any). They are sorted
  /// by relevance score in descending order (most relevant first).
  List<Suggestion> get filteredSuggestions => _filteredSuggestions;

  /// Indicates if the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the error message if an operation has failed, null otherwise
  String? get error => _error;

  /// Returns the currently selected category filter, or null if no filter is applied
  ///
  /// When null, suggestions from all categories are shown (subject to wizard state filtering).
  /// When set to a specific category, only suggestions from that category are shown.
  SuggestionCategory? get selectedCategory => _selectedCategory;

  /// Initializes the provider by loading predefined and custom suggestions
  ///
  /// This method loads all predefined suggestions from SuggestionTemplates and
  /// all custom suggestions from SharedPreferences, combines them into a single list,
  /// and initializes both the allSuggestions and filteredSuggestions lists.
  ///
  /// This should be called when the app starts or when entering the suggestions screen.
  /// Notifies listeners when the operation completes.
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

  /// Filters suggestions based on their relevance to the current wizard state
  ///
  /// [wizardState] The current state of the event wizard
  ///
  /// This method filters the complete list of suggestions to include only those
  /// that are relevant for the current wizard state, sorts them by relevance score
  /// (highest first), and then applies any category filter that may be set.
  ///
  /// Each suggestion's relevance is determined by its isRelevantFor method, which
  /// checks if the suggestion's conditions are met by the wizard state.
  ///
  /// Notifies listeners when the operation completes.
  void filterSuggestions(WizardState wizardState) {
    _isLoading = true;
    notifyListeners();

    try {
      // Filter suggestions that are relevant for the current wizard state
      final relevantSuggestions =
          _allSuggestions
              .where((suggestion) => suggestion.isRelevantFor(wizardState))
              .toList();

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

  /// Sets the category filter and applies it to the current suggestions
  ///
  /// [category] The category to filter by, or null to show all categories
  ///
  /// This method updates the selected category filter and then applies it to
  /// the current list of suggestions. When category is null, all suggestions
  /// are shown (subject to wizard state filtering). When category is set to a
  /// specific value, only suggestions from that category are shown.
  ///
  /// Notifies listeners when the operation completes.
  void setCategoryFilter(SuggestionCategory? category) {
    _selectedCategory = category;

    // Apply the filter to the current suggestions
    applyCurrentCategoryFilter();

    notifyListeners();
  }

  /// Applies the current category filter to the list of suggestions
  ///
  /// This method filters the list of suggestions based on the currently selected
  /// category filter. If no category filter is selected, all suggestions are shown.
  /// The filtered suggestions are then sorted by their base relevance score.
  ///
  /// This method is called internally by setCategoryFilter and does not notify listeners.
  /// If an error occurs, it is stored in the error property but no exception is thrown.
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

  /// Adds a custom suggestion to the list of suggestions
  ///
  /// [suggestion] The custom suggestion to add
  ///
  /// This method adds a custom suggestion to the list of all suggestions and,
  /// if it matches the current category filter, to the list of filtered suggestions.
  /// It then saves the updated list of custom suggestions to SharedPreferences.
  ///
  /// Returns true if the suggestion was successfully added, false otherwise.
  /// Notifies listeners when the operation completes.
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

  /// Updates an existing suggestion with new information
  ///
  /// [updatedSuggestion] The updated suggestion (must have the same ID as an existing suggestion)
  ///
  /// This method updates an existing suggestion with new information. If the
  /// suggestion is a custom suggestion, it also saves the updated list of custom
  /// suggestions to SharedPreferences.
  ///
  /// Returns true if the suggestion was successfully updated, false otherwise.
  /// Notifies listeners when the operation completes.
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

  /// Deletes a suggestion from the list of suggestions
  ///
  /// [suggestionId] The ID of the suggestion to delete
  ///
  /// This method removes a suggestion from the list of all suggestions and,
  /// if present, from the list of filtered suggestions. Only custom suggestions
  /// can be deleted; predefined suggestions cannot be deleted.
  ///
  /// Returns true if the suggestion was successfully deleted, false otherwise.
  /// Notifies listeners when the operation completes.
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

  /// Loads custom suggestions from SharedPreferences
  ///
  /// This private method retrieves the saved custom suggestions from SharedPreferences,
  /// deserializes them from JSON, and returns them as a list of Suggestion objects.
  /// It ensures that only suggestions with isCustom=true are loaded.
  ///
  /// Returns an empty list if no custom suggestions are found or if an error occurs.
  /// If an error occurs, it is stored in the error property and listeners are notified.
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

  /// Saves custom suggestions to SharedPreferences
  ///
  /// This private method filters the list of all suggestions to include only
  /// those with isCustom=true, serializes them to JSON, and saves them to
  /// SharedPreferences.
  ///
  /// If an error occurs, it is stored in the error property and listeners are notified.
  /// Note: This method is called automatically by addCustomSuggestion, updateSuggestion,
  /// and deleteSuggestion, so there's no need to call it directly.
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
