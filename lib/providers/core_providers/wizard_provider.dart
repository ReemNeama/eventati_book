import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/wizard_connection_service.dart';
import 'package:eventati_book/services/supabase/database/wizard_state_database_service.dart';

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

  /// Whether to use Supabase for persistence
  bool _useSupabase = false;

  /// Map to track completion status of individual fields
  final Map<String, bool> _fieldCompletionStatus = {};

  /// Database service for wizard state
  final WizardStateDatabaseService _databaseService =
      WizardStateDatabaseService();

  /// Get the current wizard state
  WizardState? get state => _state;

  /// Check if the provider is loading
  bool get isLoading => _isLoading;

  /// Get the error message if any
  String? get error => _error;

  /// Get whether Supabase is being used for persistence
  bool get useSupabase => _useSupabase;

  /// Set whether to use Supabase for persistence
  set useSupabase(bool value) {
    _useSupabase = value;
    notifyListeners();
  }

  /// Get the field completion status map
  Map<String, bool> get fieldCompletionStatus =>
      Map.unmodifiable(_fieldCompletionStatus);

  /// Check if a specific field is completed
  bool isFieldCompleted(String fieldId) {
    return _fieldCompletionStatus[fieldId] ?? false;
  }

  /// Update the completion status of a field
  void updateFieldCompletionStatus(String fieldId, bool isCompleted) {
    _fieldCompletionStatus[fieldId] = isCompleted;
    notifyListeners();
  }

  /// Get the completion percentage for a specific step
  double getStepCompletionPercentage(int step) {
    if (_state == null) return 0.0;

    // Get all fields for this step
    final fieldsForStep = _getFieldsForStep(step);
    if (fieldsForStep.isEmpty) return 0.0;

    // Count completed fields
    int completedFields = 0;
    for (final field in fieldsForStep) {
      if (isFieldCompleted(field)) {
        completedFields++;
      }
    }

    return (completedFields / fieldsForStep.length) * 100;
  }

  /// Get all fields for a specific step
  List<String> _getFieldsForStep(int step) {
    switch (step) {
      case 0: // Event Details
        return ['eventName', 'eventType'];
      case 1: // Template
        return ['template'];
      case 2: // Date & Guests
        return ['eventDate', 'guestCount'];
      case 3: // Services
        return _state?.selectedServices.keys
                .map((service) => 'service_$service')
                .toList() ??
            [];
      case 4: // Review
        return ['review'];
      default:
        return [];
    }
  }

  /// Initialize with user and event IDs for Supabase persistence
  void initializeWithIds(String userId, String eventId) {
    _userId = userId;
    _eventId = eventId;
    _useSupabase = true;
    notifyListeners();
  }

  /// Explicitly save the current state to Supabase
  Future<void> saveStateToSupabase() async {
    if (_state == null ||
        !_useSupabase ||
        _userId == null ||
        _eventId == null) {
      return;
    }

    try {
      await _databaseService.saveWizardState(_state!);
      debugPrint('Explicitly saved wizard state to Supabase');
    } catch (e) {
      _error = 'Failed to save wizard state to Supabase: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Initialize the wizard with a template
  Future<void> initializeWizard(EventTemplate template) async {
    _isLoading = true;
    _error = null;
    // Clear field completion status
    _fieldCompletionStatus.clear();
    notifyListeners();

    try {
      // Check if there's a saved state for this template
      final savedState = await _loadSavedState(template.id);

      if (savedState != null) {
        _state = savedState;
        // Initialize field completion status based on the loaded state
        _initializeFieldCompletionStatus();
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

  /// Initialize field completion status based on the current state
  void _initializeFieldCompletionStatus() {
    if (_state == null) return;

    // Event Details
    updateFieldCompletionStatus('eventName', _state!.eventName.isNotEmpty);
    updateFieldCompletionStatus(
      'eventType',
      _state!.selectedEventType != null &&
          _state!.selectedEventType!.isNotEmpty,
    );

    // Template
    updateFieldCompletionStatus(
      'template',
      _state!.selectedTemplateId != null &&
          _state!.selectedTemplateId!.isNotEmpty,
    );

    // Date & Guests
    updateFieldCompletionStatus('eventDate', _state!.eventDate != null);
    updateFieldCompletionStatus(
      'guestCount',
      _state!.guestCount != null && _state!.guestCount! > 0,
    );

    // Services
    for (final entry in _state!.selectedServices.entries) {
      updateFieldCompletionStatus('service_${entry.key}', entry.value);
    }

    // Review is always considered complete if we reach it
    if (_state!.currentStep >= 4) {
      updateFieldCompletionStatus('review', true);
    }
  }

  /// Update the event name
  void updateEventName(String name) {
    if (_state == null) return;

    _state = _state!.copyWith(eventName: name);
    // Update field completion status
    updateFieldCompletionStatus('eventName', name.isNotEmpty);
    _saveState();
    notifyListeners();
  }

  /// Update the selected event type
  void updateEventType(String type) {
    if (_state == null) return;

    _state = _state!.copyWith(selectedEventType: type);
    // Update field completion status
    updateFieldCompletionStatus('eventType', type.isNotEmpty);
    _saveState();
    notifyListeners();
  }

  /// Update the selected template
  void updateSelectedTemplate(String templateId) {
    if (_state == null) return;

    _state = _state!.copyWith(selectedTemplateId: templateId);
    // Update field completion status
    updateFieldCompletionStatus('template', templateId.isNotEmpty);
    _saveState();
    notifyListeners();
  }

  /// Apply a detailed template to the wizard state
  void applyDetailedTemplate(EventTemplate detailedTemplate) {
    if (_state == null) return;

    // Update the selected template ID
    _state = _state!.copyWith(selectedTemplateId: detailedTemplate.id);

    // Apply default values from the template if available
    if (detailedTemplate.defaultValues != null) {
      final defaultValues = detailedTemplate.defaultValues!;

      // Apply event type if available
      if (defaultValues.containsKey('eventType') &&
          _state!.template.subtypes.contains(defaultValues['eventType'])) {
        _state = _state!.copyWith(
          selectedEventType: defaultValues['eventType'] as String,
        );
      }

      // Apply guest count if available
      if (defaultValues.containsKey('guestCount')) {
        _state = _state!.copyWith(
          guestCount: defaultValues['guestCount'] as int,
        );
      }

      // Apply services if available
      if (defaultValues.containsKey('services') &&
          defaultValues['services'] is Map<String, bool>) {
        final services = Map<String, bool>.from(
          defaultValues['services'] as Map,
        );
        _state = _state!.copyWith(selectedServices: services);
      }

      // Apply business event specific values if applicable
      if (_state!.template.id == 'business') {
        if (defaultValues.containsKey('eventDuration')) {
          _state = _state!.copyWith(
            eventDuration: defaultValues['eventDuration'] as int,
          );
        }

        if (defaultValues.containsKey('needsSetup')) {
          _state = _state!.copyWith(
            needsSetup: defaultValues['needsSetup'] as bool,
          );
        }

        if (defaultValues.containsKey('setupHours')) {
          _state = _state!.copyWith(
            setupHours: defaultValues['setupHours'] as int,
          );
        }

        if (defaultValues.containsKey('needsTeardown')) {
          _state = _state!.copyWith(
            needsTeardown: defaultValues['needsTeardown'] as bool,
          );
        }

        if (defaultValues.containsKey('teardownHours')) {
          _state = _state!.copyWith(
            teardownHours: defaultValues['teardownHours'] as int,
          );
        }
      }
    }

    _saveState();
    notifyListeners();
  }

  /// Update the event date
  void updateEventDate(DateTime date) {
    if (_state == null) return;

    _state = _state!.copyWith(eventDate: date);
    // Update field completion status
    updateFieldCompletionStatus('eventDate', true);
    _saveState();
    notifyListeners();
  }

  /// Update the guest count
  void updateGuestCount(int count) {
    if (_state == null) return;

    _state = _state!.copyWith(guestCount: count);
    // Update field completion status
    updateFieldCompletionStatus('guestCount', count > 0);
    _saveState();
    notifyListeners();
  }

  /// Update a service selection
  void updateServiceSelection(String service, bool selected) {
    if (_state == null) return;

    final updatedServices = Map<String, bool>.from(_state!.selectedServices);
    updatedServices[service] = selected;

    _state = _state!.copyWith(selectedServices: updatedServices);
    // Update field completion status for this service
    updateFieldCompletionStatus('service_$service', selected);
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

  /// Save the current wizard state and exit
  void saveAndExit(BuildContext context) {
    if (_state == null) return;

    // Ensure the state is marked as not completed
    if (_state!.isCompleted) {
      _state = _state!.copyWith(isCompleted: false);
    }

    // Save the current state
    _saveState();

    // Navigate back
    Navigator.of(context).pop();

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

      // If Supabase is enabled, also clear from database
      if (_useSupabase && _userId != null && _eventId != null) {
        // Create a unique ID for the wizard state based on user and event
        final stateId = '${_userId!}_${_eventId!}_${_state!.template.id}';
        await _databaseService.deleteWizardState(stateId);
        debugPrint('Deleted wizard state from Supabase');
      }

      _state = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear wizard state: $e';
      notifyListeners();
    }
  }

  /// Save the current state to storage (SharedPreferences or Supabase)
  Future<void> _saveState() async {
    if (_state == null) return;

    try {
      // Always save to SharedPreferences for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(_state!.toJson());
      await prefs.setString('wizard_${_state!.template.id}', jsonData);

      // If Supabase is enabled, also save to database
      if (_useSupabase && _userId != null && _eventId != null) {
        await _databaseService.saveWizardState(_state!);
        debugPrint('Saved wizard state to Supabase');
      }
    } catch (e) {
      _error = 'Failed to save wizard state: $e';
      notifyListeners();
    }
  }

  /// Load a saved state from storage (SharedPreferences or Supabase)
  Future<WizardState?> _loadSavedState(String templateId) async {
    try {
      // If Supabase is enabled, try to load from database first
      if (_useSupabase && _userId != null && _eventId != null) {
        // Create a unique ID for the wizard state based on user and event
        final stateId = '${_userId!}_${_eventId!}_$templateId';
        final supabaseState = await _databaseService.getWizardState(stateId);

        if (supabaseState != null) {
          debugPrint('Loaded wizard state from Supabase');
          return supabaseState;
        }
      }

      // Fall back to SharedPreferences if Supabase is disabled or no data found
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

  /// Get all in-progress wizard states for the current user
  Future<List<WizardState>> getInProgressWizards() async {
    final List<WizardState> result = [];

    try {
      // If Supabase is enabled and we have a user ID, get states from Supabase
      if (_useSupabase && _userId != null) {
        final states = await _databaseService.getWizardStatesForUser(_userId!);

        // Filter to only include in-progress states (not completed)
        for (final state in states) {
          if (!state.isCompleted) {
            result.add(state);
          }
        }

        debugPrint(
          'Loaded ${result.length} in-progress wizard states from Supabase',
        );
      }

      // Also check SharedPreferences for backward compatibility
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      // Filter keys that start with 'wizard_'
      final wizardKeys =
          allKeys.where((key) => key.startsWith('wizard_')).toList();

      for (final key in wizardKeys) {
        final jsonData = prefs.getString(key);
        if (jsonData != null) {
          try {
            final jsonMap = jsonDecode(jsonData) as Map<String, dynamic>;
            final state = WizardState.fromJson(jsonMap);

            if (state != null && !state.isCompleted) {
              // Check if this state is already in the result list (from Supabase)
              final isDuplicate = result.any((s) => s.id == state.id);

              if (!isDuplicate) {
                result.add(state);
              }
            }
          } catch (e) {
            debugPrint('Error parsing wizard state from SharedPreferences: $e');
          }
        }
      }

      return result;
    } catch (e) {
      _error = 'Failed to get in-progress wizards: $e';
      notifyListeners();
      return [];
    }
  }
}
