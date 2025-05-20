import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// A widget to indicate the availability status of a service
class AvailabilityIndicator extends StatelessWidget {
  /// Whether the service is available
  final bool isAvailable;

  /// Constructor
  const AvailabilityIndicator({super.key, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = UIUtils.isDarkMode(context);

    final Color availableColor =
        isDarkMode ? AppColorsDark.success : AppColors.success;

    final Color unavailableColor =
        isDarkMode ? AppColorsDark.error : AppColors.error;

    final String statusText = isAvailable ? 'Available' : 'Unavailable';
    final Color statusColor = isAvailable ? availableColor : unavailableColor;
    final IconData statusIcon =
        isAvailable ? Icons.check_circle_outline : Icons.cancel_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          statusColor.r.toInt(),
          statusColor.g.toInt(),
          statusColor.b.toInt(),
          0.9,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14.0, color: Colors.white),
          const SizedBox(width: 4.0),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
