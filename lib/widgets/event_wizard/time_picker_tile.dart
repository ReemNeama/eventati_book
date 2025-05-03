import 'package:flutter/material.dart';

class TimePickerTile extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final String label;
  final ValueChanged<TimeOfDay?> onTimeSelected;

  const TimePickerTile({
    super.key,
    required this.selectedTime,
    required this.label,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        selectedTime == null
            ? label
            : '$label: ${selectedTime?.format(context)}',
      ),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
        );
        onTimeSelected(time);
      },
    );
  }
}
