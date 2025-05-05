# Event Wizard State Transition Diagram

This document illustrates the state transitions in the event creation wizard of the Eventati Book application.

## Event Wizard States Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       EVENT WIZARD STATES                               │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Event Type   │                              │
│                          │  Selection    │                              │
│                          │               │                              │
│                          └───────┬───────┘                              │
│                                  │                                      │
│                                  │                                      │
│                                  ▼                                      │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Basic Info   │                              │
│                          │               │                              │
│                          └───────┬───────┘                              │
│                                  │                                      │
│                                  │                                      │
│                                  ▼                                      │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Guest Info   │                              │
│                          │               │                              │
│                          └───────┬───────┘                              │
│                                  │                                      │
│                                  │                                      │
│                                  ▼                                      │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Services     │                              │
│                          │  Selection    │                              │
│                          │               │                              │
│                          └───────┬───────┘                              │
│                                  │                                      │
│                                  │                                      │
│                                  ▼                                      │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Budget       │                              │
│                          │  Estimation   │                              │
│                          │               │                              │
│                          └───────┬───────┘                              │
│                                  │                                      │
│                                  │                                      │
│                                  ▼                                      │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Preferences  │                              │
│                          │               │                              │
│                          └───────┬───────┘                              │
│                                  │                                      │
│                                  │                                      │
│                                  ▼                                      │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Review       │                              │
│                          │               │                              │
│                          └───────┬───────┘                              │
│                                  │                                      │
│                                  │                                      │
│                                  ▼                                      │
│                          ┌───────────────┐                              │
│                          │               │                              │
│                          │  Completion   │                              │
│                          │               │                              │
│                          └───────────────┘                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Detailed State Transition Diagram

```
                                 ┌───────────────────┐
                                 │                   │
                                 │  Dashboard        │
                                 │                   │
                                 └─────────┬─────────┘
                                           │
                                           │ Create New Event
                                           ▼
┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │
│  Wedding Wizard   │◀──────────│  Event Type       │────────▶┌───────────────────┐
│                   │ Wedding   │  Selection        │ Business│                   │
│                   │           │                   │ Event   │  Business Event   │
└─────────┬─────────┘           └─────────┬─────────┘         │  Wizard           │
          │                               │                   │                   │
          │                               │ Celebration       └─────────┬─────────┘
          │                               ▼                             │
          │                     ┌───────────────────┐                   │
          │                     │                   │                   │
          │                     │  Celebration      │                   │
          │                     │  Wizard           │                   │
          │                     │                   │                   │
          │                     └─────────┬─────────┘                   │
          │                               │                             │
          │                               │                             │
          ▼                               ▼                             ▼
┌───────────────────┐           ┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │           │                   │
│  Basic Info       │           │  Basic Info       │           │  Basic Info       │
│  (Wedding)        │           │  (Celebration)    │           │  (Business)       │
│                   │           │                   │           │                   │
└─────────┬─────────┘           └─────────┬─────────┘           └─────────┬─────────┘
          │                               │                               │
          │ Next                          │ Next                          │ Next
          ▼                               ▼                               ▼
┌───────────────────┐           ┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │           │                   │
│  Guest Info       │           │  Guest Info       │           │  Guest Info       │
│  (Wedding)        │           │  (Celebration)    │           │  (Business)       │
│                   │           │                   │           │                   │
└─────────┬─────────┘           └─────────┬─────────┘           └─────────┬─────────┘
          │                               │                               │
          │ Next                          │ Next                          │ Next
          ▼                               ▼                               ▼
┌───────────────────┐           ┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │           │                   │
│  Services         │           │  Services         │           │  Services         │
│  (Wedding)        │           │  (Celebration)    │           │  (Business)       │
│                   │           │                   │           │                   │
└─────────┬─────────┘           └─────────┬─────────┘           └─────────┬─────────┘
          │                               │                               │
          │ Next                          │ Next                          │ Next
          ▼                               ▼                               ▼
┌───────────────────┐           ┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │           │                   │
│  Budget           │           │  Budget           │           │  Budget           │
│  (Wedding)        │           │  (Celebration)    │           │  (Business)       │
│                   │           │                   │           │                   │
└─────────┬─────────┘           └─────────┬─────────┘           └─────────┬─────────┘
          │                               │                               │
          │ Next                          │ Next                          │ Next
          ▼                               ▼                               ▼
┌───────────────────┐           ┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │           │                   │
│  Preferences      │           │  Preferences      │           │  Preferences      │
│  (Wedding)        │           │  (Celebration)    │           │  (Business)       │
│                   │           │                   │           │                   │
└─────────┬─────────┘           └─────────┬─────────┘           └─────────┬─────────┘
          │                               │                               │
          │ Next                          │ Next                          │ Next
          ▼                               ▼                               ▼
┌───────────────────┐           ┌───────────────────┐           ┌───────────────────┐
│                   │           │                   │           │                   │
│  Review           │           │  Review           │           │  Review           │
│  (Wedding)        │           │  (Celebration)    │           │  (Business)       │
│                   │           │                   │           │                   │
└─────────┬─────────┘           └─────────┬─────────┘           └─────────┬─────────┘
          │                               │                               │
          │ Create                        │ Create                        │ Create
          ▼                               ▼                               ▼
                          ┌───────────────────┐
                          │                   │
                          │  Event Created    │
                          │                   │
                          └─────────┬─────────┘
                                    │
                                    │
                                    ▼
                          ┌───────────────────┐
                          │                   │
                          │  Suggestions      │
                          │  Screen           │
                          │                   │
                          └─────────┬─────────┘
                                    │
                                    │
                                    ▼
                          ┌───────────────────┐
                          │                   │
                          │  Event Dashboard  │
                          │                   │
                          └───────────────────┘
```

