import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:intl/intl.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A card displaying an overview of an event
class EventOverviewCard extends StatelessWidget {
  final Event event;

  const EventOverviewCard({super.key, required this.event});

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
    final Color textPrimary =
        isDarkMode ? AppColorsDark.textPrimary : AppColors.textPrimary;
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
                        style: TextStyles.subtitle.copyWith(),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${StringUtils.capitalize(event.type.toString().split('.').last)}',
                        style: TextStyles.bodyMedium,
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
                    color:
                        isUpcoming
                            ? Color.fromRGBO(
                              AppColors.success.r.toInt(),
                              AppColors.success.g.toInt(),
                              AppColors.success.b.toInt(),
                              0.1,
                            )
                            : Color.fromRGBO(
                              AppColors.error.r.toInt(),
                              AppColors.error.g.toInt(),
                              AppColors.error.b.toInt(),
                              0.1,
                            ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUpcoming
                        ? daysUntil == 0
                            ? 'Today!'
                            : '$daysUntil days left'
                        : '${daysUntil.abs()} days ago',
                    style: TextStyle(
                      color:
                          isUpcoming
                              ? Color.fromRGBO(
                                AppColors.success.r.toInt(),
                                AppColors.success.g.toInt(),
                                AppColors.success.b.toInt(),
                                0.8,
                              )
                              : Color.fromRGBO(
                                AppColors.error.r.toInt(),
                                AppColors.error.g.toInt(),
                                AppColors.error.b.toInt(),
                                0.8,
                              ),
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
              Text('Description:', style: TextStyles.bodyMedium),
              const SizedBox(height: 4),
              Text(
                event.description!,
                style: TextStyles.bodyMedium,
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
              Text(label, style: TextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyles.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
