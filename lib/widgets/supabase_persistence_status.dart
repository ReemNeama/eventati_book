import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Widget to display the Supabase persistence status
class SupabasePersistenceStatus extends StatelessWidget {
  /// Creates a new Supabase persistence status widget
  const SupabasePersistenceStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final wizardProvider = Provider.of<WizardProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            wizardProvider.useSupabase
                ? Color.fromRGBO(AppColors.success.r.toInt(), AppColors.success.g.toInt(), AppColors.success.b.toInt(), 0.20) // 0.2 * 255 = 51
                : Color.fromRGBO(AppColors.disabled.r.toInt(), AppColors.disabled.g.toInt(), AppColors.disabled.b.toInt(), 0.20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            wizardProvider.useSupabase ? Icons.cloud_done : Icons.cloud_off,
            size: 16,
            color: wizardProvider.useSupabase ? AppColors.success : AppColors.disabled,
          ),
          const SizedBox(width: 4),
          Text(
            wizardProvider.useSupabase
                ? 'Supabase Sync On'
                : 'Local Storage Only',
            style: TextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
