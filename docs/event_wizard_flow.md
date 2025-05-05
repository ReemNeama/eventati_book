# Eventati Book Event Wizard Flow

This document provides a visual representation of the event wizard flow in the Eventati Book application.

## Event Wizard Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           EVENT WIZARD FLOW                             │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           EVENT SELECTION                               │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  Wedding    │  │  Business   │  │ Celebration │  │  Custom     │    │
│  │  Event      │  │  Event      │  │  Event      │  │  Event      │    │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘    │
│         │                │                │                │           │
│         └────────────────┼────────────────┼────────────────┘           │
│                          │                │                            │
└──────────────────────────┼────────────────┼────────────────────────────┘
                           │                │
           ┌───────────────┘                └───────────────┐
           │                                                │
           ▼                                                ▼
┌─────────────────────────────┐              ┌─────────────────────────────┐
│      EVENT WIZARD SCREEN    │              │      EVENT WIZARD SCREEN    │
│      (e.g., Wedding)        │              │   (e.g., Business Event)    │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  Progress Indicator │    │              │  │  Progress Indicator │    │
│  │  [Step 1 of 5]      │    │              │  │  [Step 1 of 5]      │    │
│  └─────────────────────┘    │              │  └─────────────────────┘    │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  Event Name Input   │    │              │  │  Event Name Input   │    │
│  └─────────────────────┘    │              │  └─────────────────────┘    │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  Date Picker        │    │              │  │  Date Picker        │    │
│  └─────────────────────┘    │              │  └─────────────────────┘    │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  Time Picker        │    │              │  │  Time Picker        │    │
│  └─────────────────────┘    │              │  └─────────────────────┘    │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  Guest Count Input  │    │              │  │  Guest Count Input  │    │
│  └─────────────────────┘    │              │  └─────────────────────┘    │
│                             │              │                             │
│  ┌─────────────────────┐    │              │  ┌─────────────────────┐    │
│  │  Next Button        │────┼──┐           │  │  Next Button        │────┼──┐
│  └─────────────────────┘    │  │           │  └─────────────────────┘    │  │
└─────────────────────────────┘  │           └─────────────────────────────┘  │
                                 │                                             │
                                 ▼                                             ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           SERVICES SELECTION                                │
│                                                                             │
│  ┌─────────────────────┐                                                    │
│  │  Progress Indicator │                                                    │
│  │  [Step 2 of 5]      │                                                    │
│  └─────────────────────┘                                                    │
│                                                                             │
│  ┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────┐ │
│  │  Venue              │    │  Catering           │    │  Photography    │ │
│  │  [Checkbox]         │    │  [Checkbox]         │    │  [Checkbox]     │ │
│  └─────────────────────┘    └─────────────────────┘    └─────────────────┘ │
│                                                                             │
│  ┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────┐ │
│  │  Event Planner      │    │  Entertainment      │    │  Decorations    │ │
│  │  [Checkbox]         │    │  [Checkbox]         │    │  [Checkbox]     │ │
│  └─────────────────────┘    └─────────────────────┘    └─────────────────┘ │
│                                                                             │
│  ┌─────────────────────┐    ┌─────────────────────┐                        │
│  │  Back Button        │    │  Next Button        │────────────────────────┼──┐
│  └─────────────────────┘    └─────────────────────┘                        │  │
└─────────────────────────────────────────────────────────────────────────────┘  │
                                                                                 │
                                                                                 ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           BUDGET ESTIMATION                                     │
│                                                                                 │
│  ┌─────────────────────┐                                                        │
│  │  Progress Indicator │                                                        │
│  │  [Step 3 of 5]      │                                                        │
│  └─────────────────────┘                                                        │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  Estimated Total Budget: $25,000                                        │    │
│  │                                                                         │    │
│  │  Venue: $10,000                                                         │    │
│  │  Catering: $8,000                                                       │    │
│  │  Photography: $3,000                                                    │    │
│  │  Event Planner: $2,000                                                  │    │
│  │  Entertainment: $1,000                                                  │    │
│  │  Decorations: $1,000                                                    │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
│  ┌─────────────────────┐    ┌─────────────────────┐                            │
│  │  Back Button        │    │  Next Button        │────────────────────────────┼──┐
│  └─────────────────────┘    └─────────────────────┘                            │  │
└─────────────────────────────────────────────────────────────────────────────────┘  │
                                                                                     │
                                                                                     ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           PREFERENCES                                               │