## State Descriptions

### Event Type Selection
- **Description**: User selects the type of event they want to create
- **UI State**: Shows options for Wedding, Celebration, or Business Event
- **Data Collected**: Event type
- **Transitions**:
  - To **Wedding Wizard** when user selects Wedding
  - To **Celebration Wizard** when user selects Celebration
  - To **Business Event Wizard** when user selects Business Event
  - To **Dashboard** when user cancels

### Basic Info
- **Description**: User enters basic information about the event
- **UI State**: Shows form with fields specific to the event type
- **Data Collected**:
  - Event name
  - Event date and time
  - Event location (optional)
  - Event description (optional)
- **Transitions**:
  - To **Guest Info** when user taps "Next"
  - To **Event Type Selection** when user taps "Back"
  - To **Dashboard** when user cancels

### Guest Info
- **Description**: User enters information about guests
- **UI State**: Shows form for guest count and categories
- **Data Collected**:
  - Estimated guest count
  - Guest categories (adults, children, etc.)
  - Special accommodations (optional)
- **Transitions**:
  - To **Services Selection** when user taps "Next"
  - To **Basic Info** when user taps "Back"
  - To **Dashboard** when user cancels

### Services Selection
- **Description**: User selects services needed for the event
- **UI State**: Shows checklist of available services
- **Data Collected**:
  - Selected services (venue, catering, photography, etc.)
  - Service priorities
- **Transitions**:
  - To **Budget Estimation** when user taps "Next"
  - To **Guest Info** when user taps "Back"
  - To **Dashboard** when user cancels

### Budget Estimation
- **Description**: User sets budget parameters
- **UI State**: Shows budget allocation form
- **Data Collected**:
  - Total budget
  - Budget allocation by category
  - Budget flexibility
- **Transitions**:
  - To **Preferences** when user taps "Next"
  - To **Services Selection** when user taps "Back"
  - To **Dashboard** when user cancels

### Preferences
- **Description**: User specifies preferences for the event
- **UI State**: Shows preference options specific to event type
- **Data Collected**:
  - Style preferences
  - Color themes
  - Atmosphere/mood
  - Special requirements
- **Transitions**:
  - To **Review** when user taps "Next"
  - To **Budget Estimation** when user taps "Back"
  - To **Dashboard** when user cancels

### Review
- **Description**: User reviews all entered information
- **UI State**: Shows summary of all wizard steps
- **Data Collected**: None (review only)
- **Transitions**:
  - To **Event Created** when user taps "Create Event"
  - To any previous step when user taps edit button for that section
  - To **Preferences** when user taps "Back"
  - To **Dashboard** when user cancels

