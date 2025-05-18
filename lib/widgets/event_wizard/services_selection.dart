import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';

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
        border: Border.all(
          color: Color.fromRGBO(
            AppColors.disabled.r.toInt(),
            AppColors.disabled.g.toInt(),
            AppColors.disabled.b.toInt(),
            0.3,
          ),
        ),
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
