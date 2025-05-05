# Screens Directory

This directory contains all the screens (pages) used in the Eventati Book application.

## Organization

The screens are organized into the following subfolders for better maintainability:

- **authentications/**: Authentication-related screens
  - auth_screen.dart: Main authentication screen
  - login_screen.dart: Login screen
  - register_screen.dart: Registration screen
  - forgetpassword_screen.dart: Forgot password screen
  - reset_password_screen.dart: Reset password screen
  - verification_screen.dart: Verification screen

- **booking/**: Booking-related screens
  - booking_details_screen.dart: Details of a booking
  - booking_form_screen.dart: Form for creating a booking
  - booking_history_screen.dart: History of bookings

- **events/**: Event-related screens
  - user_events_screen.dart: List of user's events

- **event_planning/**: Event planning tool screens
  - event_planning_tools_screen.dart: Main screen for planning tools
  - **budget/**: Budget management screens
    - budget_overview_screen.dart: Overview of the budget
    - budget_details_screen.dart: Details of budget items
    - budget_item_form_screen.dart: Form for budget items
  - **guest_list/**: Guest list management screens
    - guest_list_screen.dart: List of guests
    - guest_details_screen.dart: Details of a guest
    - guest_form_screen.dart: Form for adding/editing guests
    - guest_groups_screen.dart: Management of guest groups
  - **messaging/**: Vendor messaging screens
    - vendor_list_screen.dart: List of vendors
    - conversation_screen.dart: Conversation with a vendor
  - **milestones/**: Milestone tracking screens
    - milestone_screen.dart: Milestone tracking screen
  - **timeline/**: Timeline and checklist screens
    - timeline_screen.dart: Timeline view of tasks
    - checklist_screen.dart: Checklist view of tasks
    - task_form_screen.dart: Form for adding/editing tasks

- **event_wizard/**: Event wizard screens
  - event_wizard_screen.dart: Main wizard screen
  - suggestion_screen.dart: Suggestions based on wizard input
  - create_suggestion_screen.dart: Screen for creating custom suggestions
  - wizard_factory.dart: Factory for creating wizard screens

- **homepage/**: Homepage and event selection screens
  - homepage_screen.dart: Main homepage
  - event_selection_screen.dart: Selection of event types
  - event_checklist_selection_screen.dart: Selection of event checklists

- **profile/**: User profile screens
  - profile_screen.dart: User profile screen

- **services/**: Service browsing and comparison screens
  - **common/**: Common service screens
    - services_screen.dart: Main services screen
  - **venue/**: Venue-related screens
    - venue_list_screen.dart: List of venues
    - venue_details_screen.dart: Details of a venue
  - **catering/**: Catering-related screens
    - catering_list_screen.dart: List of catering services
    - catering_details_screen.dart: Details of a catering service
  - **photographer/**: Photographer-related screens
    - photographer_list_screen.dart: List of photographers
    - photographer_details_screen.dart: Details of a photographer
  - **planner/**: Planner-related screens
    - planner_list_screen.dart: List of planners
    - planner_details_screen.dart: Details of a planner
  - **comparison/**: Service comparison screens
    - service_comparison_screen.dart: Comparison of services
    - saved_comparisons_screen.dart: Saved comparisons

## Main Navigation

The `main_navigation_screen.dart` file in the root of the screens directory handles the main navigation structure of the application, including the bottom navigation bar.

## Screen Guidelines

1. **Naming Convention**: Use the suffix "_screen.dart" for all screen files
2. **Organization**: Place screens in the appropriate subfolder based on functionality
3. **Reusable Widgets**: Extract reusable widgets to the widgets directory
4. **Responsiveness**: Ensure all screens are responsive using the responsive utilities
5. **Error Handling**: Implement proper error handling and loading states
6. **Empty States**: Handle empty states appropriately
7. **Accessibility**: Make screens accessible with proper labels and semantics

## Navigation Flow

The application has several main navigation flows:

1. **Authentication Flow**: Login → Registration → Verification → Homepage
2. **Event Creation Flow**: Homepage → Event Selection → Event Wizard → Event Planning Tools
3. **Service Browsing Flow**: Services → Service List → Service Details → Booking
4. **Planning Tools Flow**: Event Planning Tools → Individual Tool (Budget, Guest List, etc.)

## Usage

Import the main barrel file to access all screens:

```dart
import 'package:eventati_book/screens/screens.dart';

// Navigate to a screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => HomepageScreen()),
);
```

For more specific imports, use the subfolder barrel files:

```dart
import 'package:eventati_book/screens/services/service_screens.dart';

// Navigate to a service screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => VenueListScreen()),
);
```
