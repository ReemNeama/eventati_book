import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/providers/core_providers/accessibility_provider.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/widgets/common/loading_indicator.dart';

/// Screen for managing accessibility settings
class AccessibilitySettingsScreen extends StatefulWidget {
  /// Constructor
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends State<AccessibilitySettingsScreen> {
  /// Text scale factor slider value
  double _textScaleFactorSliderValue = 1.0;

  @override
  void initState() {
    super.initState();
    // Initialize slider value from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<AccessibilityProvider>(
          context,
          listen: false,
        );
        setState(() {
          _textScaleFactorSliderValue = provider.textScaleFactor;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
        backgroundColor: primaryColor,
      ),
      body: Consumer<AccessibilityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator(
              message: 'Loading accessibility settings...',
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text('Error: ${provider.error}', style: TextStyles.error),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Text Size'),
                _buildTextSizeSection(provider),
                const Divider(),
                _buildSectionTitle('Display'),
                _buildDisplaySection(provider),
                const Divider(),
                _buildSectionTitle('Interaction'),
                _buildInteractionSection(provider),
                const Divider(),
                _buildResetButton(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build the section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: TextStyles.sectionTitle),
    );
  }

  /// Build the text size section
  Widget _buildTextSizeSection(AccessibilityProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Use System Text Size'),
          subtitle: const Text('Use the text size settings from your device'),
          value: provider.useSystemTextScale,
          onChanged: (value) {
            provider.toggleUseSystemTextScale(value);
          },
        ),
        if (!provider.useSystemTextScale) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('A', style: TextStyle(fontSize: 14)),
                Text(
                  'Text Size: ${(_textScaleFactorSliderValue * 100).toInt()}%',
                  style: TextStyles.bodyMedium,
                ),
                const Text('A', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
          Slider(
            value: _textScaleFactorSliderValue,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            onChanged: (value) {
              setState(() {
                _textScaleFactorSliderValue = value;
              });
            },
            onChangeEnd: (value) {
              provider.updateTextScaleFactor(value);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Sample Text',
              style: TextStyles.bodyMedium.copyWith(
                fontSize:
                    TextStyles.bodyMedium.fontSize! *
                    _textScaleFactorSliderValue,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build the display section
  Widget _buildDisplaySection(AccessibilityProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('High Contrast Mode'),
          subtitle: const Text('Increase contrast for better readability'),
          value: provider.highContrastEnabled,
          onChanged: (value) {
            provider.toggleHighContrastMode(value);
          },
        ),
        SwitchListTile(
          title: const Text('Reduce Animations'),
          subtitle: const Text('Minimize motion effects throughout the app'),
          value: provider.reduceAnimations,
          onChanged: (value) {
            provider.toggleReduceAnimations(value);
          },
        ),
      ],
    );
  }

  /// Build the interaction section
  Widget _buildInteractionSection(AccessibilityProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Haptic Feedback'),
          subtitle: const Text('Enable vibration feedback for interactions'),
          value: provider.enableHapticFeedback,
          onChanged: (value) {
            provider.toggleHapticFeedback(value);
          },
        ),
      ],
    );
  }

  /// Build the reset button
  Widget _buildResetButton(AccessibilityProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ElevatedButton(
          onPressed: () {
            provider.resetToDefaults();
            setState(() {
              _textScaleFactorSliderValue = 1.0;
            });
          },
          child: const Text('Reset to Defaults'),
        ),
      ),
    );
  }
}
