import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/wizard_connection_service.dart';
import 'package:eventati_book/services/firebase/firestore/wizard_state_firestore_service.dart';

/// Provider to manage the state of the event wizard throughout the application.
///
/// The WizardProvider is responsible for:
/// * Initializing the event wizard with a template
/// * Managing the wizard's state as users progress through steps
/// * Storing and retrieving wizard state data
/// * Validating user inputs at each step
/// * Connecting wizard data to other planning tools upon completion
/// * Persisting wizard state between app sessions
///
/// This provider uses SharedPreferences for persistent storage of wizard state.
/// When a wizard is completed, it connects the collected data to other planning tools
/// like budget, guest list, and timeline through the WizardConnectionService.
///
/// Usage example:
/// ```dart
/// // Access the provider
/// final wizardProvider = Provider.of<WizardProvider>(context, listen: false);
///
/// // Initialize with a template
/// await wizardProvider.initializeWizard(eventTemplate);
///
/// // Update wizard data
/// wizardProvider.updateEventName('My Wedding');
/// wizardProvider.updateEventDate(DateTime(2023, 6, 15));
/// wizardProvider.updateGuestCount(150);
///
/// // Navigate through steps
/// if (wizardProvider.nextStep()) {
///   // Move to next screen or update UI
/// }
///
/// // Complete the wizard
/// wizardProvider.completeWizard(context);
/// ```
class WizardProvider extends ChangeNotifier {
  /// Current state of the wizard
  WizardState? _state;

  /// Whether the provider is loading data
  bool _isLoading = false;

  /// Error message if any
  String? _error;

  /// Current user ID
  String? _userId;

  /// Current event ID
  String? _eventId;

  /// Whether to use Firebase for persistence
  bool _useFirebase = false;

  /// Firestore service for wizard state
  final WizardStateFirestoreService _firestoreService =
      WizardStateFirestoreService();

  /// Get the current wizard state
  WizardState? get state => _state;

  /// Check if the provider is loading
  bool get isLoading => _isLoading;

  /// Get the error message if any
  String? get error => _error;

  /// Get whether Firebase is being used for persistence
  bool get useFirebase => _useFirebase;

  /// Set whether to use Firebase for persistence
  set useFirebase(bool value) {
    _useFirebase = value;
    notifyListeners();
  }

  /// Initialize with user and event IDs for Firebase persistence
  void initializeWithIds(String userId, String eventId) {
    _userId = userId;
    _eventId = eventId;
    _useFirebase = true;
    notifyListeners();
  }

