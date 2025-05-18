import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';

import 'package:eventati_book/styles/text_styles.dart';


class AuthTitleWidget extends StatelessWidget {
  final double fontSize;
  final String title;

  const AuthTitleWidget({super.key, this.fontSize = 40, this.title = ''});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.isEmpty ? AppConstants.appName : title,
      style: TextStyles.title.copyWith(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }
}
