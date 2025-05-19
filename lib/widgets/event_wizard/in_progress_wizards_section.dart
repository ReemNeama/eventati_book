import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/screens/event_wizard/wizard_factory.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/widgets/common/empty_state.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/event_wizard/in_progress_wizard_card.dart';

/// A section displaying in-progress wizards that can be continued
class InProgressWizardsSection extends StatefulWidget {
  /// Constructor
  const InProgressWizardsSection({super.key});

  @override
  State<InProgressWizardsSection> createState() =>
      _InProgressWizardsSectionState();
}

class _InProgressWizardsSectionState extends State<InProgressWizardsSection> {
  late Future<List<WizardState>> _inProgressWizardsFuture;

  @override
  void initState() {
    super.initState();
    _loadInProgressWizards();
  }

  void _loadInProgressWizards() {
    final wizardProvider = Provider.of<WizardProvider>(context, listen: false);

    // Initialize with user ID for Supabase persistence
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      wizardProvider.initializeWithIds(
        authProvider.currentUser!.id,
        'temp', // Temporary event ID, will be replaced when resuming
      );
    }

    _inProgressWizardsFuture = wizardProvider.getInProgressWizards();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WizardState>>(
      future: _inProgressWizardsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: LoadingIndicator(size: 30)),
          );
        }

        if (snapshot.hasError) {
          return EmptyState.error(
            message: 'Error loading saved events',
            displayType: EmptyStateDisplayType.compact,
          );
        }

        final inProgressWizards = snapshot.data ?? [];
        if (inProgressWizards.isEmpty) {
          return const SizedBox.shrink(); // No in-progress wizards
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Continue Creating',
                style: TextStyles.sectionTitle.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: inProgressWizards.length,
              itemBuilder: (context, index) {
                final wizard = inProgressWizards[index];
                return InProgressWizardCard(
                  wizard: wizard,
                  onContinue: () => _resumeWizard(wizard),
                  onDelete: () => _deleteWizard(wizard),
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.white30,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Start a New Event',
                style: TextStyles.sectionTitle.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  void _resumeWizard(WizardState wizard) {
    // Create a new WizardProvider with the saved state
    final wizardProvider = WizardProvider();

    // Initialize with user ID for Supabase persistence
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      wizardProvider.initializeWithIds(
        authProvider.currentUser!.id,
        wizard.template.id,
      );
    }

    // Navigate to the wizard screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChangeNotifierProvider.value(
              value: wizardProvider,
              child: WizardFactory.createWizardScreen(
                context,
                wizard.template.id,
              ),
            ),
      ),
    ).then((_) {
      // Refresh the list when returning from the wizard
      setState(() {
        _loadInProgressWizards();
      });
    });
  }

  void _deleteWizard(WizardState wizard) async {
    final wizardProvider = Provider.of<WizardProvider>(context, listen: false);

    // Initialize with user ID for Supabase persistence
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      wizardProvider.initializeWithIds(
        authProvider.currentUser!.id,
        wizard.template.id,
      );
    }

    // Clear the wizard
    await wizardProvider.clearWizard();

    // Refresh the list
    setState(() {
      _loadInProgressWizards();
    });

    // Show a snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
