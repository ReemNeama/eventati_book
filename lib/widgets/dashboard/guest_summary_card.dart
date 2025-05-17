import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

/// Enum representing the status of a guest
enum GuestStatus { pending, confirmed, declined, tentative }

/// Extension on Guest to add missing properties
extension GuestExtension on Guest {
  /// Get the status of the guest
  GuestStatus get status {
    // In a real app, this would be based on a property in the Guest model
    // For now, we'll return a default value
    return GuestStatus.pending;
  }
}

/// A card displaying a summary of guests
class GuestSummaryCard extends StatelessWidget {
  final List<Guest> guests;

  const GuestSummaryCard({super.key, required this.guests});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color textPrimary =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    // We don't need textSecondary in this widget

    // Calculate guest statistics
    final int totalGuests = guests.length;
    final int confirmedGuests =
        guests.where((guest) => guest.status == GuestStatus.confirmed).length;
    final int pendingGuests =
        guests.where((guest) => guest.status == GuestStatus.pending).length;
    final int declinedGuests =
        guests.where((guest) => guest.status == GuestStatus.declined).length;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guest List Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGuestStatItem(
                  'Total',
                  totalGuests,
                  Colors.blue,
                  textPrimary,
                ),
                _buildGuestStatItem(
                  'Confirmed',
                  confirmedGuests,
                  Colors.green,
                  textPrimary,
                ),
                _buildGuestStatItem(
                  'Pending',
                  pendingGuests,
                  Colors.orange,
                  textPrimary,
                ),
                _buildGuestStatItem(
                  'Declined',
                  declinedGuests,
                  Colors.red,
                  textPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestStatItem(
    String label,
    int count,
    Color color,
    Color textColor,
  ) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: textColor)),
      ],
    );
  }
}
