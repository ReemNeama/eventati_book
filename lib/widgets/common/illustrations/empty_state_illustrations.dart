import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';

/// A collection of illustrations for empty states
class EmptyStateIllustrations {
  /// Get an illustration for an empty list
  static Widget getEmptyListIllustration(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final secondaryColor =
        isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  primaryColor.r.toInt(),
                  primaryColor.g.toInt(),
                  primaryColor.b.toInt(),
                  isDarkMode ? 0.1 : 0.05,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(Icons.list_alt_outlined, size: 60, color: primaryColor),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: secondaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Get an illustration for empty search results
  static Widget getEmptySearchIllustration(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  primaryColor.r.toInt(),
                  primaryColor.g.toInt(),
                  primaryColor.b.toInt(),
                  isDarkMode ? 0.1 : 0.05,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.search_off_outlined,
              size: 60,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Get an illustration for empty events
  static Widget getEmptyEventsIllustration(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final accentColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  primaryColor.r.toInt(),
                  primaryColor.g.toInt(),
                  primaryColor.b.toInt(),
                  isDarkMode ? 0.1 : 0.05,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(Icons.event_outlined, size: 60, color: primaryColor),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get an illustration for empty guest list
  static Widget getEmptyGuestListIllustration(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  primaryColor.r.toInt(),
                  primaryColor.g.toInt(),
                  primaryColor.b.toInt(),
                  isDarkMode ? 0.1 : 0.05,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(Icons.people_outline, size: 60, color: primaryColor),
          ),
        ],
      ),
    );
  }

  /// Get an illustration for empty budget
  static Widget getEmptyBudgetIllustration(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  primaryColor.r.toInt(),
                  primaryColor.g.toInt(),
                  primaryColor.b.toInt(),
                  isDarkMode ? 0.1 : 0.05,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Get an illustration for empty timeline
  static Widget getEmptyTimelineIllustration(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  primaryColor.r.toInt(),
                  primaryColor.g.toInt(),
                  primaryColor.b.toInt(),
                  isDarkMode ? 0.1 : 0.05,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(child: Icon(Icons.checklist, size: 60, color: primaryColor)),
        ],
      ),
    );
  }

  /// Get an illustration for empty bookings
  static Widget getEmptyBookingsIllustration(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  primaryColor.r.toInt(),
                  primaryColor.g.toInt(),
                  primaryColor.b.toInt(),
                  isDarkMode ? 0.1 : 0.05,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
