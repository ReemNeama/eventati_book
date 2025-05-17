import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';

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
  }) {
    return EmptyState(
      title: 'No $itemType',
      message: 'No $itemType have been added yet',
      icon: Icons.list_alt_outlined,
      actionText: actionText,
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
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
  }) {
    return EmptyState(
      title: 'No Results Found',
      message: 'No matches found for "$searchTerm"',
      icon: Icons.search_off_outlined,
      actionText: actionText,
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
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
  }) {
    return EmptyState(
      title: 'No Matches',
      message: 'No items match your current filters',
      icon: Icons.filter_alt_off,
      actionText: actionText ?? 'Clear Filters',
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
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
  }) {
    return EmptyState(
      title: 'No Events Yet',
      message: 'Create your first event to get started',
      icon: Icons.event_busy,
      actionText: actionText ?? 'Create Event',
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
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
  }) {
    return EmptyState(
      title: 'No Guests Yet',
      message: 'Add guests to your event',
      icon: Icons.people_outline,
      actionText: actionText ?? 'Add Guest',
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
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
  }) {
    return EmptyState(
      title: 'No Budget Items',
      message: 'Add items to your budget',
      icon: Icons.account_balance_wallet_outlined,
      actionText: actionText ?? 'Add Item',
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
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
  }) {
    return EmptyState(
      title: 'No Tasks Yet',
      message: 'Add tasks to your timeline',
      icon: Icons.checklist,
      actionText: actionText ?? 'Add Task',
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
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
  }) {
    return EmptyState(
      title: 'No Messages',
      message: 'Start a conversation with a vendor',
      icon: Icons.message_outlined,
      actionText: actionText,
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
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
  }) {
    return EmptyState(
      title: 'No Notifications',
      message: 'You\'re all caught up!',
      icon: Icons.notifications_none_outlined,
      actionText: actionText,
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
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
  }) {
    return EmptyState(
      title: 'No Bookings Yet',
      message: 'Book a service to see your bookings here',
      icon: Icons.calendar_today_outlined,
      actionText: actionText,
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      displayType: displayType,
      animationType: animationType,
    );
  }
}