### Event Created
- **Description**: Event has been successfully created
- **UI State**: Shows success message
- **Data Collected**: None
- **Transitions**:
  - To **Suggestions Screen** automatically
  - To **Dashboard** when user taps "Skip Suggestions"

### Suggestions Screen
- **Description**: System provides suggestions based on event details
- **UI State**: Shows recommended services and next steps
- **Data Collected**: User selections of suggestions to save
- **Transitions**:
  - To **Event Dashboard** when user taps "Continue to Dashboard"
  - To **Event Dashboard** when user taps "Skip"

### Event Dashboard
- **Description**: Main management screen for the created event
- **UI State**: Shows event overview and planning tools
- **Data Collected**: None
- **Transitions**:
  - To various planning tools (Budget, Guest List, Timeline, etc.)

## State Variables in EventWizardProvider

```dart
class EventWizardProvider extends ChangeNotifier {
  // State variables
  EventWizardState _wizardState = EventWizardState.eventTypeSelection;
  EventType? _eventType;
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Event data
  Map<String, dynamic> _eventData = {};
  
  // Getters
  EventWizardState get wizardState => _wizardState;
  EventType? get eventType => _eventType;
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get eventData => _eventData;
  
  // State transition methods
  void selectEventType(EventType type) {
    _eventType = type;
    _wizardState = EventWizardState.basicInfo;
    _currentStep = 1;
    notifyListeners();
  }
  
  void goToNextStep() {
    if (_currentStep < getMaxSteps() - 1) {
      _currentStep++;
      _updateWizardState();
      notifyListeners();
    }
  }
  
  void goToPreviousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _updateWizardState();
      notifyListeners();
    }
  }
  
  void updateEventData(String key, dynamic value) {
    _eventData[key] = value;
    notifyListeners();
  }
  
  Future<void> createEvent() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Create event logic
      // Save to database
      
      _wizardState = EventWizardState.eventCreated;
      notifyListeners();
      
      // After a delay, move to suggestions
      await Future.delayed(Duration(seconds: 2));
      _wizardState = EventWizardState.suggestions;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void goToEventDashboard() {
    _wizardState = EventWizardState.eventDashboard;
    notifyListeners();
  }
  
  // Helper methods
  int getMaxSteps() {
    return 7; // Total number of steps in the wizard
  }
  
  void _updateWizardState() {
    switch (_currentStep) {
      case 0:
        _wizardState = EventWizardState.eventTypeSelection;
        break;
      case 1:
        _wizardState = EventWizardState.basicInfo;
        break;
      case 2:
        _wizardState = EventWizardState.guestInfo;
        break;
      case 3:
        _wizardState = EventWizardState.servicesSelection;
        break;
      case 4:
        _wizardState = EventWizardState.budgetEstimation;
        break;
      case 5:
        _wizardState = EventWizardState.preferences;
        break;
      case 6:
        _wizardState = EventWizardState.review;
        break;
    }
  }
}

enum EventWizardState {
  eventTypeSelection,
  basicInfo,
  guestInfo,
  servicesSelection,
  budgetEstimation,
  preferences,
  review,
  eventCreated,
  suggestions,
  eventDashboard
}

enum EventType {
  wedding,
  celebration,
  businessEvent
}
```

## UI Response to State Changes

### Event Type Selection
```dart
if (wizardProvider.wizardState == EventWizardState.eventTypeSelection) {
  return EventTypeSelectionScreen();
}
```

### Basic Info
```dart
if (wizardProvider.wizardState == EventWizardState.basicInfo) {
  switch (wizardProvider.eventType) {
    case EventType.wedding:
      return WeddingBasicInfoScreen();
    case EventType.celebration:
      return CelebrationBasicInfoScreen();
    case EventType.businessEvent:
      return BusinessEventBasicInfoScreen();
    default:
      return Container(); // Should never happen
  }
}
```

### Guest Info
```dart
if (wizardProvider.wizardState == EventWizardState.guestInfo) {
  switch (wizardProvider.eventType) {
    case EventType.wedding:
      return WeddingGuestInfoScreen();
    case EventType.celebration:
      return CelebrationGuestInfoScreen();
    case EventType.businessEvent:
      return BusinessEventGuestInfoScreen();
    default:
      return Container(); // Should never happen
  }
}
```

