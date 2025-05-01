import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isWhiteBackground;

  const AuthButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isWhiteBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        minimumSize: WidgetStateProperty.all(const Size(200, 40)),
        backgroundColor: WidgetStateProperty.all(
          isWhiteBackground ? Colors.white : Theme.of(context).primaryColor,
        ),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color:
              isWhiteBackground ? Theme.of(context).primaryColor : Colors.white,
        ),
      ),
    );
  }
}
