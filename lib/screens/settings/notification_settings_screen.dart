import 'package:flutter/material.dart';
import 'package:eventati_book/models/notification_models/notification_settings.dart';
import 'package:eventati_book/models/notification_models/notification_topic.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventati_book/styles/app_colors.dart';

import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Screen for managing notification settings
class NotificationSettingsScreen extends StatefulWidget {
  /// Constructor
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  /// Loading state
  bool _isLoading = true;

  /// Error message
  String? _errorMessage;

  /// User notification settings
  NotificationSettings? _settings;

  // Supabase client is used for authentication and database access

  /// Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load user notification settings
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final response =
          await _supabase
              .from('user_notification_settings')
              .select()
              .eq('user_id', user.id)
              .single();

      setState(() {
        try {
          final data = Map<String, dynamic>.from(response);
          _settings = NotificationSettings.fromDatabaseDoc(data);
        } catch (e) {
          _settings = NotificationSettings.defaultSettings();
        }
        _isLoading = false;
      });
    } catch (e) {
      Logger.e(
        'Error loading notification settings: $e',
        tag: 'NotificationSettingsScreen',
      );
      setState(() {
        _errorMessage = 'Failed to load notification settings';
        _settings = NotificationSettings.defaultSettings();
        _isLoading = false;
      });
    }
  }

  /// Save user notification settings
  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      if (_settings == null) {
        throw Exception('Settings not initialized');
      }

      await _supabase.from('user_notification_settings').upsert({
        'user_id': user.id,
        ..._settings!.toDatabaseDoc(),
      });

      if (mounted) {
        UIUtils.showSuccessSnackBar(context, 'Notification settings saved');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.e(
        'Error saving notification settings: $e',
        tag: 'NotificationSettingsScreen',
      );
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save notification settings';
          _isLoading = false;
        });

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          if (!_isLoading && _settings != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
              tooltip: 'Save Settings',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSettings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_settings == null) {
      return const Center(child: Text('No notification settings available'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMainToggle(),
        const Divider(),
        _buildChannelToggles(),
        const Divider(),
        _buildTopicSection('Event Types', NotificationTopicCategory.eventType),
        const Divider(),
        _buildTopicSection('Features', NotificationTopicCategory.feature),
        const Divider(),
        _buildTopicSection('Marketing', NotificationTopicCategory.marketing),
        const Divider(),
        _buildTopicSection('System', NotificationTopicCategory.system),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _saveSettings,
          child: const Text('Save Settings'),
        ),
      ],
    );
  }

  Widget _buildMainToggle() {
    return SwitchListTile(
      title: const Text(
        'Enable All Notifications',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('Turn on/off all notifications at once'),
      value: _settings!.allNotificationsEnabled,
      onChanged: _updateAllNotificationsEnabled,
    );
  }

  Widget _buildChannelToggles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Notification Channels',
            style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildTopicSection(String title, NotificationTopicCategory category) {
    final topics = NotificationTopics.getByCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...topics.map((topic) => _buildTopicTile(topic)),
      ],
    );
  }

  Widget _buildTopicTile(NotificationTopic topic) {
    return SwitchListTile(
      title: Text(topic.name),
      subtitle: Text(topic.description),
      value: _settings!.isTopicEnabled(topic.id),
      onChanged:
          _settings!.allNotificationsEnabled
              ? (value) => _updateTopicSetting(topic.id, value)
              : null,
    );
  }
}
