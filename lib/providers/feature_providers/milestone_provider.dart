import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';

/// Provider for managing milestones and achievements in the event planning process.
///
/// The MilestoneProvider is responsible for:
/// * Tracking user progress through milestones and achievements
/// * Checking for milestone completion based on wizard state
/// * Calculating total points earned from completed milestones
/// * Notifying the UI when new milestones are completed
/// * Persisting milestone status between app sessions
///
/// This provider depends on the WizardProvider to track user progress and
/// determine when milestones are completed. It listens to changes in the
/// wizard state and automatically checks for milestone completion.
///
/// Usage example:
/// ```dart
/// // Access the provider from the widget tree
/// final milestoneProvider = Provider.of<MilestoneProvider>(context);
///
/// // Initialize milestones for a specific event type
/// await milestoneProvider.initializeMilestones('wedding');
///
/// // Get all milestones
/// final allMilestones = milestoneProvider.milestones;
///
/// // Get completed milestones
/// final completedMilestones = milestoneProvider.completedMilestones;
///
/// // Get newly completed milestones (for notifications)
/// final newMilestones = milestoneProvider.newlyCompletedMilestones;
///
/// // Get total points earned
/// final points = milestoneProvider.totalPoints;
///
/// // Get milestones by category
/// final planningMilestones =
///     milestoneProvider.getMilestonesByCategory(MilestoneCategory.planning);
///
/// // Acknowledge a newly completed milestone (dismiss notification)
/// milestoneProvider.acknowledgeNewlyCompletedMilestone('milestone-1');
/// ```
class MilestoneProvider extends ChangeNotifier {
  /// List of all available milestones for the current event type
  List<Milestone> _milestones = [];

  /// List of milestones that have been completed by the user
  List<Milestone> _completedMilestones = [];

  /// List of milestones that have been newly completed and not yet acknowledged
  /// Used for displaying notifications and celebrations to the user
  List<Milestone> _newlyCompletedMilestones = [];

  /// Flag indicating if the provider is currently loading data
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _error;

  /// Reference to the wizard provider for tracking event planning progress
  /// This provider listens to changes in the wizard state to check for milestone completion
  final WizardProvider _wizardProvider;

  /// Creates a new MilestoneProvider with a reference to the WizardProvider
  ///
  /// [_wizardProvider] The wizard provider to track for milestone completion
  ///
  /// Automatically loads milestones based on the current wizard state and
  /// sets up a listener to check for milestone completion when the wizard state changes.
  MilestoneProvider(this._wizardProvider) {
    // Initialize milestones
    _loadMilestones();

    // Listen to wizard state changes
    _wizardProvider.addListener(_checkMilestones);
  }

  /// Returns the list of all available milestones
  ///
  /// This includes both completed and incomplete milestones.
  List<Milestone> get milestones => _milestones;

  /// Returns the list of milestones that have been completed
  ///
  /// These are milestones that have been achieved by the user.
  List<Milestone> get completedMilestones => _completedMilestones;

  /// Returns the list of newly completed milestones that haven't been acknowledged
  ///
  /// These are used for displaying notifications and celebrations to the user.
  /// Once acknowledged, they are removed from this list but remain in completedMilestones.
  List<Milestone> get newlyCompletedMilestones => _newlyCompletedMilestones;

  /// Indicates if the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the error message if an operation has failed, null otherwise
  String? get error => _error;

  /// Calculates the total points earned from all completed milestones
  ///
  /// Each milestone has a point value, and this getter sums up the points
  /// from all completed milestones to give a total score.
  int get totalPoints {
    return _completedMilestones.fold(
      0,
      (sum, milestone) => sum + milestone.points,
    );
  }

  /// Returns all milestones belonging to the specified category
  ///
  /// [category] The milestone category to filter by (e.g., planning, budget, guest)
  ///
  /// This method filters the complete list of milestones by their category
  /// and returns a new list containing only milestones in the specified category.
  List<Milestone> getMilestonesByCategory(MilestoneCategory category) {
    return _milestones.where((m) => m.category == category).toList();
  }

  /// Returns completed milestones belonging to the specified category
  ///
  /// [category] The milestone category to filter by (e.g., planning, budget, guest)
  ///
  /// This method filters the list of completed milestones by their category
  /// and returns a new list containing only completed milestones in the specified category.
  List<Milestone> getCompletedMilestonesByCategory(MilestoneCategory category) {
    return _completedMilestones.where((m) => m.category == category).toList();
  }

