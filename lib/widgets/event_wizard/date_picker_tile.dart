import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';

class DatePickerTile extends StatelessWidget {
  final DateTime? selectedDate;
  final Color primaryColor;
  final ValueChanged<DateTime?> onDateSelected;
  final String label;

  const DatePickerTile({
    super.key,
    required this.selectedDate,
    required this.primaryColor,
    required this.onDateSelected,
    this.label = 'Select Event Date',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.disabled),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListTile(
        title: Text(
          selectedDate == null
              ? label
              : 'Date: ${DateTimeUtils.formatDate(selectedDate as DateTime)}',
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                  ),
                ),
                // Use null-safe approach with null coalescing operator
                child: child ?? Container(),
              );
            },
          );
          onDateSelected(date);
        },
      ),
    );
  }
}
