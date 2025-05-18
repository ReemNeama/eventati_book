import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/details/image_placeholder.dart';
import 'package:eventati_book/utils/image_utils.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// A widget that displays a network image with caching and loading states
class CachedNetworkImageWidget extends StatelessWidget {
  /// The URL of the image to display
  final String imageUrl;

  /// The width of the image
  final double? width;

  /// The height of the image
  final double? height;

  /// The border radius of the image
  final double borderRadius;

  /// The fit of the image
  final BoxFit fit;

  /// The placeholder widget to display while the image is loading
  final Widget? placeholder;

  /// The error widget to display if the image fails to load
  final Widget? errorWidget;

  /// Whether to show a loading indicator while the image is loading
  final bool showLoadingIndicator;

  /// The color of the loading indicator
  final Color? loadingIndicatorColor;

  /// The background color of the image
  final Color? backgroundColor;

  /// The icon to display in the placeholder
  final IconData placeholderIcon;

  /// The size of the icon in the placeholder
  final double placeholderIconSize;

  /// The color of the icon in the placeholder
  final Color? placeholderIconColor;

  /// The semantic label for the image
  final String? semanticLabel;

  /// Creates a CachedNetworkImageWidget
  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.showLoadingIndicator = true,
    this.loadingIndicatorColor,
    this.backgroundColor,
    this.placeholderIcon = Icons.image,
    this.placeholderIconSize = 50,
    this.placeholderIconColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultLoadingColor = theme.primaryColor;

    // Optimize the image URL
    final optimizedUrl = ImageUtils.getOptimizedUrl(
      imageUrl,
      width: width?.toInt(),
      height: height?.toInt(),
      quality: 85,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        optimizedUrl,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        // Use cacheWidth and cacheHeight for memory optimization
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return _buildLoadingWidget(
            context,
            loadingProgress,
            defaultLoadingColor,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              ImagePlaceholder(
                height: height ?? 200,
                width: width ?? double.infinity,
                borderRadius: borderRadius,
                icon: Icons.broken_image,
                iconSize: placeholderIconSize,
                backgroundColor: backgroundColor,
                iconColor: placeholderIconColor,
              );
        },
      ),
    );
  }

  /// Build the loading widget
  Widget _buildLoadingWidget(
    BuildContext context,
    ImageChunkEvent loadingProgress,
    Color defaultLoadingColor,
  ) {
    if (placeholder != null) {
      return placeholder!;
    }

    final totalBytes = loadingProgress.expectedTotalBytes;
    final loadedBytes = loadingProgress.cumulativeBytesLoaded;
    final progress = totalBytes != null ? loadedBytes / totalBytes : null;

    return Container(
      width: width,
      height: height,
      color: backgroundColor,
      child: Center(
        child:
            showLoadingIndicator
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      color: loadingIndicatorColor ?? defaultLoadingColor,
                    ),
                    if (progress != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyles.bodySmall,
                        ),
                      ),
                  ],
                )
                : ImagePlaceholder(
                  height: height ?? 200,
                  width: width ?? double.infinity,
                  borderRadius: borderRadius,
                  icon: placeholderIcon,
                  iconSize: placeholderIconSize,
                  backgroundColor: backgroundColor,
                  iconColor: placeholderIconColor,
                ),
      ),
    );
  }
}
