import 'package:flutter/material.dart';
import 'package:eventati_book/screens/settings/notification_settings_screen.dart';
import 'package:eventati_book/screens/settings/pending_shares_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// Screen for app settings
class SettingsScreen extends StatelessWidget {
  /// Constructor
  const SettingsScreen({super.key});

  /// Show an info snackbar
  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection(context, 'Account', [
            _buildListTile(context, 'Profile', Icons.person, () {
              // Navigate to profile screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile settings not implemented yet'),
                  backgroundColor: AppColors.primary,
                ),
              );
            }),
            _buildListTile(context, 'Change Password', Icons.lock, () {
              // Navigate to change password screen
              _showInfoSnackBar(context, 'Change password not implemented yet');
            }),
            _buildListTile(context, 'Sign Out', Icons.exit_to_app, () async {
              // Sign out
              await Supabase.instance.client.auth.signOut();
              // Navigate to login screen
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            }),
          ]),
          _buildSection(context, 'Notifications', [
            _buildListTile(
              context,
              'Notification Settings',
              Icons.notifications,
              () {
                // Navigate to notification settings screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
          ]),
          _buildSection(context, 'Sharing', [
            _buildListTile(context, 'Pending Shares', Icons.share, () {
              // Navigate to pending shares screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PendingSharesScreen(),
                ),
              );
            }),
          ]),
          _buildSection(context, 'Appearance', [
            _buildListTile(context, 'Theme', Icons.color_lens, () {
              // Navigate to theme settings screen
              _showInfoSnackBar(context, 'Theme settings not implemented yet');
            }),
            _buildListTile(context, 'Language', Icons.language, () {
              // Navigate to language settings screen
              _showInfoSnackBar(
                context,
                'Language settings not implemented yet',
              );
            }),
          ]),
          _buildSection(context, 'About', [
            _buildListTile(context, 'About Eventati Book', Icons.info, () {
              // Navigate to about screen
              _showInfoSnackBar(context, 'About screen not implemented yet');
            }),
            _buildListTile(context, 'Privacy Policy', Icons.privacy_tip, () {
              // Navigate to privacy policy screen
              _showInfoSnackBar(context, 'Privacy policy not implemented yet');
            }),
            _buildListTile(context, 'Terms of Service', Icons.description, () {
              // Navigate to terms of service screen
              _showInfoSnackBar(
                context,
                'Terms of service not implemented yet',
              );
            }),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
