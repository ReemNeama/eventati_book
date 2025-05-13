import 'package:eventati_book/models/notification_models/notification_settings.dart';
import 'package:eventati_book/models/notification_models/notification_topic.dart';
import 'package:eventati_book/services/notification/messaging_service.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen for managing notification preferences
class NotificationPreferencesScreen extends StatefulWidget {
  /// Constructor
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final MessagingService _messagingService = MessagingService();

  NotificationSettings? _settings;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load notification settings
  Future<void> _loadSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Get notification settings from database
      final response =
          await _supabase
              .from('user_notification_settings')
              .select()
              .eq('user_id', user.id)
              .maybeSingle();

      // Create settings from response or use default settings
      final settings = NotificationSettings.fromDatabaseDoc(response);

      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      Logger.e(
        'Error loading notification settings: $e',
        tag: 'NotificationPreferencesScreen',
      );
      setState(() {
        _errorMessage = 'Failed to load notification settings';
        _isLoading = false;
      });
    }
  }

  /// Save notification settings
  Future<void> _saveSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      if (_settings == null) {
        throw Exception('Settings not initialized');
      }

      // Update notification settings in database
      await _supabase.from('user_notification_settings').upsert({
        'user_id': user.id,
        ..._settings!.toDatabaseDoc(),
      });

      // Update messaging service settings
      await _messagingService.updateNotificationSettings({
        'allNotificationsEnabled': _settings!.allNotificationsEnabled,
        'pushNotificationsEnabled': _settings!.pushNotificationsEnabled,
        'emailNotificationsEnabled': _settings!.emailNotificationsEnabled,
        'inAppNotificationsEnabled': _settings!.inAppNotificationsEnabled,
      });

      // Subscribe or unsubscribe from topics
      for (final entry in _settings!.topicSettings.entries) {
        final topicId = entry.key;
        final isEnabled = entry.value;

        if (isEnabled) {
          await _messagingService.subscribeToTopic(topicId);
        } else {
          await _messagingService.unsubscribeFromTopic(topicId);
        }
      }

      if (mounted) {
        UIUtils.showSuccessSnackBar(context, 'Notification settings saved');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      Logger.e(
        'Error saving notification settings: $e',
        tag: 'NotificationPreferencesScreen',
      );
      setState(() {
        _errorMessage = 'Failed to save notification settings';
        _isLoading = false;
      });

      if (mounted) {
        UIUtils.showErrorSnackBar(
          context,
          'Failed to save notification settings',
        );
      }
    }
  }

  /// Update all notifications enabled setting
  void _updateAllNotificationsEnabled(bool value) {
    setState(() {
      _settings = _settings!.copyWith(allNotificationsEnabled: value);
    });
  }

  /// Update push notifications enabled setting
  void _updatePushNotificationsEnabled(bool value) {
    setState(() {
      _settings = _settings!.copyWith(pushNotificationsEnabled: value);
    });
  }

  /// Update email notifications enabled setting
  void _updateEmailNotificationsEnabled(bool value) {
    setState(() {
      _settings = _settings!.copyWith(emailNotificationsEnabled: value);
    });
  }

  /// Update in-app notifications enabled setting
  void _updateInAppNotificationsEnabled(bool value) {
    setState(() {
      _settings = _settings!.copyWith(inAppNotificationsEnabled: value);
    });
  }

  /// Update topic setting
  void _updateTopicSetting(String topicId, bool value) {
    setState(() {
      _settings = _settings!.updateTopicSetting(topicId, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        backgroundColor: primaryColor,
        actions: [
          if (!_isLoading && _settings != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
              tooltip: 'Save Settings',
            ),
        ],
      ),
      body:
          _isLoading
              ? const LoadingIndicator(
                message: 'Loading notification settings...',
              )
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: TextStyles.error))
              : _settings == null
              ? const Center(child: Text('No notification settings available'))
              : _buildSettingsForm(),
    );
  }

  /// Build the settings form
  Widget _buildSettingsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMasterToggle(),
          const Divider(),
          _buildChannelToggles(),
          const Divider(),
          _buildTopicToggles(),
        ],
      ),
    );
  }

  /// Build the master toggle
  Widget _buildMasterToggle() {
    return SwitchListTile(
      title: const Text('Enable All Notifications'),
      subtitle: const Text(
        'Turn on or off all notifications. Individual settings will be preserved.',
      ),
      value: _settings!.allNotificationsEnabled,
      onChanged: _updateAllNotificationsEnabled,
    );
  }

  /// Build the channel toggles
  Widget _buildChannelToggles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Notification Channels',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SwitchListTile(
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive notifications on your device'),
          value: _settings!.pushNotificationsEnabled,
          onChanged:
              _settings!.allNotificationsEnabled
                  ? _updatePushNotificationsEnabled
                  : null,
        ),
        SwitchListTile(
          title: const Text('Email Notifications'),
          subtitle: const Text('Receive notifications via email'),
          value: _settings!.emailNotificationsEnabled,
          onChanged:
              _settings!.allNotificationsEnabled
                  ? _updateEmailNotificationsEnabled
                  : null,
        ),
        SwitchListTile(
          title: const Text('In-App Notifications'),
          subtitle: const Text('Receive notifications within the app'),
          value: _settings!.inAppNotificationsEnabled,
          onChanged:
              _settings!.allNotificationsEnabled
                  ? _updateInAppNotificationsEnabled
                  : null,
        ),
      ],
    );
  }

  /// Build the topic toggles
  Widget _buildTopicToggles() {
    // Group topics by category
    final Map<NotificationTopicCategory, List<NotificationTopic>>
    groupedTopics = {};

    for (final topic in NotificationTopics.all) {
      if (!groupedTopics.containsKey(topic.category)) {
        groupedTopics[topic.category] = [];
      }
      groupedTopics[topic.category]!.add(topic);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Notification Types',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...groupedTopics.entries.map((entry) {
          final category = entry.key;
          final topics = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  _getCategoryDisplayName(category),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              ...topics.map((topic) {
                final isEnabled =
                    _settings!.topicSettings[topic.id] ?? topic.defaultEnabled;

                return SwitchListTile(
                  title: Text(topic.name),
                  subtitle: Text(topic.description),
                  value: isEnabled,
                  onChanged:
                      _settings!.allNotificationsEnabled
                          ? (value) => _updateTopicSetting(topic.id, value)
                          : null,
                );
              }),
              const SizedBox(height: 8),
            ],
          );
        }),
      ],
    );
  }

  /// Get the display name for a notification topic category
  String _getCategoryDisplayName(NotificationTopicCategory category) {
    switch (category) {
      case NotificationTopicCategory.eventType:
        return 'Event Types';
      case NotificationTopicCategory.feature:
        return 'Features';
      case NotificationTopicCategory.marketing:
        return 'Marketing';
      case NotificationTopicCategory.system:
        return 'System';
    }
  }
}
