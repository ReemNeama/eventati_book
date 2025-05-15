import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/details/image_placeholder.dart';

/// A single page in the onboarding flow
///
/// This widget represents a single page in the onboarding flow,
/// with a title, description, and image.
class OnboardingPage extends StatelessWidget {
  /// The title of the page
  final String title;

  /// The description of the page
  final String description;

  /// The image to display on the page
  final String image;

  /// The background color of the page
  final Color backgroundColor;

  /// Creates an OnboardingPage
  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(flex: 3, child: _buildImage(size)),

          const SizedBox(height: 32.0),

          // Title
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16.0),

          // Description
          Text(
            description,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Size size) {
    // Check if the image file exists
    // For now, we'll use a placeholder
    // In a real app, you would use an asset image or a network image
    return Center(
      child: ImagePlaceholder(
        height: size.height * 0.3,
        width: size.width * 0.8,
        borderRadius: 16.0,
        icon: Icons.image,
        iconSize: 80,
      ),
    );

    // When you have actual images, use this instead:
    // return Image.asset(
    //   image,
    //   height: size.height * 0.3,
    //   width: size.width * 0.8,
    //   fit: BoxFit.contain,
    // );
  }
}
