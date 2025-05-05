# Eventati Book Event Wizard System

This document provides a comprehensive overview of the Event Wizard system in the Eventati Book application, including its architecture, components, data flow, and integration with other features.

## Event Wizard Overview

The Event Wizard is a guided, step-by-step process that helps users create and configure different types of events (weddings, business events, celebrations). It collects essential information about the event, suggests appropriate services and planning tools, and sets up the initial event structure. The wizard adapts its flow and options based on the event type, providing a personalized experience.

## Event Wizard Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       EVENT TYPE SELECTION                              │
│                                                                         │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐          │
│  │  Wedding        │  │  Business Event │  │  Celebration    │          │
│  │                 │  │                 │  │                 │          │
│  │  [Image]        │  │  [Image]        │  │  [Image]        │          │
│  │                 │  │                 │  │                 │          │
│  │  Plan your      │  │  Organize your  │  │  Create your    │          │
│  │  perfect        │  │  corporate      │  │  special        │          │
│  │  wedding        │  │  event          │  │  celebration    │          │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘          │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User selects event type
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       EVENT WIZARD SCREEN                               │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       STEP 1: BASIC INFORMATION                         │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Event Name                                                      │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Event Date                                                      │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Event Location (City/Region)                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Estimated Guest Count                                           │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Event Description                                               │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User completes basic information
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       STEP 2: EVENT DETAILS                             │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Event Type-Specific Fields                                      │    │
│  │                                                                  │    │
│  │  Wedding:                                                        │    │
│  │  - Wedding Style (Traditional, Modern, Destination, etc.)        │    │
│  │  - Ceremony Type                                                 │    │
│  │  - Partner Names                                                 │    │
│  │                                                                  │    │
│  │  Business Event:                                                 │    │
│  │  - Event Format (Conference, Meeting, Team Building, etc.)       │    │
│  │  - Industry                                                      │    │
│  │  - Company Name                                                  │    │
│  │                                                                  │    │
│  │  Celebration:                                                    │    │
│  │  - Occasion (Birthday, Anniversary, Graduation, etc.)            │    │
│  │  - Celebrant Name                                                │    │
│  │  - Age/Year (if applicable)                                      │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User completes event details
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       STEP 3: BUDGET & PREFERENCES                      │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Budget Range                                                    │    │
│  │  - Slider or predefined ranges                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Priority Services                                               │    │
│  │  - Venue                                                         │    │
│  │  - Catering                                                      │    │
│  │  - Photography                                                   │    │
│  │  - Entertainment                                                 │    │
│  │  - Decoration                                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Style Preferences                                               │    │
│  │  - Color Themes                                                  │    │
│  │  - Atmosphere (Formal, Casual, Elegant, Fun, etc.)               │    │
│  │  - Indoor/Outdoor Preference                                     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User sets budget and preferences
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       STEP 4: PLANNING TOOLS SETUP                      │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Select Planning Tools                                           │    │
│  │  - Budget Calculator                                             │    │
│  │  - Guest List Management                                         │    │
│  │  - Timeline/Checklist                                            │    │
│  │  - Vendor Communication                                          │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Tool Configuration Options                                      │    │
│  │  - Pre-populate with templates based on event type               │    │
│  │  - Customize timeline milestones                                 │    │
│  │  - Set budget categories                                         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User selects planning tools
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       STEP 5: SUMMARY & CREATION                        │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Event Summary                                                   │    │
│  │  - Basic Information                                             │    │
│  │  - Event Details                                                 │    │
│  │  - Budget Range                                                  │    │
│  │  - Selected Preferences                                          │    │
│  │  - Planning Tools                                                │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Create Event Button                                             │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    │ User confirms and creates event
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       EVENT DASHBOARD                                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Event Overview                                                  │    │
│  │  - Event details                                                 │    │
│  │  - Days remaining                                                │    │
│  │  - Progress indicators                                           │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Planning Tools                                                  │    │
│  │  - Budget                                                        │    │
│  │  - Guest List                                                    │    │
│  │  - Timeline                                                      │    │
│  │  - Messaging                                                     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Recommended Services                                            │    │
│  │  - Based on preferences and event type                           │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

## Event Wizard Components

### Screens

1. **EventTypeSelectionScreen**
   - Purpose: Allow users to select the type of event they want to create
   - Key Features:
     - Visual cards for each event type (Wedding, Business Event, Celebration)
     - Brief descriptions of each event type
     - Navigation to the appropriate wizard screen

