import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';

class EventTypeDropdown extends StatelessWidget {
  final String? selectedValue;
  final List<String> eventTypes;
  final Color primaryColor;
  final ValueChanged<String?> onChanged;

  const EventTypeDropdown({
    super.key,
    required this.selectedValue,
    required this.eventTypes,
    required this.primaryColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Event Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
      ),
      value: selectedValue,
      items:
          eventTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
      onChanged: onChanged,
    );
  }
}
