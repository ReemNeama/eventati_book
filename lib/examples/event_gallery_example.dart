import 'package:flutter/material.dart';
import 'package:eventati_book/widgets/widgets.dart';
import 'package:eventati_book/models/event_models/event.dart';
import 'package:eventati_book/utils/file_utils.dart';
import 'package:image_picker/image_picker.dart';

/// Example screen showing how to use the ImageGallery widget with an event
class EventGalleryExample extends StatefulWidget {
  /// The event to display
  final Event event;

  /// Creates an EventGalleryExample
  const EventGalleryExample({super.key, required this.event});

  @override
  State<EventGalleryExample> createState() => _EventGalleryExampleState();
}

class _EventGalleryExampleState extends State<EventGalleryExample> {
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
      final result = await FileUtils.uploadEventImage(
        widget.event.id,
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
      appBar: AppBar(title: Text(widget.event.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event details
            Text(
              widget.event.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${widget.event.date.toString().substring(0, 10)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Location: ${widget.event.location}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),

            // Image gallery
            const Text(
              'Event Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ImageGallery(
              imageUrls: _imageUrls,
              height: 250,
              borderRadius: 12,
              enableFullScreen: true,
              emptyText: 'No photos available for this event',
            ),
            const SizedBox(height: 16),

            // Upload progress
            if (_isUploading) ...[
              const Text('Uploading photo...'),
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

            // Add image button
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