2. **WeddingWizardScreen**
   - Purpose: Guide users through creating a wedding event
   - Key Features:
     - Step-by-step form with progress indicator
     - Wedding-specific fields and options
     - Template suggestions based on wedding style
     - Budget allocation recommendations for wedding services

3. **BusinessEventWizardScreen**
   - Purpose: Guide users through creating a business event
   - Key Features:
     - Step-by-step form with progress indicator
     - Business event-specific fields and options
     - Template suggestions based on event format
     - Budget allocation recommendations for business services

4. **CelebrationWizardScreen**
   - Purpose: Guide users through creating a celebration event
   - Key Features:
     - Step-by-step form with progress indicator
     - Celebration-specific fields and options
     - Template suggestions based on occasion
     - Budget allocation recommendations for celebration services

### Widgets

1. **WizardStepIndicator**
   - Purpose: Display the current step and progress in the wizard
   - Key Features:
     - Visual representation of steps
     - Indication of current step
     - Step completion status

2. **EventTypeCard**
   - Purpose: Display an event type option in the selection screen
   - Key Features:
     - Visual representation of event type
     - Title and description
     - Selection state

3. **WizardNavigationButtons**
   - Purpose: Provide navigation controls for the wizard
   - Key Features:
     - Next and Previous buttons
     - Step validation
     - Completion button on final step

### Models

1. **Event**
   - Core data model for event information
   - Properties:
     - id: Unique identifier
     - userId: User who created the event
     - name: Event name
     - date: Event date
     - location: Event location
     - guestCount: Estimated number of guests
     - description: Event description
     - type: Event type (wedding, business, celebration)
     - budget: Budget range
     - preferences: User preferences
     - createdAt: Creation timestamp
     - updatedAt: Last update timestamp

2. **EventType**
   - Enum representing different event types
   - Values:
     - wedding: Wedding event
     - business: Business event
     - celebration: Celebration event

3. **EventPreferences**
   - Model for storing user preferences for an event
   - Properties:
     - priorityServices: List of priority services
     - stylePreferences: Style and theme preferences
     - colorTheme: Preferred color theme
     - atmosphere: Preferred atmosphere
     - venueType: Preferred venue type (indoor/outdoor)

### Providers

1. **EventProvider**
   - Purpose: Manage event data and operations
   - Key Responsibilities:
     - Create, read, update, and delete events
     - Filter events by type
     - Sort events by date
     - Manage event errors
     - Notify listeners of changes

2. **WizardProvider**
   - Purpose: Manage the state of the event wizard
   - Key Responsibilities:
     - Track current wizard step
     - Store form data across steps
     - Validate step data
     - Generate event from wizard data
     - Manage wizard errors
     - Notify listeners of changes

## Integration with Other Features

### Integration with Planning Tools

- The wizard sets up initial planning tools based on user selections
- Budget categories are pre-populated based on event type and preferences
- Timeline templates are selected based on event type and date
- Guest list categories are created based on event type

### Integration with Services

- Service recommendations are generated based on event type and preferences
- Priority services are highlighted in service listings
- Budget allocations guide service selection

### Integration with Booking System

- Events can be associated with bookings
- Event details are used to pre-fill booking information
- Bookings appear in event dashboard

## Data Models

### Event Model

```dart
class Event {
  final String id;
  final String userId;
  final String name;
  final DateTime date;
  final String location;
  final int guestCount;
  final String description;
  final EventType type;
  final double budgetMin;
  final double budgetMax;
  final EventPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor, copyWith, and other methods...
}
```

### EventType Enum

```dart
enum EventType {
  wedding,
  business,
  celebration;

  // Properties for display name, icon, and description
  String get displayName { ... }
  IconData get icon { ... }
  String get description { ... }
}
```

### EventPreferences Model

```dart
class EventPreferences {
  final List<String> priorityServices;
  final List<String> stylePreferences;
  final String colorTheme;
  final String atmosphere;
  final String venueType;

  // Constructor and other methods...
}
```

## Key Functionality

### Dynamic Form Adaptation

The wizard dynamically adapts its form fields and options based on the selected event type:

```dart
Widget _buildEventSpecificFields() {
  switch (widget.eventType) {
    case EventType.wedding:
      return _buildWeddingFields();
    case EventType.business:
      return _buildBusinessEventFields();
    case EventType.celebration:
      return _buildCelebrationFields();
    default:
      return Container();
  }
}
```

