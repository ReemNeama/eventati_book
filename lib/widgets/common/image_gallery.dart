import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/common/cached_network_image_widget.dart';
import 'package:eventati_book/widgets/details/image_placeholder.dart';

/// A widget that displays a gallery of images
class ImageGallery extends StatefulWidget {
  /// List of image URLs to display
  final List<String> imageUrls;

  /// Height of the gallery
  final double height;

  /// Width of the gallery
  final double width;

  /// Border radius of the gallery items
  final double borderRadius;

  /// Spacing between gallery items
  final double spacing;

  /// Padding around the gallery
  final EdgeInsetsGeometry padding;

  /// Background color of the gallery
  final Color? backgroundColor;

  /// Whether to show the full screen viewer when an image is tapped
  final bool enableFullScreen;

  /// Placeholder widget to display when there are no images
  final Widget? placeholder;

  /// Text to display when there are no images
  final String emptyText;

  /// Callback when an image is tapped
  final Function(int)? onImageTap;

  /// Creates an ImageGallery widget
  const ImageGallery({
    super.key,
    required this.imageUrls,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 8.0,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.all(0),
    this.backgroundColor,
    this.enableFullScreen = true,
    this.placeholder,
    this.emptyText = 'No images available',
    this.onImageTap,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Container(
          height: widget.height,
          width: widget.width,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (widget.enableFullScreen) {
                    _showFullScreenImage(context, index);
                  }
                  if (widget.onImageTap != null) {
                    widget.onImageTap!(index);
                  }
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: CachedNetworkImageWidget(
                      imageUrl: widget.imageUrls[index],
                      width: widget.width,
                      height: widget.height,
                      fit: BoxFit.cover,
                      borderRadius: widget.borderRadius,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 8),
          _buildIndicator(),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      width: widget.width,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child:
          widget.placeholder ??
          ImagePlaceholder(
            height: widget.height,
            width: widget.width,
            borderRadius: widget.borderRadius,
            icon: Icons.image,
            iconSize: 50,
          ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          widget.imageUrls.asMap().entries.map((entry) {
            final index = entry.key;
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withAlpha(128),
              ),
            );
          }).toList(),
    );
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => FullScreenImageViewer(
              imageUrls: widget.imageUrls,
              initialIndex: initialIndex,
            ),
      ),
    );
  }
}

/// A full screen image viewer
class FullScreenImageViewer extends StatefulWidget {
  /// List of image URLs to display
  final List<String> imageUrls;

  /// Initial index to display
  final int initialIndex;

  /// Creates a FullScreenImageViewer
  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Image ${_currentIndex + 1} of ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 3.0,
            child: Center(
              child: CachedNetworkImageWidget(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.contain,
                showLoadingIndicator: true,
                loadingIndicatorColor: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
