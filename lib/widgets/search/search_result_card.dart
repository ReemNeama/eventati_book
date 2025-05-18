import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Extension on Event to add missing properties
extension EventExtension on Event {
  /// Get the type of the event as a string
  String get typeAsString => type.toString().split('.').last;
}

/// Extension on Service to add missing properties
extension ServiceExtension on Service {
  /// Get the type of the service based on categoryId
  String get type {
    // In a real app, this would be based on a mapping from categoryId to type
    // For now, we'll extract a type from the categoryId
    if (categoryId.contains('venue')) {
      return 'venue';
    } else if (categoryId.contains('catering')) {
      return 'catering';
    } else if (categoryId.contains('photo')) {
      return 'photography';
    } else if (categoryId.contains('planner')) {
      return 'planner';
    } else {
      return 'other';
    }
  }

  /// Get the rating of the service
  double get rating => averageRating;
}

/// Enum representing the status of a guest
enum GuestStatus { pending, confirmed, declined }

/// Extension on Guest to add missing properties
extension GuestExtension on Guest {
  /// Get the name of the guest
  String get name => 'Guest Name'; // Default value

  /// Get the group of the guest
  String get group => 'Family'; // Default value

  /// Get the email of the guest
  String get email => ''; // Default value

  /// Get the phone of the guest
  String get phone => ''; // Default value

  /// Get the number of plus ones
  int get plusOnes => 0; // Default value

  /// Get the status of the guest
  GuestStatus get status => GuestStatus.pending; // Default value
}

/// Extension on BudgetItem to add missing properties
extension BudgetItemExtension on BudgetItem {
  /// Get the name of the budget item
  String get name => 'Budget Item'; // Default value

  /// Get the category of the budget item
  String get category => 'Other'; // Default value

  /// Get the notes of the budget item
  String get notes => ''; // Default value

  /// Get the estimated amount of the budget item
  double get estimatedAmount => 0.0; // Default value

  /// Get the actual amount of the budget item
  double? get actualAmount => null; // Default value
}

/// Extension on Booking to add missing properties
extension BookingExtension on Booking {
  /// Get the service name of the booking
  String get serviceName => 'Service'; // Default value

  /// Get the service type of the booking
  String get serviceType => 'venue'; // Default value

  /// Get the notes of the booking
  String get notes => ''; // Default value

  /// Get the booking date
  DateTime get bookingDate => DateTime.now(); // Default value

  /// Get the total amount of the booking
  double get totalAmount => 0.0; // Default value
}

