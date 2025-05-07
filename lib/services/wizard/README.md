# Wizard Services

This directory contains services related to the event wizard functionality in the Eventati Book application.

## Overview

The wizard services provide functionality to connect the event wizard with other planning tools in the application. These services help transform the data collected during the wizard process into actionable items in the planning tools.

## Components

### WizardConnectionService

The `WizardConnectionService` is responsible for connecting the wizard data to various planning tools:

- **Budget Calculator**: Creates budget items based on selected services and event details
- **Guest List Management**: Sets up guest groups based on event type and initializes RSVP deadlines
- **Timeline/Checklist**: Generates tasks based on event type, date, and selected services
- **Service Recommendations**: Provides service recommendations based on wizard selections

### BudgetItemsBuilder

The `BudgetItemsBuilder` creates budget items based on the services selected in the wizard:

- Generates cost estimates based on guest count, event type, and duration
- Creates appropriate budget items for each selected service
- Provides budget allocation recommendations

### GuestGroupsBuilder

The `GuestGroupsBuilder` creates guest groups based on the event type:

- Provides different group structures for weddings, business events, and celebrations
- Creates appropriate color coding for different guest groups
- Initializes default groups based on event requirements

## Integration with Planning Tools

The wizard connection process follows these steps:

1. User completes the event wizard
2. `WizardProvider` calls `WizardConnectionService.connectToAllPlanningTools()`
3. Connection service transforms wizard data into planning tool data:
   - Budget items are created and added to the budget calculator
   - Guest groups are created and added to the guest list
   - Tasks are generated and added to the timeline with dependencies
   - Service recommendations are provided to the service screens

## Task Dependencies

The connection service creates logical dependencies between tasks:

- Tasks within the same category are sequenced chronologically
- Cross-category dependencies are created (e.g., venue booking must be completed before sending invitations)
- Dependencies are managed through the `TaskProvider.addDependency()` method

## Example Usage

```dart
// In the WizardProvider after completing the wizard
void completeWizard(BuildContext context) {
  // Convert WizardState to Map<String, dynamic>
  final wizardData = _state!.toJson();
  
  // Connect to all planning tools
  WizardConnectionService.connectToAllPlanningTools(context, wizardData);
}
```

## Future Enhancements

- Add more specialized task templates for different event types
- Implement more sophisticated budget estimation algorithms
- Add integration with vendor recommendation system
- Implement custom task dependency rules based on venue requirements
