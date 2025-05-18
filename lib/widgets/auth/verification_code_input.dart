import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';

class VerificationCodeInput extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String, int) onCodeChanged;

  const VerificationCodeInput({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 50,
          height: 60,
          child: TextFormField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            onChanged: (value) => onCodeChanged(value, index),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color.fromRGBO(255, 255, 255, 0.7),
                ),
                borderRadius: BorderRadius.circular(
                  AppConstants.mediumBorderRadius,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(
                  AppConstants.mediumBorderRadius,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
