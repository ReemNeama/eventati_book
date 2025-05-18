import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/widgets.dart';
import 'package:eventati_book/models/service_models/venue.dart';
import 'package:eventati_book/utils/file_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/text_styles.dart';

/// Example screen showing how to use the ImageGallery widget with a venue
class VenueGalleryExample extends StatefulWidget {
  /// The venue to display
  final Venue venue;

  /// Creates a VenueGalleryExample
  const VenueGalleryExample({super.key, required this.venue});

  @override
  State<VenueGalleryExample> createState() => _VenueGalleryExampleState();
}

class _VenueGalleryExampleState extends State<VenueGalleryExample> {
  List<String> _imageUrls = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    // In a real app, you would load the images from Supabase Storage
    // For this example, we'll use the venue's imageUrl
    setState(() {
      if (widget.venue.imageUrl.isNotEmpty) {
        _imageUrls = [widget.venue.imageUrl];
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    try {
      // Pick an image
      final imageFile = await FileUtils.pickImage(ImageSource.gallery);
      if (imageFile == null) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _errorMessage = null;
      });

      // Upload the image
      final result = await FileUtils.uploadVenueImage(
        widget.venue.id,
        imageFile,
        onMainProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      if (result != null && result.containsKey('mainUrl')) {
        setState(() {
          _imageUrls = [..._imageUrls, result['mainUrl']!];
          _isUploading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to upload image';
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.venue.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue details
            Text(
              widget.venue.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.venue.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Image gallery
            Text('Gallery', style: TextStyles.sectionTitle),
            const SizedBox(height: 8),
            ImageGallery(
              imageUrls: _imageUrls,
              height: 250,
              borderRadius: 12,
              enableFullScreen: true,
              emptyText: 'No images available for this venue',
            ),
            const SizedBox(height: 16),

            // Upload progress
            if (_isUploading) ...[
              const Text('Uploading image...'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _uploadProgress),
              Text('${(_uploadProgress * 100).toInt()}%'),
              const SizedBox(height: 16),
            ],

            // Error message
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 16),
            ],

            // Add image button
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Image'),
            ),
          ],
        ),
      ),
    );
  }
}
