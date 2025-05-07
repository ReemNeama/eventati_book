import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';

/// Widget to display the Firebase persistence status
class FirebasePersistenceStatus extends StatelessWidget {
  /// Creates a new Firebase persistence status widget
  const FirebasePersistenceStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wizardProvider = Provider.of<WizardProvider>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: wizardProvider.useFirebase
            ? Colors.green.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            wizardProvider.useFirebase
                ? Icons.cloud_done
                : Icons.cloud_off,
            size: 16,
            color: wizardProvider.useFirebase ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            wizardProvider.useFirebase
                ? 'Firebase Sync On'
                : 'Local Storage Only',
            style: TextStyle(
              fontSize: 12,
              color: wizardProvider.useFirebase ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
