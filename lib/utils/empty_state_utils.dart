import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';

/// Utility functions for empty states
class EmptyStateUtils {
  /// Get an empty state widget for a list
  static Widget getEmptyListState({
    required String itemType,
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
  }) {
    return EmptyState.list(
      title: 'No $itemType',
      message: 'No $itemType have been added yet',
      actionText: actionText,
      onAction: onAction,
      displayType: displayType,
    );
  }

  /// Get an empty state widget for search results
  static Widget getEmptySearchState({
    required String searchTerm,
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
  }) {
    return EmptyState.search(
      title: 'No results found',
      message: 'No matches found for "$searchTerm"',
      actionText: actionText,
      onAction: onAction,
      displayType: displayType,
    );
  }

  /// Get an empty state widget for filtered results
  static Widget getEmptyFilterState({
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
  }) {
    return EmptyState.search(
      title: 'No matches',
      message: 'No items match your current filters',
      actionText: actionText ?? 'Clear Filters',
      onAction: onAction,
      displayType: displayType,
    );
  }

  /// Get an empty state widget for events
  static Widget getEmptyEventsState({
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
  }) {
    return EmptyState(
      title: 'No events yet',
      message: 'Create your first event to get started',
      icon: Icons.event_busy,
      actionText: actionText ?? 'Create Event',
      onAction: onAction,
      displayType: displayType,
    );
  }

  /// Get an empty state widget for guest list
  static Widget getEmptyGuestListState({
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
  }) {
    return EmptyState(
      title: 'No guests yet',
      message: 'Add guests to your event',
      icon: Icons.people_outline,
      actionText: actionText ?? 'Add Guest',
      onAction: onAction,
      displayType: displayType,
    );
  }

  /// Get an empty state widget for budget
  static Widget getEmptyBudgetState({
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
  }) {
    return EmptyState(
      title: 'No budget items',
      message: 'Add items to your budget',
      icon: Icons.account_balance_wallet_outlined,
      actionText: actionText ?? 'Add Item',
      onAction: onAction,
      displayType: displayType,
    );
  }

  /// Get an empty state widget for timeline
  static Widget getEmptyTimelineState({
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
  }) {
    return EmptyState(
      title: 'No tasks yet',
      message: 'Add tasks to your timeline',
      icon: Icons.checklist,
      actionText: actionText ?? 'Add Task',
      onAction: onAction,
      displayType: displayType,
    );
  }

  /// Get an empty state widget for messages
  static Widget getEmptyMessagesState({
    String? actionText,
    VoidCallback? onAction,
    EmptyStateDisplayType displayType = EmptyStateDisplayType.standard,
  }) {
    return EmptyState(
      title: 'No messages',
      message: 'Start a conversation with a vendor',
      icon: Icons.message_outlined,
      actionText: actionText,
      onAction: onAction,
      displayType: displayType,
    );
  }
}
