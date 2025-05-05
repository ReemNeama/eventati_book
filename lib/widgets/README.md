# Widgets Directory

This directory contains reusable UI components used throughout the Eventati Book application.

## Organization

The widgets are organized into the following subfolders for better maintainability:

- **auth/**: Authentication-related widgets
  - auth_button.dart: Custom button for authentication actions
  - auth_text_field.dart: Custom text field for authentication forms
  - auth_title_widget.dart: Title widget for authentication screens
  - verification_code_input.dart: Input for verification codes

- **booking/**: Booking-related widgets
  - booking_card.dart: Card displaying booking information
  
- **common/**: Common widgets used across the application
  - confirmation_dialog.dart: Dialog for confirming user actions
  - empty_state.dart: Widget displayed when no data is available
  - error_message.dart: Widget for displaying error messages
  - error_screen.dart: Screen displayed when an error occurs
  - loading_indicator.dart: Loading indicator for async operations

- **details/**: Widgets for detail screens
  - chip_group.dart: Group of chips for displaying categories
  - detail_tab_bar.dart: Tab bar for detail screens
  - feature_item.dart: Item displaying a feature
  - image_placeholder.dart: Placeholder for images
  - info_card.dart: Card displaying information
  - package_card.dart: Card displaying package information

- **event_planning/**: Widgets for event planning tools
  - tool_card.dart: Card displaying a planning tool
  - **messaging/**: Messaging-specific widgets
    - date_separator.dart: Separator for dates in message lists
    - message_bubble.dart: Bubble for displaying messages
    - message_input.dart: Input for composing messages
    - vendor_card.dart: Card displaying vendor information

- **event_wizard/**: Widgets for the event wizard
  - date_picker_tile.dart: Tile for picking dates
  - event_name_input.dart: Input for event names
  - event_type_dropdown.dart: Dropdown for selecting event types
  - guest_count_input.dart: Input for guest counts
  - services_selection.dart: Selection for services
  - suggestion_card.dart: Card displaying suggestions
  - time_picker_tile.dart: Tile for picking times
  - wizard_progress_indicator.dart: Indicator for wizard progress

- **messaging/**: General messaging widgets
  - message_bubble.dart: Bubble for displaying messages
  - message_input.dart: Input for composing messages

- **milestones/**: Milestone-related widgets
  - milestone_card.dart: Card displaying a milestone
  - milestone_celebration_overlay.dart: Overlay for celebrating milestones
  - milestone_detail_dialog.dart: Dialog showing milestone details
  - milestone_grid.dart: Grid of milestones

- **responsive/**: Widgets for responsive design
  - responsive_builder.dart: Builder for responsive layouts
  - responsive_grid_view.dart: Grid view that adapts to screen size
  - responsive_layout.dart: Layout that adapts to screen size

- **services/**: Service-related widgets
  - comparison_item_card.dart: Card for comparison items
  - feature_comparison_table.dart: Table comparing features
  - filter_dialog.dart: Dialog for filtering services
  - multi_select_chip_group.dart: Chip group for multiple selection
  - price_range_filter.dart: Filter for price ranges
  - pricing_comparison_table.dart: Table comparing prices
  - range_slider_filter.dart: Filter using a range slider
  - recommended_badge.dart: Badge for recommended services
  - service_card.dart: Card displaying a service
  - service_filter_bar.dart: Bar for filtering services

## Usage

Import the main barrel file to access all widgets:

```dart
import 'package:eventati_book/widgets/widgets.dart';

// Now you can use any widget
final loadingIndicator = LoadingIndicator();
final errorMessage = ErrorMessage(message: 'Something went wrong');
```

For more specific imports, use the subfolder barrel files:

```dart
import 'package:eventati_book/widgets/auth/auth_widgets.dart';

// Now you can use any auth widget
final authButton = AuthButton(onPressed: () {}, label: 'Sign In');
```

## Widget Guidelines

1. **Reusability**: Create widgets that can be reused across multiple screens
2. **Customization**: Allow for customization through constructor parameters
3. **Responsiveness**: Ensure widgets adapt to different screen sizes
4. **Accessibility**: Make widgets accessible with proper labels and semantics
5. **Documentation**: Document widget parameters and usage
6. **Naming**: Use descriptive names that indicate the widget's purpose
7. **Organization**: Place widgets in the appropriate subfolder based on functionality

## Note on Ambiguous Exports

Some widgets (like MessageBubble and MessageInput) exist in both the `event_planning/messaging` and `messaging` directories. To avoid ambiguous exports, these are handled carefully in the barrel files. When using these widgets, be specific about which version you're importing if needed.
