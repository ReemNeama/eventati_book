import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/screens/event_wizard/wizard_factory.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/text_styles.dart';


class EventSelectionScreen extends StatefulWidget {
  const EventSelectionScreen({super.key});

  @override
  State<EventSelectionScreen> createState() => _EventSelectionScreenState();
}

class _EventSelectionScreenState extends State<EventSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: Text(AppConstants.appName, style: TextStyles.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'What type of event are\nyou planning?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            _buildEventButton(
              title: 'Business Event',
              onPressed: () {
                // Initialize the wizard provider
                Provider.of<WizardProvider>(
                  context,
                  listen: false,
                ).resetWizard();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChangeNotifierProvider(
                          create: (_) => WizardProvider(),
                          child: WizardFactory.createWizardScreen(
                            context,
                            'business',
                          ),
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildEventButton(
              title: 'Wedding/Engagement',
              onPressed: () {
                // Initialize the wizard provider
                Provider.of<WizardProvider>(
                  context,
                  listen: false,
                ).resetWizard();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChangeNotifierProvider(
                          create: (_) => WizardProvider(),
                          child: WizardFactory.createWizardScreen(
                            context,
                            'wedding',
                          ),
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildEventButton(
              title: 'Celebration',
              onPressed: () {
                // Initialize the wizard provider
                Provider.of<WizardProvider>(
                  context,
                  listen: false,
                ).resetWizard();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ChangeNotifierProvider(
                          create: (_) => WizardProvider(),
                          child: WizardFactory.createWizardScreen(
                            context,
                            'celebration',
                          ),
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventButton({
    required String title,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        ),
        backgroundColor: WidgetStateProperty.all(Colors.white),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyles.sectionTitle.copyWith(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
