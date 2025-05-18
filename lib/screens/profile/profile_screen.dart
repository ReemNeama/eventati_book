import 'package:flutter/material.dart';
import 'package:eventati_book/providers/providers.dart';
import 'package:eventati_book/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/routing/routing.dart';
import 'package:eventati_book/screens/profile/edit_profile_screen.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Profile screen that displays user information and settings
class ProfileScreen extends StatelessWidget {
  final Function toggleTheme;

  const ProfileScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;

          if (user == null) {
            return const Center(child: Text('No user is logged in'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Center(
                  child: Column(
                    children: [
                      user.profileImageUrl != null
                          ? ClipOval(
                            child: CachedNetworkImageWidget(
                              imageUrl: user.profileImageUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholderIcon: Icons.person,
                              backgroundColor: theme.primaryColor.withAlpha(50),
                              placeholderIconColor: theme.primaryColor,
                              semanticLabel: 'Profile image for ${user.name}',
                            ),
                          )
                          : CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.primaryColor.withAlpha(50),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: theme.primaryColor,
                            ),
                          ),
                      const SizedBox(height: 16),
                      Text(user.name, style: TextStyles.title),
                      const SizedBox(height: 4),
                      Text(user.email, style: TextStyles.bodyLarge),
                      if (!user.emailVerified && user.authProvider == 'email')
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                RouteNames.verification,
                                arguments: VerificationArguments(
                                  email: user.email,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.warning,
                              color: AppColors.warning,
                            ),
                            label: const Text(
                              'Verify Email',
                              style: TextStyle(color: AppColors.warning),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Settings section
                Text('Settings', style: TextStyles.sectionTitle),
                const SizedBox(height: 8),
                _buildSettingItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {
                    // Navigate to notification settings screen
                    Navigator.pushNamed(context, RouteNames.notifications);
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  title: isDarkMode ? 'Light Mode' : 'Dark Mode',
                  onTap: () {
                    toggleTheme();
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.language,
                  title: 'Language',
                  onTap: () {
                    // Navigate to language settings
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.fingerprint,
                  title: 'Biometric Authentication',
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.biometricSettings);
                  },
                ),

                const SizedBox(height: 24),

                // Account section
                Text('Account', style: TextStyles.sectionTitle),
                const SizedBox(height: 8),
                _buildSettingItem(
                  context,
                  icon: Icons.compare_arrows,
                  title: 'Saved Comparisons',
                  onTap: () {
                    Navigator.pushNamed(context, '/comparisons/saved');
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    // Navigate to help & support
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.security,
                  title: 'Feature Guards Demo',
                  onTap: () {
                    Navigator.pushNamed(context, '/demo/feature-guard');
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.speed,
                  title: 'Route Performance',
                  onTap: () {
                    Navigator.pushNamed(context, '/demo/route-performance');
                  },
                ),
                _buildSettingItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: AppColors.error,
                  onTap: () {
                    _showLogoutConfirmationDialog(context, authProvider);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _showLogoutConfirmationDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  authProvider.logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
