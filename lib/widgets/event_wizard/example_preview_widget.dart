import 'package:flutter/material.dart';
import 'package:eventati_book/styles/text_styles.dart';
import 'package:eventati_book/utils/ui/ui_utils.dart';
import 'package:eventati_book/widgets/common/cached_network_image_widget.dart';

/// A widget that displays example images and descriptions for options
class ExamplePreviewWidget extends StatefulWidget {
  /// Title of the example
  final String title;

  /// Description of the example
  final String description;

  /// URL of the example image (can be asset or network)
  final String? imageUrl;

  /// Icon to display if no image is available
  final IconData? fallbackIcon;

  /// Whether the image is an asset (true) or network image (false)
  final bool isAssetImage;

  /// Whether the description is initially expanded
  final bool initiallyExpanded;

  /// Height of the image
  final double imageHeight;

  /// Border radius of the widget
  final double borderRadius;

  /// Creates an example preview widget
  const ExamplePreviewWidget({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.fallbackIcon,
    this.isAssetImage = true,
    this.initiallyExpanded = false,
    this.imageHeight = 150.0,
    this.borderRadius = 12.0,
  });

  @override
  State<ExamplePreviewWidget> createState() => _ExamplePreviewWidgetState();
}

class _ExamplePreviewWidgetState extends State<ExamplePreviewWidget> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = isDarkMode ? Colors.grey[850] : Colors.grey[100];
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image section
          if (widget.imageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.borderRadius),
                topRight: Radius.circular(widget.borderRadius),
              ),
              child:
                  widget.isAssetImage
                      ? Image.asset(
                        widget.imageUrl!,
                        height: widget.imageHeight,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackImage(primaryColor);
                        },
                      )
                      : CachedNetworkImageWidget(
                        imageUrl: widget.imageUrl!,
                        height: widget.imageHeight,
                        fit: BoxFit.cover,
                        borderRadius: widget.borderRadius,
                      ),
            ),
          ] else if (widget.fallbackIcon != null) ...[
            _buildFallbackImage(primaryColor),
          ],

          // Title and expand/collapse button
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyles.subtitle.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),

          // Description (expandable)
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0.0, 12.0, 12.0),
              child: Text(
                widget.description,
                style: TextStyles.bodyMedium.copyWith(
                  color: Color.fromRGBO(
                    textColor.r.toInt(),
                    textColor.g.toInt(),
                    textColor.b.toInt(),
                    0.8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFallbackImage(Color primaryColor) {
    return Container(
      height: widget.imageHeight,
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          primaryColor.r.toInt(),
          primaryColor.g.toInt(),
          primaryColor.b.toInt(),
          0.1,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.borderRadius),
          topRight: Radius.circular(widget.borderRadius),
        ),
      ),
      child: Center(
        child: Icon(
          widget.fallbackIcon ?? Icons.image,
          size: 50,
          color: primaryColor,
        ),
      ),
    );
  }
}
