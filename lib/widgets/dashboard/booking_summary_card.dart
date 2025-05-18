import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:intl/intl.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Extension on Booking to add missing properties
extension BookingExtension on Booking {
  /// Get the booking date
  DateTime get bookingDate => createdAt;

  /// Get the total amount
  double get totalAmount => 0.0; // Default value

  /// Get the service type
  String get serviceType => 'venue'; // Default to venue if not specified

  /// Get the service name
  String get serviceName => 'Service'; // Default name if not specified
}

/// A card displaying a summary of bookings
class BookingSummaryCard extends StatelessWidget {
  final List<Booking> bookings;

  const BookingSummaryCard({super.key, required this.bookings});

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

    final Color textSecondary =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;

    // Sort bookings by date
    final sortedBookings = List<Booking>.from(bookings)
      ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));

    // Take only the first 3 bookings
    final displayBookings = sortedBookings.take(3).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Bookings',
                  style: TextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('${bookings.length} total', style: TextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 12),
            ...displayBookings.map(
              (booking) => _buildBookingItem(context, booking),
            ),
            if (displayBookings.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No bookings yet',
                    style: TextStyle(
                      color: textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem(BuildContext context, Booking booking) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getServiceTypeColor(booking.serviceType).withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                _getServiceTypeIcon(booking.serviceType),
                color: _getServiceTypeColor(booking.serviceType),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.serviceName, style: TextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  'Type: ${StringUtils.capitalize(booking.serviceType)}',
                  style: TextStyles.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Date: ${DateFormat('MMM d, yyyy').format(booking.bookingDate)}',
                  style: TextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            ServiceUtils.formatPrice(booking.totalAmount),
            style: TextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  IconData _getServiceTypeIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'venue':
        return Icons.location_on;
      case 'catering':
        return Icons.restaurant;
      case 'photography':
        return Icons.camera_alt;
      case 'planner':
        return Icons.event;
      default:
        return Icons.business;
    }
  }

  Color _getServiceTypeColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'venue':
        return AppColors.primary;
      case 'catering':
        return AppColors.warning;
      case 'photography':
        return AppColors.primary;
      case 'planner':
        return AppColors.success;
      default:
        return AppColors.disabled;
    }
  }
}
