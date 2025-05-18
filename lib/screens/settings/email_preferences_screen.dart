import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/services/notification/email_preferences_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:eventati_book/widgets/common/error_display.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Screen for managing email preferences
class EmailPreferencesScreen extends StatefulWidget {
  /// Constructor
  const EmailPreferencesScreen({super.key});

  @override
  State<EmailPreferencesScreen> createState() => _EmailPreferencesScreenState();
}

class _EmailPreferencesScreenState extends State<EmailPreferencesScreen> {
  @override
  void initState() {
    super.initState();
    // Track screen view
    Posthog().screen(screenName: 'Email Preferences Screen');

    // Initialize provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmailPreferencesProvider>(
        context,
        listen: false,
      ).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Preferences'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<EmailPreferencesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: ErrorDisplay(
                message: provider.errorMessage!,
                onRetry: () => provider.initialize(),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage your email preferences',
                  style: TextStyles.sectionTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose which types of emails you want to receive from Eventati Book.',
                  style: TextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),
                _buildPreferenceSection(
                  title: 'Booking Notifications',
                  children: [
                    _buildPreferenceSwitch(
                      title: 'Booking Confirmations',
                      subtitle: 'Receive emails when you make a new booking',
                      value: provider.receiveBookingConfirmations,
                      onChanged:
                          (value) => _updatePreference(
                            EmailType.bookingConfirmation,
                            value,
                          ),
                    ),
                    _buildPreferenceSwitch(
                      title: 'Booking Updates',
                      subtitle: 'Receive emails when your bookings are updated',
                      value: provider.receiveBookingUpdates,
                      onChanged:
                          (value) =>
                              _updatePreference(EmailType.bookingUpdate, value),
                    ),
                    _buildPreferenceSwitch(
                      title: 'Booking Reminders',
                      subtitle: 'Receive reminder emails before your bookings',
                      value: provider.receiveBookingReminders,
                      onChanged:
                          (value) => _updatePreference(
                            EmailType.bookingReminder,
                            value,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPreferenceSection(
                  title: 'Marketing & Recommendations',
                  children: [
                    _buildPreferenceSwitch(
                      title: 'Promotional Emails',
                      subtitle: 'Receive special offers and promotions',
                      value: provider.receivePromotionalEmails,
                      onChanged:
                          (value) =>
                              _updatePreference(EmailType.promotional, value),
                    ),
                    _buildPreferenceSwitch(
                      title: 'Newsletters',
                      subtitle: 'Receive our monthly newsletter',
                      value: provider.receiveNewsletters,
                      onChanged:
                          (value) =>
                              _updatePreference(EmailType.newsletter, value),
                    ),
                    _buildPreferenceSwitch(
                      title: 'Recommendations',
                      subtitle: 'Receive personalized vendor recommendations',
                      value: provider.receiveRecommendations,
                      onChanged:
                          (value) => _updatePreference(
                            EmailType.recommendation,
                            value,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPreferenceSection(
                  title: 'Account Emails',
                  children: [
                    _buildPreferenceSwitch(
                      title: 'Account Notifications',
                      subtitle:
                          'Important account-related emails (cannot be disabled)',
                      value: provider.receiveAccountEmails,
                      onChanged: null, // Cannot be changed
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Note: You will always receive important account-related emails such as password resets and security notifications.',
                  style: TextStyles.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreferenceSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildPreferenceSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyles.bodySmall),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Future<void> _updatePreference(EmailType type, bool value) async {
    await Provider.of<EmailPreferencesProvider>(
      context,
      listen: false,
    ).updatePreference(type, value);
  }
}
