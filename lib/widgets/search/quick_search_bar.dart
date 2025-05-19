import 'package:flutter/material.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/utils/utils.dart';

/// A search bar widget for quick access to search functionality
class QuickSearchBar extends StatelessWidget {
  /// Placeholder text to display in the search bar
  final String placeholder;

  /// Whether to show the search icon
  final bool showSearchIcon;

  /// Whether to show the filter icon
  final bool showFilterIcon;

  /// Callback when the search bar is tapped
  final VoidCallback? onTap;

  /// Background color of the search bar
  final Color? backgroundColor;

  /// Text color of the search bar
  final Color? textColor;

  /// Icon color of the search bar
  final Color? iconColor;

  /// Border radius of the search bar
  final double borderRadius;

  /// Constructor
  const QuickSearchBar({
    super.key,
    this.placeholder = 'Search...',
    this.showSearchIcon = true,
    this.showFilterIcon = false,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Default colors based on theme
    final bgColor =
        backgroundColor ??
        (isDarkMode
            ? const Color.fromRGBO(59, 29, 37, 0.3) // Dark brown color
            : const Color.fromRGBO(121, 85, 72, 0.1)); // Light brown color

    final txtColor =
        textColor ?? (isDarkMode ? Colors.white70 : AppColors.textSecondary);

    final icnColor =
        iconColor ?? (isDarkMode ? Colors.white70 : AppColors.textSecondary);

    return InkWell(
      onTap:
          onTap ??
          () {
            // Navigate to search screen
            NavigationUtils.navigateToNamed(context, RouteNames.globalSearch);
          },
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color:
                isDarkMode
                    ? const Color.fromRGBO(255, 255, 255, 0.1)
                    : const Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ),
        child: Row(
          children: [
            if (showSearchIcon) ...[
              Icon(Icons.search, color: icnColor, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                placeholder,
                style: TextStyle(color: txtColor, fontSize: 16),
              ),
            ),
            if (showFilterIcon) ...[
              const SizedBox(width: 12),
              Icon(Icons.filter_list, color: icnColor, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