│                                                                                     │
│  ┌─────────────────────┐                                                            │
│  │  Progress Indicator │                                                            │
│  │  [Step 4 of 5]      │                                                            │
│  └─────────────────────┘                                                            │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐        │
│  │  Event Style/Theme                                                      │        │
│  │  [Dropdown or Multiple Choice]                                          │        │
│  └─────────────────────────────────────────────────────────────────────────┘        │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐        │
│  │  Color Scheme                                                           │        │
│  │  [Color Picker or Predefined Options]                                   │        │
│  └─────────────────────────────────────────────────────────────────────────┘        │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐        │
│  │  Venue Type                                                             │        │
│  │  [Multiple Choice: Indoor, Outdoor, Both]                               │        │
│  └─────────────────────────────────────────────────────────────────────────┘        │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐        │
│  │  Additional Preferences                                                 │        │
│  │  [Text Area]                                                            │        │
│  └─────────────────────────────────────────────────────────────────────────┘        │
│                                                                                     │
│  ┌─────────────────────┐    ┌─────────────────────┐                                │
│  │  Back Button        │    │  Next Button        │────────────────────────────────┼──┐
│  └─────────────────────┘    └─────────────────────┘                                │  │
└─────────────────────────────────────────────────────────────────────────────────────┘  │
                                                                                         │
                                                                                         ▼
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                           SUMMARY & SUGGESTIONS                                         │
│                                                                                         │
│  ┌─────────────────────┐                                                                │
│  │  Progress Indicator │                                                                │
│  │  [Step 5 of 5]      │                                                                │
│  └─────────────────────┘                                                                │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐            │
│  │  Event Summary                                                          │            │
│  │  - Event Type: Wedding                                                  │            │
│  │  - Event Name: John & Jane's Wedding                                    │            │
│  │  - Date & Time: May 15, 2023 at 2:00 PM                                 │            │
│  │  - Guest Count: 150                                                     │            │
│  │  - Selected Services: Venue, Catering, Photography, Event Planner        │            │
│  │  - Estimated Budget: $25,000                                            │            │
│  └─────────────────────────────────────────────────────────────────────────┘            │
│                                                                                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐            │
│  │  Suggested Services                                                     │            │
│  │                                                                         │            │
│  │  [List of recommended services based on preferences]                    │            │
│  │                                                                         │            │
│  │  [View All Suggestions Button]                                          │            │
│  └─────────────────────────────────────────────────────────────────────────┘            │
│                                                                                         │
│  ┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐         │
│  │  Back Button        │    │  Save as Draft      │    │  Complete Setup     │─────────┼──┐
│  └─────────────────────┘    └─────────────────────┘    └─────────────────────┘         │  │
└─────────────────────────────────────────────────────────────────────────────────────────┘  │
                                                                                             │
                                                                                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                           WIZARD COMPLETION                                                 │
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐                │
│  │  Success Message                                                        │                │
│  │  "Your event has been set up successfully!"                             │                │
│  └─────────────────────────────────────────────────────────────────────────┘                │
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────┐                │
│  │  Next Steps                                                             │                │
│  │  - View and book suggested services                                     │                │
│  │  - Set up your planning tools                                           │                │
│  │  - Track your progress with milestones                                  │                │
│  └─────────────────────────────────────────────────────────────────────────┘                │
│                                                                                             │
│  ┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐             │
│  │  View Suggestions   │    │  Planning Tools     │    │  Dashboard          │             │
│  └─────────────────────┘    └─────────────────────┘    └─────────────────────┘             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

## Suggestion Screen Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                       SUGGESTION SCREEN                                 │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           HEADER                                        │
│                                                                         │
│  ┌─────────────┐  ┌─────────────────────────────────┐  ┌─────────────┐  │
│  │  Back       │  │  Suggested Services             │  │  Create     │  │
│  │  Button     │  │                                 │  │  Suggestion │  │
│  └─────────────┘  └─────────────────────────────────┘  └─────────────┘  │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           FILTER TABS                                   │
│                                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  All        │  │  Venues     │  │  Catering   │  │  Photography│    │
│  │  (Selected) │  │             │  │             │  │             │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           SUGGESTION CARDS                              │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  SUGGESTION CARD                                                │    │
│  │                                                                 │    │
│  │  ┌─────────────┐  ┌─────────────────────────────────────────┐  │    │
│  │  │  Service    │  │  Service Name                           │  │    │
│  │  │  Image      │  │                                         │  │    │
│  │  │  Placeholder│  │  Service Type: Venue                    │  │    │
│  │  │             │  │                                         │  │    │
│  │  │             │  │  Match: 95% based on your preferences   │  │    │
│  │  │             │  │                                         │  │    │
│  │  │             │  │  Price Range: $$$                       │  │    │
│  │  └─────────────┘  └─────────────────────────────────────────┘  │    │
│  │                                                                 │    │
│  │  ┌─────────────────────┐  ┌─────────────────────────────────┐  │    │
│  │  │  View Details       │  │  Add to Comparison              │  │    │
│  │  └─────────────────────┘  └─────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  SUGGESTION CARD                                                │    │
│  │                                                                 │    │
│  │  ┌─────────────┐  ┌─────────────────────────────────────────┐  │    │
│  │  │  Service    │  │  Service Name                           │  │    │
│  │  │  Image      │  │                                         │  │    │
│  │  │  Placeholder│  │  Service Type: Catering                 │  │    │
│  │  │             │  │                                         │  │    │
│  │  │             │  │  Match: 88% based on your preferences   │  │    │
│  │  │             │  │                                         │  │    │
│  │  │             │  │  Price Range: $$                        │  │    │
│  │  └─────────────┘  └─────────────────────────────────────────┘  │    │
│  │                                                                 │    │
│  │  ┌─────────────────────┐  ┌─────────────────────────────────┐  │    │
│  │  │  View Details       │  │  Add to Comparison              │  │    │
│  │  └─────────────────────┘  └─────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