  /// Explicitly save the current state to Firebase
  Future<void> saveStateToFirebase() async {
    if (_state == null ||
        !_useFirebase ||
        _userId == null ||
        _eventId == null) {
      return;
    }

    try {
      await _firestoreService.saveWizardState(_userId!, _eventId!, _state!);
      debugPrint('Explicitly saved wizard state to Firebase');
    } catch (e) {
      _error = 'Failed to save wizard state to Firebase: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Initialize the wizard with a template
  Future<void> initializeWizard(EventTemplate template) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if there's a saved state for this template
      final savedState = await _loadSavedState(template.id);

      if (savedState != null) {
        _state = savedState;
      } else {
        // Create a new state with the template
        _state = WizardState(template: template);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to initialize wizard: $e';
      notifyListeners();
    }
  }

  /// Update the event name
  void updateEventName(String name) {
    if (_state == null) return;

    _state = _state!.copyWith(eventName: name);
    _saveState();
    notifyListeners();
  }

  /// Update the selected event type
  void updateEventType(String type) {
    if (_state == null) return;

    _state = _state!.copyWith(selectedEventType: type);
    _saveState();
    notifyListeners();
  }

  /// Update the event date
  void updateEventDate(DateTime date) {
    if (_state == null) return;

    _state = _state!.copyWith(eventDate: date);
    _saveState();
    notifyListeners();
  }

  /// Update the guest count
  void updateGuestCount(int count) {
    if (_state == null) return;

    _state = _state!.copyWith(guestCount: count);
    _saveState();
    notifyListeners();
  }

  /// Update a service selection
  void updateServiceSelection(String service, bool selected) {
    if (_state == null) return;

    final updatedServices = Map<String, bool>.from(_state!.selectedServices);
    updatedServices[service] = selected;

    _state = _state!.copyWith(selectedServices: updatedServices);
    _saveState();
    notifyListeners();
  }

  /// Update the event duration (for business events)
  void updateEventDuration(int days) {
    if (_state == null) return;

    _state = _state!.copyWith(eventDuration: days);
    _saveState();
    notifyListeners();
  }

  /// Update the daily start time (for business events)
  void updateDailyStartTime(TimeOfDay time) {
    if (_state == null) return;

    _state = _state!.copyWith(dailyStartTime: time);
    _saveState();
    notifyListeners();
  }

  /// Update the daily end time (for business events)
  void updateDailyEndTime(TimeOfDay time) {
    if (_state == null) return;

    _state = _state!.copyWith(dailyEndTime: time);
    _saveState();
    notifyListeners();
  }

  /// Update setup needs (for business events)
  void updateSetupNeeds(bool needsSetup) {
    if (_state == null) return;

    _state = _state!.copyWith(needsSetup: needsSetup);
    _saveState();
    notifyListeners();
  }

  /// Update setup hours (for business events)
  void updateSetupHours(int hours) {
    if (_state == null) return;

    _state = _state!.copyWith(setupHours: hours);
    _saveState();
    notifyListeners();
  }

  /// Update teardown needs (for business events)
  void updateTeardownNeeds(bool needsTeardown) {
    if (_state == null) return;

    _state = _state!.copyWith(needsTeardown: needsTeardown);
    _saveState();
    notifyListeners();
  }

  /// Update teardown hours (for business events)
  void updateTeardownHours(int hours) {
    if (_state == null) return;

    _state = _state!.copyWith(teardownHours: hours);
    _saveState();
    notifyListeners();
  }

  /// Move to the next step in the wizard
  bool nextStep() {
    if (_state == null) return false;

    // Check if the current step is valid
    if (!_state!.isStepValid(_state!.currentStep)) {
      return false;
    }

    // Check if we're already at the last step
    if (_state!.currentStep >= _state!.totalSteps - 1) {
      // Mark as completed
      _state = _state!.copyWith(isCompleted: true);
      _saveState();
      notifyListeners();

      return true;
    }

    // Move to the next step
    _state = _state!.copyWith(currentStep: _state!.currentStep + 1);
    _saveState();
    notifyListeners();

    return true;
  }

  /// Move to the previous step in the wizard
  bool previousStep() {
    if (_state == null) return false;

    // Check if we're already at the first step
    if (_state!.currentStep <= 0) {
      return false;
    }

    // Move to the previous step
    _state = _state!.copyWith(currentStep: _state!.currentStep - 1);
    _saveState();
    notifyListeners();

    return true;
  }

  /// Go to a specific step in the wizard
  bool goToStep(int step) {
    if (_state == null) return false;

    // Check if the step is valid
    if (step < 0 || step >= _state!.totalSteps) {
      return false;
    }

    // Go to the step
    _state = _state!.copyWith(currentStep: step);
    _saveState();
    notifyListeners();

    return true;
  }

  /// Complete the wizard
  void completeWizard(BuildContext context) {
    if (_state == null) return;

    _state = _state!.copyWith(isCompleted: true);
    _saveState();

    // Connect to planning tools
    _connectToPlanningTools(context);

    notifyListeners();
  }

  /// Connect the wizard to all planning tools
  void _connectToPlanningTools(BuildContext context) {
    if (_state == null) return;

    try {
      // Convert WizardState to Map<String, dynamic>
      final wizardData = _state!.toJson();

      // Connect to all planning tools
      WizardConnectionService.connectToAllPlanningTools(context, wizardData);
    } catch (e) {
      debugPrint('Error connecting wizard to planning tools: $e');
      _error = 'Failed to connect to planning tools: $e';
      notifyListeners();
    }
  }

  /// Reset the wizard
  void resetWizard() {
    if (_state == null) return;

    // Create a new state with the same template
    _state = WizardState(template: _state!.template);
    _saveState();
    notifyListeners();
  }

  /// Clear the wizard state from all storage
  Future<void> clearWizard() async {
    if (_state == null) return;

    try {
      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('wizard_${_state!.template.id}');

      // If Firebase is enabled, also clear from Firestore
      if (_useFirebase && _userId != null && _eventId != null) {
        await _firestoreService.deleteWizardState(_userId!, _eventId!);
        debugPrint('Deleted wizard state from Firebase');
      }

      _state = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear wizard state: $e';
      notifyListeners();
    }
  }

  /// Save the current state to storage (SharedPreferences or Firebase)
  Future<void> _saveState() async {
    if (_state == null) return;

    try {
      // Always save to SharedPreferences for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(_state!.toJson());
      await prefs.setString('wizard_${_state!.template.id}', jsonData);

      // If Firebase is enabled, also save to Firestore
      if (_useFirebase && _userId != null && _eventId != null) {
        await _firestoreService.saveWizardState(_userId!, _eventId!, _state!);
        debugPrint('Saved wizard state to Firebase');
      }
    } catch (e) {
      _error = 'Failed to save wizard state: $e';
      notifyListeners();
    }
  }

  /// Load a saved state from storage (SharedPreferences or Firebase)
  Future<WizardState?> _loadSavedState(String templateId) async {
    try {
      // If Firebase is enabled, try to load from Firestore first
      if (_useFirebase && _userId != null && _eventId != null) {
        final firebaseState = await _firestoreService.getWizardState(
          _userId!,
          _eventId!,
        );

        if (firebaseState != null) {
          debugPrint('Loaded wizard state from Firebase');
          return firebaseState;
        }
      }

      // Fall back to SharedPreferences if Firebase is disabled or no data found
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('wizard_$templateId');

      if (jsonData == null) return null;

      final jsonMap = jsonDecode(jsonData) as Map<String, dynamic>;

      return WizardState.fromJson(jsonMap);
    } catch (e) {
      _error = 'Failed to load wizard state: $e';
      notifyListeners();

      return null;
    }
  }
}
