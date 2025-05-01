import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';

class GuestCountInput extends StatelessWidget {
  final Color primaryColor;
  final ValueChanged<String> onChanged;

  const GuestCountInput({
    super.key,
    required this.primaryColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Expected Number of Guests',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
      ),
      onChanged: onChanged,
      validator:
          (value) => ValidationUtils.validateNumber(
            value,
            message: 'Please enter a valid number of guests',
          ),
    );
  }
}