### Services Selection
```dart
if (wizardProvider.wizardState == EventWizardState.servicesSelection) {
  return ServicesSelectionScreen(eventType: wizardProvider.eventType);
}
```

### Budget Estimation
```dart
if (wizardProvider.wizardState == EventWizardState.budgetEstimation) {
  return BudgetEstimationScreen(eventType: wizardProvider.eventType);
}
```

### Preferences
```dart
if (wizardProvider.wizardState == EventWizardState.preferences) {
  switch (wizardProvider.eventType) {
    case EventType.wedding:
      return WeddingPreferencesScreen();
    case EventType.celebration:
      return CelebrationPreferencesScreen();
    case EventType.businessEvent:
      return BusinessEventPreferencesScreen();
    default:
      return Container(); // Should never happen
  }
}
```

### Review
```dart
if (wizardProvider.wizardState == EventWizardState.review) {
  return ReviewScreen(eventData: wizardProvider.eventData);
}
```

### Event Created
```dart
if (wizardProvider.wizardState == EventWizardState.eventCreated) {
  return EventCreatedScreen();
}
```

### Suggestions
```dart
if (wizardProvider.wizardState == EventWizardState.suggestions) {
  return SuggestionsScreen(eventData: wizardProvider.eventData);
}
```

### Event Dashboard
```dart
if (wizardProvider.wizardState == EventWizardState.eventDashboard) {
  return EventDashboardScreen(eventId: createdEventId);
}
```

## Event Type-Specific Variations

Each event type (Wedding, Celebration, Business Event) has specific variations in the wizard flow:

### Wedding Wizard
- **Basic Info**: Includes wedding couple names, wedding style
- **Guest Info**: Includes wedding party size, family groups
- **Services**: Emphasizes venue, catering, photography, flowers, attire
- **Preferences**: Includes wedding theme, colors, traditions

### Celebration Wizard
- **Basic Info**: Includes celebration type (birthday, anniversary, etc.)
- **Guest Info**: Includes age groups, special guests
- **Services**: Emphasizes venue, entertainment, catering, decorations
- **Preferences**: Includes theme, activities, special moments

### Business Event Wizard
- **Basic Info**: Includes event purpose, company information
- **Guest Info**: Includes attendee types, registration needs
- **Services**: Emphasizes venue, AV equipment, catering, accommodations
- **Preferences**: Includes branding requirements, presentation needs

## Firebase Integration

When Firebase is implemented, the event creation will store data in Firestore:

```dart
Future<void> createEvent() async {
  _isLoading = true;
  notifyListeners();
  
  try {
    // Get current user ID
    String userId = FirebaseAuth.instance.currentUser!.uid;
    
    // Create event document in Firestore
    DocumentReference eventRef = await FirebaseFirestore.instance
        .collection('events')
        .add({
          'userId': userId,
          'eventType': _eventType.toString(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          ..._eventData, // Spread all event data
        });
    
    // Store event ID
    String eventId = eventRef.id;
    
    // Create initial planning tools data
    await _createInitialPlanningData(eventId);
    
    _wizardState = EventWizardState.eventCreated;
    notifyListeners();
    
    // After a delay, move to suggestions
    await Future.delayed(Duration(seconds: 2));
    _wizardState = EventWizardState.suggestions;
    notifyListeners();
  } catch (e) {
    _errorMessage = e.toString();
    notifyListeners();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<void> _createInitialPlanningData(String eventId) async {
  // Create budget document
  await FirebaseFirestore.instance
      .collection('budgets')
      .add({
        'eventId': eventId,
        'totalBudget': _eventData['estimatedBudget'] ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
  
  // Create guest list document
  await FirebaseFirestore.instance
      .collection('guestLists')
      .add({
        'eventId': eventId,
        'estimatedCount': _eventData['estimatedGuestCount'] ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
  
  // Create timeline with default milestones
  await FirebaseFirestore.instance
      .collection('timelines')
      .add({
        'eventId': eventId,
        'createdAt': FieldValue.serverTimestamp(),
      });
  
  // Add default milestones based on event type
  await _addDefaultMilestones(eventId);
}
```
