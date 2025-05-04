import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';

/// Provider to manage milestones and achievements
class MilestoneProvider extends ChangeNotifier {
  /// All available milestones
  List<Milestone> _milestones = [];

  /// Milestones that have been completed
  List<Milestone> _completedMilestones = [];

  /// Milestones that have been newly completed (for notifications)
  List<Milestone> _newlyCompletedMilestones = [];

  /// Whether the provider is loading data
  bool _isLoading = false;

  /// Error message if any
  String? _error;

  /// Reference to the wizard provider
  final WizardProvider _wizardProvider;

  /// Constructor
  MilestoneProvider(this._wizardProvider) {
    // Initialize milestones
    _loadMilestones();

    // Listen to wizard state changes
    _wizardProvider.addListener(_checkMilestones);
  }

  /// Get all milestones
  List<Milestone> get milestones => _milestones;

  /// Get completed milestones
  List<Milestone> get completedMilestones => _completedMilestones;

  /// Get newly completed milestones
  List<Milestone> get newlyCompletedMilestones => _newlyCompletedMilestones;

  /// Check if the provider is loading
  bool get isLoading => _isLoading;

  /// Get the error message if any
  String? get error => _error;

  /// Get total points earned
  int get totalPoints {
    return _completedMilestones.fold(
      0,
      (sum, milestone) => sum + milestone.points,
    );
  }

  /// Get milestones by category
  List<Milestone> getMilestonesByCategory(MilestoneCategory category) {
    return _milestones.where((m) => m.category == category).toList();
  }

  /// Get completed milestones by category
  List<Milestone> getCompletedMilestonesByCategory(MilestoneCategory category) {
    return _completedMilestones.where((m) => m.category == category).toList();
  }

  /// Initialize milestones for the current event type
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

  /// Load milestones based on the current wizard state
  Future<void> _loadMilestones() async {
    if (_wizardProvider.state == null) return;

    final eventType = _wizardProvider.state!.template.id;
    await initializeMilestones(eventType);
  }

  /// Check for milestone completion
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

  /// Mark a newly completed milestone as acknowledged
  void acknowledgeNewlyCompletedMilestone(String milestoneId) {
    _newlyCompletedMilestones.removeWhere((m) => m.id == milestoneId);
    notifyListeners();
  }

  /// Load saved milestone status from shared preferences
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

  /// Save milestone status to shared preferences
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

  /// Reset all milestones
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
  void dispose() {
    // Remove listener from wizard provider
    _wizardProvider.removeListener(_checkMilestones);
    super.dispose();
  }
}
