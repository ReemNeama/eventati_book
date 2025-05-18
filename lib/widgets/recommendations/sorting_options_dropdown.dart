import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/utils/utils.dart';


/// A dropdown for selecting sorting options
class SortingOptionsDropdown extends StatelessWidget {
  /// The available sorting options
  final List<String> options;

  /// The currently selected option
  final String selectedOption;

  /// Callback when an option is selected
  final Function(String) onOptionSelected;

  /// Creates a new sorting options dropdown
  const SortingOptionsDropdown({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor.withAlpha(128)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButton<String>(
        value: selectedOption,
        icon: Icon(Icons.arrow_drop_down, color: primaryColor),
        iconSize: 24,
        elevation: 16,
        style: TextStyle(color: textColor),
        underline: const SizedBox(), // Remove the default underline
        onChanged: (String? newValue) {
          if (newValue != null) {
            onOptionSelected(newValue);
          }
        },
        items:
            options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }
}
