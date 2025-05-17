import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:intl/intl.dart';

/// A card displaying an overview of an event
class EventOverviewCard extends StatelessWidget {
  final Event event;

  const EventOverviewCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color textPrimary =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
    final Color textSecondary =
        isDarkMode ? AppColorsDark.textSecondary : AppColors.textSecondary;
    final Color accentColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    final daysUntil = event.date.difference(DateTime.now()).inDays;
    final isUpcoming = daysUntil >= 0;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${StringUtils.capitalize(event.type.toString().split('.').last)}',
                        style: TextStyle(fontSize: 14, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isUpcoming ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUpcoming
                        ? daysUntil == 0
                            ? 'Today!'
                            : '$daysUntil days left'
                        : '${daysUntil.abs()} days ago',
                    style: TextStyle(
                      color: isUpcoming ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                  context,
                  Icons.calendar_today,
                  'Date',
                  DateFormat('MMM d, yyyy').format(event.date),
                  accentColor,
                  textPrimary,
                ),
                const SizedBox(width: 24),
                _buildInfoItem(
                  context,
                  Icons.location_on,
                  'Location',
                  event.location,
                  accentColor,
                  textPrimary,
                ),
                const SizedBox(width: 24),
                _buildInfoItem(
                  context,
                  Icons.people,
                  'Guests',
                  '${event.guestCount}',
                  accentColor,
                  textPrimary,
                ),
              ],
            ),
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Description:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.description!,
                style: TextStyle(fontSize: 14, color: textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color iconColor,
    Color textColor,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: textColor.withAlpha(179)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
