import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';

class ServicesSelection extends StatelessWidget {
  final Map<String, bool> selectedServices;
  final Color primaryColor;
  final Function(String, bool?) onServiceChanged;

  const ServicesSelection({
    super.key,
    required this.selectedServices,
    required this.primaryColor,
    required this.onServiceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
      ),
      child: Column(
        children:
            selectedServices.keys.map((service) {
              return CheckboxListTile(
                title: Text(service),
                value: selectedServices[service],
                activeColor: primaryColor,
                onChanged: (value) => onServiceChanged(service, value),
              );
            }).toList(),
      ),
    );
  }
}
