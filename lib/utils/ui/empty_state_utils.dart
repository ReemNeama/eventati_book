import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/illustrations/empty_state_illustrations.dart';

/// Utility functions for empty states
class EmptyStateUtils {
  /// Get an empty state widget for a list
  static Widget getEmptyListState({
    required String itemType,
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    Widget? illustration,
    BuildContext? context,
  }) {
    return EmptyState(
      title: 'No $itemType Yet',
      message:
          'You haven\'t added any $itemType yet. Add your first one to get started!',
      guidance:
          'Adding your first $itemType will help you organize and track your event planning process. You can always add more later.',
      icon: Icons.list_alt_outlined,
      actionText: actionText ?? 'Add $itemType',
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
      illustration:
          illustration ??
          (context != null
              ? EmptyStateIllustrations.getEmptyListIllustration(context)
              : null),
    );
  }

  /// Get an empty state widget for search results
  static Widget getEmptySearchState({
    required String searchTerm,
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    Widget? illustration,
    BuildContext? context,
  }) {
    return EmptyState(
      title: 'No Results Found',
      message:
          'We couldn\'t find any matches for "$searchTerm". Try checking your spelling or using different keywords.',
      guidance:
          'Search is most effective with simple terms. Try using fewer words or more general terms. You can also browse all items instead of searching.',
      icon: Icons.search_off_outlined,
      actionText: actionText ?? 'Clear Search',
      onAction: onAction,
      secondaryActionText: secondaryActionText ?? 'Browse All',
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
      illustration:
          illustration ??
          (context != null
              ? EmptyStateIllustrations.getEmptySearchIllustration(context)
              : null),
    );
  }

  /// Get an empty state widget for filtered results
  static Widget getEmptyFilterState({
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    Widget? illustration,
  }) {
    return EmptyState(
      title: 'No Matching Results',
      message:
          'Your current filters are too restrictive. Try removing some filters or selecting different options to see more results.',
      icon: Icons.filter_alt_off,
      actionText: actionText ?? 'Clear All Filters',
      onAction: onAction,
      secondaryActionText: secondaryActionText ?? 'Adjust Filters',
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
      illustration: illustration,
    );
  }

  /// Get an empty state widget for events
  static Widget getEmptyEventsState({
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    Widget? illustration,
    BuildContext? context,
  }) {
    return EmptyState(
      title: 'No Events Yet',
      message:
          'Start planning your special occasion by creating your first event. Our tools will help you organize everything from guest lists to budgets.',
      guidance:
          'Creating an event is the first step in your planning journey. You\'ll be able to set dates, manage guest lists, track your budget, and organize tasks all in one place.',
      icon: Icons.event_busy,
      actionText: actionText ?? 'Create Your First Event',
      onAction: onAction,
      secondaryActionText: secondaryActionText ?? 'Explore Event Types',
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
      illustration:
          illustration ??
          (context != null
              ? EmptyStateIllustrations.getEmptyEventsIllustration(context)
              : null),
    );
  }

  /// Get an empty state widget for guest list
  static Widget getEmptyGuestListState({
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    Widget? illustration,
  }) {
    return EmptyState(
      title: 'Your Guest List is Empty',
      message:
          'Start adding guests to your event. You\'ll be able to track RSVPs, manage seating arrangements, and send updates to everyone on your list.',
      icon: Icons.people_outline,
      actionText: actionText ?? 'Add Your First Guest',
      onAction: onAction,
      secondaryActionText: secondaryActionText ?? 'Import Contacts',
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
      illustration: illustration,
    );
  }

  /// Get an empty state widget for budget
  static Widget getEmptyBudgetState({
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    Widget? illustration,
  }) {
    return EmptyState(
      title: 'Your Budget is Empty',
      message:
          'Start planning your event finances by adding budget items. Track expenses, set spending limits, and stay on top of your event costs.',
      icon: Icons.account_balance_wallet_outlined,
      actionText: actionText ?? 'Add First Budget Item',
      onAction: onAction,
      secondaryActionText: secondaryActionText ?? 'Use Budget Template',
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
      illustration: illustration,
    );
  }

  /// Get an empty state widget for timeline
  static Widget getEmptyTimelineState({
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    Widget? illustration,
  }) {
    return EmptyState(
      title: 'Your Timeline is Empty',
      message:
          'Create tasks to build your event timeline. Stay organized with deadlines, reminders, and task dependencies to ensure everything happens on schedule.',
      icon: Icons.checklist,
      actionText: actionText ?? 'Add Your First Task',
      onAction: onAction,
      secondaryActionText: secondaryActionText ?? 'Use Task Template',
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
      illustration: illustration,
    );
  }

  /// Get an empty state widget for messages
  static Widget getEmptyMessagesState({
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    Widget? illustration,
  }) {
    return EmptyState(
      title: 'No Messages Yet',
      message:
          'Connect with vendors and service providers by starting a conversation. Keep all your event communications in one place for easy reference.',
      icon: Icons.message_outlined,
      actionText: actionText ?? 'Find Vendors',
      onAction: onAction,
      secondaryActionText: secondaryActionText ?? 'View Recommended Vendors',
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
      illustration: illustration,
    );
  }

  /// Get an empty state widget for notifications
  static Widget getEmptyNotificationsState({
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    Widget? illustration,
  }) {
    return EmptyState(
      title: 'No Notifications',
      message:
          'You\'re all caught up! Notifications about your events, tasks, and messages will appear here to keep you informed of important updates.',
      icon: Icons.notifications_none_outlined,
      actionText: actionText ?? 'Set Notification Preferences',
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
      illustration: illustration,
    );
  }

  /// Get an empty state widget for bookings
  static Widget getEmptyBookingsState({
    String? actionText,
    VoidCallback? onAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
    EmptyStateAnimationType animationType = EmptyStateAnimationType.fadeIn,
    Widget? illustration,
  }) {
    return EmptyState(
      title: 'No Bookings Yet',
      message:
          'Book venues and services for your event to keep track of all your reservations in one place. Manage dates, times, and payment details with ease.',
      icon: Icons.calendar_today_outlined,
      actionText: actionText ?? 'Browse Services',
      onAction: onAction,
      secondaryActionText: secondaryActionText ?? 'View Recommended Services',
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
      illustration: illustration,
    );
  }
}