  /// Initializes milestones for a specific event type
  ///
  /// [eventType] The type of event (e.g., 'wedding', 'business', 'celebration')
  ///
  /// This method loads the predefined milestone templates for the specified event type,
  /// restores any previously saved milestone status from SharedPreferences,
  /// and checks if any milestones have been completed based on the current wizard state.
  /// Notifies listeners when the operation completes.
  Future<void> initializeMilestones(String eventType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load predefined milestones
      _milestones = MilestoneFactory.getTemplatesForEventType(eventType);

      // Load saved milestone status
      await _loadSavedMilestoneStatus(eventType);

      // Check for completed milestones
      _checkMilestones();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to initialize milestones: $e';
      notifyListeners();
    }
  }

  /// Loads milestones based on the current wizard state
  ///
  /// This private method is called when the provider is initialized.
  /// It retrieves the event type from the wizard state and initializes
  /// the milestones for that event type.
  /// If the wizard state is null (no event in progress), this method does nothing.
  Future<void> _loadMilestones() async {
    if (_wizardProvider.state == null) return;

    final eventType = _wizardProvider.state!.template.id;
    await initializeMilestones(eventType);
  }

  /// Checks all milestones for completion based on the current wizard state
  ///
  /// This method is called automatically when the wizard state changes.
  /// It iterates through all milestones that haven't been completed yet,
  /// checks if they are now completed based on the current wizard state,
  /// and updates the completed and newly completed milestone lists accordingly.
  /// If any milestones are newly completed, it saves the updated status and
  /// notifies listeners so the UI can display notifications or celebrations.
  void _checkMilestones() {
    if (_wizardProvider.state == null) return;

    final wizardState = _wizardProvider.state!;
    _newlyCompletedMilestones = [];

    for (final milestone in _milestones) {
      // Skip milestones that are already completed
      if (milestone.isCompleted) continue;

      // Check if the milestone is completed
      final wasCompleted = milestone.checkCompletion(wizardState);

      if (wasCompleted) {
        _completedMilestones.add(milestone);
        _newlyCompletedMilestones.add(milestone);

        // Save the updated milestone status
        _saveMilestoneStatus();
      }
    }

    // Notify listeners if any milestones were completed
    if (_newlyCompletedMilestones.isNotEmpty) {
      notifyListeners();
    }
  }

  /// Marks a newly completed milestone as acknowledged by the user
  ///
  /// [milestoneId] The ID of the milestone to acknowledge
  ///
  /// This method is called when the user dismisses a milestone notification
  /// or celebration. It removes the milestone from the newly completed list
  /// but keeps it in the completed list. This prevents the same notification
  /// from appearing multiple times.
  /// Notifies listeners so the UI can update accordingly.
  void acknowledgeNewlyCompletedMilestone(String milestoneId) {
    _newlyCompletedMilestones.removeWhere((m) => m.id == milestoneId);
    notifyListeners();
  }

  /// Loads saved milestone status from SharedPreferences
  ///
  /// [eventType] The type of event to load milestone status for
  ///
  /// This method retrieves the saved milestone status from SharedPreferences,
  /// deserializes it from JSON, and updates the milestone objects with their
  /// saved status (completed, locked, etc.) and completion dates.
  /// It also populates the completed milestones list with any milestones
  /// that were previously completed.
  /// If no saved data is found or an error occurs, the error is stored but
  /// no exception is thrown.
  Future<void> _loadSavedMilestoneStatus(String eventType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('milestones_$eventType');

      if (jsonData == null) return;

      final jsonList = jsonDecode(jsonData) as List<dynamic>;
      final savedMilestones =
          jsonList.map((json) {
            final id = json['id'] as String;
            final milestone = _milestones.firstWhere(
              (m) => m.id == id,
              orElse: () => throw Exception('Milestone not found: $id'),
            );

            return milestone.copyWith(
              status: MilestoneStatus.values.firstWhere(
                (e) => e.toString() == json['status'],
                orElse: () => MilestoneStatus.locked,
              ),
              completedDate:
                  json['completedDate'] != null
                      ? DateTime.parse(json['completedDate'])
                      : null,
            );
          }).toList();

      // Update milestones with saved status
      for (final savedMilestone in savedMilestones) {
        final index = _milestones.indexWhere((m) => m.id == savedMilestone.id);
        if (index >= 0) {
          _milestones[index] = savedMilestone;

          // Add to completed milestones if completed
          if (savedMilestone.isCompleted) {
            _completedMilestones.add(savedMilestone);
          }
        }
      }
    } catch (e) {
      _error = 'Failed to load milestone status: $e';
    }
  }

  /// Saves the current milestone status to SharedPreferences
  ///
  /// This method serializes all milestones to JSON and stores them in
  /// SharedPreferences using a key that includes the event type.
  /// This allows different event types to have their own saved milestone status.
  /// If the wizard state is null or an error occurs, the error is stored but
  /// no exception is thrown.
  Future<void> _saveMilestoneStatus() async {
    if (_wizardProvider.state == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final eventType = _wizardProvider.state!.template.id;

      final jsonList =
          _milestones.map((milestone) => milestone.toJson()).toList();
      final jsonData = jsonEncode(jsonList);

      await prefs.setString('milestones_$eventType', jsonData);
    } catch (e) {
      _error = 'Failed to save milestone status: $e';
    }
  }

  /// Resets all milestones to their initial locked state
  ///
  /// This method resets all milestones to their initial locked state,
  /// clears the completed and newly completed milestone lists,
  /// saves the reset status to SharedPreferences, and then checks
  /// if any milestones should be immediately completed based on the
  /// current wizard state.
  /// Notifies listeners when the operation completes.
  /// If the wizard state is null or an error occurs, the error is stored
  /// and listeners are notified.
  Future<void> resetMilestones() async {
    if (_wizardProvider.state == null) return;

    try {
      // Reset milestone status
      for (final milestone in _milestones) {
        milestone.status = MilestoneStatus.locked;
        milestone.completedDate = null;
      }

      _completedMilestones = [];
      _newlyCompletedMilestones = [];

      // Save the reset status
      await _saveMilestoneStatus();

      // Check milestones again
      _checkMilestones();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to reset milestones: $e';
      notifyListeners();
    }
  }

  @override
  /// Cleans up resources when the provider is disposed
  ///
  /// This method removes the listener from the wizard provider to prevent
  /// memory leaks and unnecessary processing when the provider is no longer needed.
  void dispose() {
    // Remove listener from wizard provider
    _wizardProvider.removeListener(_checkMilestones);
    super.dispose();
  }
}
