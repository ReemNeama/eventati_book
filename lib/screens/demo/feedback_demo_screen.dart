import 'package:flutter/material.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/widgets/widgets.dart';

/// A demo screen to showcase all feedback mechanisms
class FeedbackDemoScreen extends StatefulWidget {
  /// Creates a FeedbackDemoScreen
  const FeedbackDemoScreen({super.key});

  @override
  State<FeedbackDemoScreen> createState() => _FeedbackDemoScreenState();
}

class _FeedbackDemoScreenState extends State<FeedbackDemoScreen> {
  bool _isLoading = false;
  double _progress = 0.0;
  OverlayEntry? _loadingOverlay;

  @override
  void dispose() {
    _loadingOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback Mechanisms Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Loading Indicators'),
            _buildLoadingIndicatorsSection(),
            const SizedBox(height: 24),

            _buildSectionTitle('Toast Messages'),
            _buildToastMessagesSection(),
            const SizedBox(height: 24),

            _buildSectionTitle('Haptic Feedback'),
            _buildHapticFeedbackSection(),
            const SizedBox(height: 24),

            _buildSectionTitle('Progress Indicators'),
            _buildProgressIndicatorsSection(),
            const SizedBox(height: 24),

            _buildSectionTitle('Animations'),
            _buildAnimationsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: TextStyles.title),
    );
  }

  Widget _buildLoadingIndicatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Standard loading indicator
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Standard Loading Indicator', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                const Center(
                  child: LoadingIndicator(message: 'Loading data...'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Async button
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Async Button', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: AsyncButton(
                    text: 'Load Data',
                    onPressed: () async {
                      // Simulate loading
                      await Future.delayed(const Duration(seconds: 2));
                    },
                    showSuccessMessage: true,
                    successMessage: 'Data loaded successfully!',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Loading overlay
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loading Overlay', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () async {
                              setState(() {
                                _isLoading = true;
                              });

                              // Show loading overlay
                              _loadingOverlay =
                                  FeedbackUtils.showLoadingOverlay(
                                    context,
                                    message: 'Loading data...',
                                    dismissible: true,
                                    onDismiss: () {
                                      _loadingOverlay?.remove();
                                      _loadingOverlay = null;
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    },
                                  );

                              // Simulate loading
                              await Future.delayed(const Duration(seconds: 5));

                              // Remove loading overlay
                              _loadingOverlay?.remove();
                              _loadingOverlay = null;

                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                    child: const Text('Show Loading Overlay'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToastMessagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success toast
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Success Toast', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ToastMessage.show(
                        context,
                        message: 'Operation completed successfully!',
                        type: ToastType.success,
                      );
                    },
                    child: const Text('Show Success Toast'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Error toast
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error Toast', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ToastMessage.show(
                        context,
                        message: 'An error occurred. Please try again.',
                        type: ToastType.error,
                      );
                    },
                    child: const Text('Show Error Toast'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Info toast
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Info Toast', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ToastMessage.show(
                        context,
                        message: 'New updates are available!',
                        type: ToastType.info,
                        actionText: 'Update',
                        onAction: () {
                          // Handle update action
                        },
                      );
                    },
                    child: const Text('Show Info Toast'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHapticFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Light haptic feedback
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Light Haptic Feedback', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      FeedbackUtils.addHapticFeedback(HapticFeedbackType.light);
                    },
                    child: const Text('Light Impact'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Medium haptic feedback
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Medium Haptic Feedback', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      FeedbackUtils.addHapticFeedback(
                        HapticFeedbackType.medium,
                      );
                    },
                    child: const Text('Medium Impact'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Heavy haptic feedback
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Heavy Haptic Feedback', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      FeedbackUtils.addHapticFeedback(HapticFeedbackType.heavy);
                    },
                    child: const Text('Heavy Impact'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linear progress indicator
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Linear Progress Indicator', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                ProgressIndicatorWidget(
                  progress: _progress,
                  message: 'Uploading file...',
                  type: ProgressIndicatorType.linear,
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _simulateProgress();
                    },
                    child: const Text('Simulate Progress'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Circular progress indicator
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Circular Progress Indicator', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: ProgressIndicatorWidget(
                    progress: _progress,
                    message: 'Processing data...',
                    type: ProgressIndicatorType.circular,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stepped progress indicator
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Stepped Progress Indicator', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                ProgressIndicatorWidget(
                  currentStep: (_progress * 5).floor(),
                  steps: 5,
                  message: 'Step ${(_progress * 5).floor() + 1} of 5',
                  type: ProgressIndicatorType.stepped,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fade in animation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fade In Animation', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: AnimationUtils.applyAnimation(
                    Container(
                      width: 100,
                      height: 100,
                      color: AppColors.primary,
                    ),
                    type: AnimationType.fadeIn,
                    duration: const Duration(seconds: 2),
                    repeat: true,
                    reverse: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Slide up animation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Slide Up Animation', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: AnimationUtils.applyAnimation(
                    Container(
                      width: 100,
                      height: 100,
                      color: AppColors.primary,
                    ),
                    type: AnimationType.slideUp,
                    duration: const Duration(seconds: 2),
                    repeat: true,
                    reverse: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Pulse animation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pulse Animation', style: TextStyles.subtitle),
                const SizedBox(height: 16),
                Center(
                  child: AnimationUtils.applyAnimation(
                    Container(
                      width: 100,
                      height: 100,
                      color: AppColors.success,
                    ),
                    type: AnimationType.pulse,
                    duration: const Duration(seconds: 1),
                    repeat: true,
                    reverse: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _simulateProgress() async {
    setState(() {
      _progress = 0.0;
    });

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _progress = i / 10;
        });
      }
    }
  }
}