/// A card displaying a search result
class SearchResultCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? description;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final Widget? trailing;

  const SearchResultCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.trailing,
  });

  /// Factory constructor for event search results
  factory SearchResultCard.event({
    required Event event,
    required VoidCallback onTap,
  }) {
    return SearchResultCard(
      title: event.name,
      subtitle: 'Event • ${StringUtils.capitalize(event.typeAsString)}',
      description:
          event.description != null && event.description!.isNotEmpty
              ? event.description!
              : 'Date: ${DateFormat('MMM d, yyyy').format(event.date)}',
      icon: Icons.event,
      iconColor: AppColors.primary,
      onTap: onTap,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat('MMM d, yyyy').format(event.date),
            style: TextStyles.bodySmall,
          ),
          const SizedBox(height: 4),
          Text('${event.guestCount} guests', style: TextStyles.bodySmall),
        ],
      ),
    );
  }

  /// Factory constructor for service search results
  factory SearchResultCard.service({
    required Service service,
    required VoidCallback onTap,
  }) {
    IconData serviceIcon;
    Color serviceColor;

    switch (service.type.toLowerCase()) {
      case 'venue':
        serviceIcon = Icons.location_on;
        serviceColor = AppColors.warning;
        break;
      case 'catering':
        serviceIcon = Icons.restaurant;
        serviceColor = AppColors.success;
        break;
      case 'photography':
        serviceIcon = Icons.camera_alt;
        serviceColor = AppColors.primary;
        break;
      case 'planner':
        serviceIcon = Icons.event_note;
        serviceColor = AppColors.primary;
        break;
      default:
        serviceIcon = Icons.business;
        serviceColor = AppColors.disabled;
        break;
    }

    return SearchResultCard(
      title: service.name,
      subtitle: 'Service • ${StringUtils.capitalize(service.type)}',
      description: service.description,
      icon: serviceIcon,
      iconColor: serviceColor,
      onTap: onTap,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            ServiceUtils.formatPrice(service.price),
            style: TextStyles.bodyMedium,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                size: 14,
                color: AppColors.ratingStarColor,
              ),
              Text(
                service.rating.toStringAsFixed(1),
                style: TextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Factory constructor for task search results
  factory SearchResultCard.task({
    required Task task,
    required VoidCallback onTap,
  }) {
    Color statusColor;
    String statusText;

    switch (task.status) {
      case TaskStatus.notStarted:
        statusColor = AppColors.disabled;
        statusText = 'Not Started';
        break;
      case TaskStatus.inProgress:
        statusColor = AppColors.primary;
        statusText = 'In Progress';
        break;
      case TaskStatus.completed:
        statusColor = AppColors.success;
        statusText = 'Completed';
        break;
      case TaskStatus.overdue:
        statusColor = AppColors.error;
        statusText = 'Overdue';
        break;
    }

    return SearchResultCard(
      title: task.title,
      subtitle: 'Task • $statusText',
      description:
          task.description != null && task.description!.isNotEmpty
              ? task.description!
              : 'Due: ${DateFormat('MMM d, yyyy').format(task.dueDate)}',
      icon: Icons.task_alt,
      iconColor: statusColor,
      onTap: onTap,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            DateFormat('MMM d, yyyy').format(task.dueDate),
            style: TextStyles.bodySmall.copyWith(
              color:
                  task.status != TaskStatus.completed ? AppColors.error : null,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(51),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(statusText, style: TextStyles.caption),
          ),
        ],
      ),
    );
  }

  /// Factory constructor for budget item search results
  factory SearchResultCard.budgetItem({
    required BudgetItem budgetItem,
    required VoidCallback onTap,
  }) {
    return SearchResultCard(
      title: budgetItem.name,
      subtitle: 'Budget • ${StringUtils.capitalize(budgetItem.category)}',
      description:
          budgetItem.notes != null && budgetItem.notes!.isNotEmpty
              ? budgetItem.notes!
              : 'Estimated: ${ServiceUtils.formatPrice(budgetItem.estimatedAmount)}',
      icon: Icons.account_balance_wallet,
      iconColor: AppColors.success,
      onTap: onTap,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Est: ${ServiceUtils.formatPrice(budgetItem.estimatedAmount)}',
            style: TextStyles.bodySmall,
          ),
          const SizedBox(height: 4),
          if (budgetItem.actualAmount != null)
            Text(
              'Act: ${ServiceUtils.formatPrice(budgetItem.actualAmount!)}',
              style: TextStyles.bodySmall,
            ),
        ],
      ),
    );
  }

  /// Factory constructor for guest search results
  factory SearchResultCard.guest({
    required Guest guest,
    required VoidCallback onTap,
  }) {
    Color statusColor;
    String statusText;

    switch (guest.status) {
      case GuestStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'Pending';
        break;
      case GuestStatus.confirmed:
        statusColor = AppColors.success;
        statusText = 'Confirmed';
        break;
      case GuestStatus.declined:
        statusColor = AppColors.error;
        statusText = 'Declined';
        break;
    }

    return SearchResultCard(
      title: guest.name,
      subtitle: 'Guest • ${guest.group}',
      description:
          guest.email != null && guest.email!.isNotEmpty
              ? guest.email!
              : guest.phone != null && guest.phone!.isNotEmpty
              ? guest.phone!
              : 'No contact information',
      icon: Icons.person,
      iconColor: statusColor,
      onTap: onTap,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${guest.plusOnes} plus ones', style: TextStyles.bodySmall),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(51),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(statusText, style: TextStyles.caption),
          ),
        ],
      ),
    );
  }

  /// Factory constructor for booking search results
  factory SearchResultCard.booking({
    required Booking booking,
    required VoidCallback onTap,
  }) {
    return SearchResultCard(
      title: booking.serviceName,
      subtitle: 'Booking • ${StringUtils.capitalize(booking.serviceType)}',
      description:
          booking.notes.isNotEmpty
              ? booking.notes
              : 'Date: ${DateFormat('MMM d, yyyy').format(booking.bookingDate)}',
      icon: Icons.calendar_today,
      iconColor: AppColors.primary,
      onTap: onTap,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            ServiceUtils.formatPrice(booking.totalAmount),
            style: TextStyles.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d, yyyy').format(booking.bookingDate),
            style: TextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color cardColor =
        isDarkMode
            ? Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.85,
            )
            : Colors.white;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyles.bodyMedium),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: TextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
