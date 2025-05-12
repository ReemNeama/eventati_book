import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/widgets.dart';
import 'package:eventati_book/utils/file_utils.dart';
import 'package:image_picker/image_picker.dart';

/// Example screen showing how to use the ImageGallery widget with a service
///
/// IMPORTANT NOTE: This example includes image upload functionality for demonstration purposes only.
/// In the actual Eventati Book app, vendors will have their own separate admin projects/applications
/// where they can upload their details and images. The Eventati Book app will only display vendor
/// information, handle bookings, and process payments. The app will not include functionality for
/// vendors to upload images directly. When implementing this in the actual app, remove the upload
/// functionality and only use the display functionality.
class ServiceGalleryExample extends StatefulWidget {
  /// The service ID
  final String serviceId;

  /// The service type (catering, photography, etc.)
  final String serviceType;

  /// The service name
  final String serviceName;

  /// Creates a ServiceGalleryExample
  const ServiceGalleryExample({
    super.key,
    required this.serviceId,
    required this.serviceType,
    required this.serviceName,
  });

  @override
  State<ServiceGalleryExample> createState() => _ServiceGalleryExampleState();
}

class _ServiceGalleryExampleState extends State<ServiceGalleryExample> {
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
    // For this example, we'll use a placeholder
    setState(() {
      _imageUrls = [];
    });
  }

  // DEMONSTRATION ONLY: This method demonstrates how to upload service images,
  // but should NOT be used in the production app as vendors will use separate admin projects for uploads.
  Future<void> _pickAndUploadImage() async {
    // Show a warning dialog to make it clear this is for demonstration only
    final shouldProceed =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Demonstration Only'),
                content: const Text(
                  'This functionality is for demonstration purposes only. '
                  'In the actual Eventati Book app, vendors will have their own separate admin '
                  'projects/applications where they can upload their details and images. '
                  '\n\nDo you want to proceed with this demonstration?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Proceed'),
                  ),
                ],
              ),
        ) ??
        false;

    if (!shouldProceed) return;

    try {
      // Pick an image
      final imageFile = await FileUtils.pickImage(ImageSource.gallery);
      if (imageFile == null) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _errorMessage = null;
      });

      // Upload the image - DEMONSTRATION ONLY
      final result = await FileUtils.uploadServiceImage(
        widget.serviceType,
        widget.serviceId,
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
      appBar: AppBar(title: Text(widget.serviceName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service details
            Text(
              widget.serviceName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Service Type: ${widget.serviceType}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Image gallery
            const Text(
              'Service Gallery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ImageGallery(
              imageUrls: _imageUrls,
              height: 250,
              borderRadius: 12,
              enableFullScreen: true,
              emptyText: 'No images available for this service',
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
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
            ],

            // Add image button - DEMONSTRATION ONLY
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Image (Demo Only)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: In the production app, this button should be removed as vendors will use separate admin projects for uploads.',
              style: TextStyle(
                color: Colors.red,
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