### Template Suggestion System

The wizard suggests appropriate templates for planning tools based on the event type and user preferences:

```dart
List<MilestoneTemplate> getSuggestedMilestoneTemplates() {
  switch (_eventType) {
    case EventType.wedding:
      return _weddingMilestoneTemplates;
    case EventType.business:
      return _businessEventMilestoneTemplates;
    case EventType.celebration:
      return _celebrationMilestoneTemplates;
    default:
      return [];
  }
}
```

### Budget Allocation Recommendations

The wizard provides recommended budget allocations based on the event type and total budget:

```dart
Map<String, double> getRecommendedBudgetAllocations(double totalBudget) {
  switch (_eventType) {
    case EventType.wedding:
      return {
        'Venue': totalBudget * 0.4,
        'Catering': totalBudget * 0.25,
        'Photography': totalBudget * 0.15,
        'Decoration': totalBudget * 0.1,
        'Entertainment': totalBudget * 0.05,
        'Miscellaneous': totalBudget * 0.05,
      };
    // Similar cases for other event types...
    default:
      return {};
  }
}
```

### Progress Tracking and Validation

The wizard tracks user progress through the steps and validates each step before allowing advancement:

```dart
bool validateCurrentStep() {
  switch (_currentStep) {
    case 0: // Basic Information
      return _validateBasicInformation();
    case 1: // Event Details
      return _validateEventDetails();
    case 2: // Budget & Preferences
      return _validateBudgetAndPreferences();
    case 3: // Planning Tools Setup
      return _validatePlanningToolsSetup();
    case 4: // Summary & Creation
      return true; // No validation needed for summary
    default:
      return false;
  }
}
```

### Event Creation and Setup

The wizard creates the event and sets up associated planning tools based on user selections:

```dart
Future<bool> createEvent() async {
  try {
    // Create the event
    final event = Event(
      id: const Uuid().v4(),
      userId: _authProvider.currentUser?.uid ?? '',
      name: _eventName,
      date: _eventDate,
      location: _eventLocation,
      guestCount: _guestCount,
      description: _eventDescription,
      type: _eventType,
      budgetMin: _budgetRange.start,
      budgetMax: _budgetRange.end,
      preferences: _eventPreferences,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save the event
    final success = await _eventProvider.createEvent(event);
    
    if (success) {
      // Set up planning tools
      await _setupPlanningTools(event.id);
      return true;
    }
    
    return false;
  } catch (e) {
    _error = e.toString();
    return false;
  }
}
```

## Wizard Step Details

### Step 1: Basic Information

Collects fundamental information about the event:
- Event name
- Event date
- Event location (city/region)
- Estimated guest count
- Event description

This information is used to create the basic event structure and is required for all event types.

### Step 2: Event Details

Collects information specific to the event type:

**Wedding:**
- Wedding style (Traditional, Modern, Destination, etc.)
- Ceremony type (Religious, Civil, Symbolic, etc.)
- Partner names

**Business Event:**
- Event format (Conference, Meeting, Team Building, etc.)
- Industry
- Company name

**Celebration:**
- Occasion (Birthday, Anniversary, Graduation, etc.)
- Celebrant name
- Age/Year (if applicable)

This information helps tailor the planning tools and service recommendations to the specific event type.

### Step 3: Budget & Preferences

Collects information about budget and style preferences:
- Budget range
- Priority services
- Style preferences
- Color themes
- Atmosphere preferences
- Indoor/Outdoor preference

This information is used to guide budget allocation, service recommendations, and style suggestions.

### Step 4: Planning Tools Setup

Allows users to select and configure planning tools:
- Budget calculator
- Guest list management
- Timeline/Checklist
- Vendor communication

Users can choose which tools to enable and configure initial settings for each tool.

### Step 5: Summary & Creation

Displays a summary of all the information collected and allows the user to create the event:
- Basic information
- Event details
- Budget range
- Selected preferences
- Planning tools

Users can review the information and make changes before finalizing the event creation.

## Future Enhancements

Planned enhancements for the Event Wizard system include:
- AI-powered recommendations based on user preferences
- More detailed budget allocation suggestions
- Integration with calendar systems for date selection
- Location-based venue suggestions
- Collaborative event creation with multiple users
- Event templates for quick setup
- More customization options for different event types
- Visual theme previews
- Integration with social media for event sharing
