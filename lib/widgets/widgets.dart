// =========================================================
// EVENTATI BOOK WIDGETS BARREL FILE
// =========================================================
// This file exports all reusable UI components to simplify imports.
// Widgets are organized into logical categories for better maintainability.
//
// USAGE:
//   import 'package:eventati_book/widgets/widgets.dart';
//
// ORGANIZATION:
//   Widgets are organized into subfolders by functionality
// =========================================================

// -------------------------
// COMMON WIDGETS
// -------------------------
// General-purpose widgets used throughout the application
export 'common/error_message.dart'; // Display error messages
export 'common/error_screen.dart'; // Full-screen error display
export 'common/empty_state.dart'; // Display when no data is available
export 'common/loading_indicator.dart'; // Loading spinner/indicator
export 'common/confirmation_dialog.dart'; // Dialog for confirming actions
export 'common/route_guard_wrapper.dart'; // Wrapper for applying route guards
export 'common/feature_guard_wrapper.dart'; // Wrapper for applying feature guards
export 'common/cached_network_image_widget.dart'; // Widget for displaying cached network images
export 'common/image_gallery.dart'; // Widget for displaying image galleries
export 'common/step_progress_indicator.dart'; // Progress indicator for multi-step flows
export 'common/back_to_top_button.dart'; // Button to scroll back to top
export 'common/scroll_to_top_wrapper.dart'; // Wrapper that adds a back to top button
export 'common/async_button.dart'; // Button that shows loading state during async operations
export 'common/progress_indicator_widget.dart'; // Customizable progress indicator for long operations
export 'common/toast_message.dart'; // Customizable toast message for confirmations

// -------------------------
// AUTHENTICATION WIDGETS
// -------------------------
// Widgets used in authentication screens
export 'auth/auth_widgets.dart'; // Barrel file for auth widgets
// Includes:
// - AuthButton: Custom button for authentication actions
// - AuthTextField: Custom text field for authentication forms
// - AuthTitleWidget: Title widget for authentication screens
// - VerificationCodeInput: Input for verification codes

// -------------------------
// DETAIL SCREEN WIDGETS
// -------------------------
// Widgets used in detail screens for services and other items
export 'details/detail_widgets.dart'; // Barrel file for detail widgets
// Includes:
// - ChipGroup: Group of chips for displaying categories
// - DetailTabBar: Tab bar for detail screens
// - FeatureItem: Item displaying a feature
// - ImagePlaceholder: Placeholder for images
// - InfoCard: Card displaying information
// - PackageCard: Card displaying package information

// -------------------------
// EVENT PLANNING WIDGETS
// -------------------------
// Widgets used in event planning tools
export 'event_planning/event_planning_widgets.dart'; // Barrel file for planning widgets
// Includes:
// - ToolCard: Card displaying a planning tool
// - Messaging widgets (through event_planning/messaging subfolder)

// -------------------------
// EVENT WIZARD WIDGETS
// -------------------------
// Widgets used in the event creation wizard
export 'event_wizard/event_wizard_widgets.dart'; // Barrel file for wizard widgets
// Includes:
// - DatePickerTile: Tile for picking dates
// - EventNameInput: Input for event names
// - EventTypeDropdown: Dropdown for selecting event types
// - GuestCountInput: Input for guest counts
// - ServicesSelection: Selection for services
// - SuggestionCard: Card displaying suggestions
// - TimePickerTile: Tile for picking times
// - WizardProgressIndicator: Indicator for wizard progress

// -------------------------
// MILESTONE WIDGETS
// -------------------------
// Widgets for milestone tracking and celebration
export 'milestones/milestone_widgets.dart'; // Barrel file for milestone widgets
// Includes:
// - MilestoneCard: Card displaying a milestone
// - MilestoneCelebrationOverlay: Overlay for celebrating milestones
// - MilestoneDetailDialog: Dialog showing milestone details
// - MilestoneGrid: Grid of milestones

// -------------------------
// SERVICE WIDGETS
// -------------------------
// Widgets for browsing and comparing services
export 'services/service_widgets.dart'; // Barrel file for service widgets
// Includes:
// - ComparisonItemCard: Card for comparison items
// - FeatureComparisonTable: Table comparing features
// - FilterDialog: Dialog for filtering services
// - MultiSelectChipGroup: Chip group for multiple selection
// - PriceRangeFilter: Filter for price ranges
// - PricingComparisonTable: Table comparing prices
// - RangeSliderFilter: Filter using a range slider
// - RecommendedBadge: Badge for recommended services
// - ServiceCard: Card displaying a service
// - ServiceFilterBar: Bar for filtering services

// -------------------------
// RESPONSIVE DESIGN WIDGETS
// -------------------------
// Widgets for creating responsive layouts
export 'responsive/responsive.dart'; // Barrel file for responsive widgets
// Includes:
// - ResponsiveBuilder: Builder for responsive layouts
// - ResponsiveGridView: Grid view that adapts to screen size
// - ResponsiveLayout: Layout that adapts to screen size

// -------------------------
// NOTIFICATION WIDGETS
// -------------------------
// Widgets for displaying notifications
export 'notification/notification_widgets.dart'; // Barrel file for notification widgets
// Includes:
// - NotificationBadge: Badge showing unread notification count
// - NotificationCenter: Dropdown for displaying notifications

// -------------------------
// NAVIGATION WIDGETS
// -------------------------
// Widgets for navigation and breadcrumbs
export 'navigation/navigation_widgets.dart'; // Barrel file for navigation widgets
// Includes:
// - BreadcrumbNavigation: Widget for displaying breadcrumb navigation paths

// -------------------------
// HOMEPAGE WIDGETS
// -------------------------
// Widgets used on the homepage
export 'homepage/homepage_widgets.dart'; // Barrel file for homepage widgets
// Includes:
// - QuickActionButton: Button for quick actions on the homepage

// -------------------------
// SPECIAL NOTES
// -------------------------
// Note: Messaging widgets are exported through event_planning_widgets.dart
// to avoid ambiguous exports with event_planning/messaging widgets.
// If you need specific messaging widgets, import them directly:
//   import 'package:eventati_book/widgets/messaging/message_bubble.dart';