## Create Suggestion Screen Components

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CREATE SUGGESTION SCREEN                             │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           HEADER                                        │
│                                                                         │
│  ┌─────────────┐  ┌─────────────────────────────────┐                   │
│  │  Back       │  │  Create Custom Suggestion       │                   │
│  │  Button     │  │                                 │                   │
│  └─────────────┘  └─────────────────────────────────┘                   │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           FORM                                          │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Service Type                                                   │    │
│  │  [Dropdown: Venue, Catering, Photography, etc.]                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Service Name                                                   │    │
│  │  [Text Input]                                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Description                                                    │    │
│  │  [Text Area]                                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Price Range                                                    │    │
│  │  [Dropdown: $, $$, $$$, $$$$]                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Contact Information                                            │    │
│  │  [Text Input]                                                   │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  Notes                                                          │    │
│  │  [Text Area]                                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           ACTION BUTTONS                                │
│                                                                         │
│  ┌─────────────────────────────────────────────────┐  ┌─────────────┐  │
│  │  Cancel                                         │  │  Save       │  │
│  │                                                 │  │             │  │
│  └─────────────────────────────────────────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

## Event Type-Specific Wizard Features

### Wedding Wizard

- **Unique Fields**:
  - Wedding style (traditional, modern, rustic, etc.)
  - Ceremony and reception locations (same or different)
  - Wedding party size
  - Special traditions or customs

### Business Event Wizard

- **Unique Fields**:
  - Event purpose (conference, seminar, team building, etc.)
  - Equipment needs (projectors, microphones, etc.)
  - Seating arrangement
  - Presentation requirements

### Celebration Event Wizard

- **Unique Fields**:
  - Celebration type (birthday, anniversary, graduation, etc.)
  - Theme options
  - Activities and entertainment
  - Gift registry options

## Integration with Other Features

### Integration with Planning Tools

- **Budget Tool**: Initial budget created based on wizard selections
- **Guest List Tool**: Initial guest count set from wizard
- **Timeline Tool**: Task templates selected based on event type
- **Messaging Tool**: Initial vendor contacts added based on services selected

### Integration with Services

- **Service Recommendations**: Services recommended based on wizard preferences
- **Service Filtering**: Wizard preferences used to pre-filter service listings
- **Service Comparison**: Suggested services can be added to comparison

### Integration with Booking System

- **Pre-filled Information**: Wizard data pre-fills booking forms
- **Budget Allocation**: Budget estimates from wizard used in booking process

## Data Models

### Event Template Model

```
EventTemplate {
  id: string,
  name: string,
  type: string,  // "wedding", "business", "celebration", "custom"
  description: string,
  defaultGuestCount: int,
  defaultBudget: double,
  suggestedServices: List<string>,  // Types of services typically needed
  defaultTimeline: List<Task>,  // Default tasks for this event type
  customFields: Map<string, dynamic>,  // Type-specific fields
}
```

### Wizard State Model

```
WizardState {
  id: string,
  eventType: string,  // "wedding", "business", "celebration", "custom"
  eventName: string,
  eventDate: DateTime,
  eventTime: TimeOfDay,
  guestCount: int,
  selectedServices: List<string>,
  estimatedBudget: double,
  budgetBreakdown: Map<string, double>,
  preferences: {
    style: string,
    colorScheme: string,
    venueType: string,
    additionalPreferences: string,
  },
  customFields: Map<string, dynamic>,  // Type-specific data
  step: int,  // Current step in the wizard
  isComplete: bool,
  createdAt: DateTime,
  updatedAt: DateTime,
}
```

### Suggestion Model

```
Suggestion {
  id: string,
  eventId: string,
  serviceType: string,  // "venue", "catering", "photography", etc.
  serviceName: string,
  serviceId: string,  // Reference to actual service if available
  matchPercentage: int,  // How well it matches preferences
  priceRange: string,  // "$", "$$", "$$$", "$$$$"
  description: string,
  isCustom: bool,  // Whether this is a user-created suggestion
  contactInfo: string,  // For custom suggestions
  notes: string,
  createdAt: DateTime,
}
```
