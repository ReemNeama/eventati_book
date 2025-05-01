import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

class VendorListScreen extends StatelessWidget {
  final String eventId;
  final String eventName;

  const VendorListScreen({
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
        title: Text('Vendors for $eventName'),
        backgroundColor: primaryColor,
      ),
      body: const Center(
        child: Text('Vendor Communication Coming Soon'),
      ),
    );
  }
}
