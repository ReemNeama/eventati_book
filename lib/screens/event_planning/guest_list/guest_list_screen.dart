import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

class GuestListScreen extends StatelessWidget {
  final String eventId;
  final String eventName;

  const GuestListScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Guest List for $eventName'),
        backgroundColor: primaryColor,
      ),
      body: const Center(
        child: Text('Guest List Management Coming Soon'),
      ),
    );
  }
}
