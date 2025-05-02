// Main barrel file for widgets
// This file exports all widget barrel files to simplify imports

// Common widgets
export 'common/error_message.dart';
export 'common/loading_indicator.dart';

// Feature-specific widgets
export 'auth/auth_widgets.dart';
export 'details/detail_widgets.dart';
export 'event_planning/event_planning_widgets.dart';
export 'event_wizard/event_wizard_widgets.dart';
export 'milestones/milestone_widgets.dart';
export 'services/service_widgets.dart';

// Note: Messaging widgets are exported through event_planning_widgets.dart
// to avoid ambiguous exports with event_planning/messaging widgets

// Responsive widgets
export 'responsive/responsive.dart';
