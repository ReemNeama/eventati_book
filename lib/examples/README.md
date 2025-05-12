# Examples Directory

This directory contains example implementations of various features in the Eventati Book application. These examples are meant to serve as reference implementations that can be integrated into the actual screens.

## Important Note on Vendor Implementation

- Vendors will have their own separate admin projects/applications where they can upload their details and images
- The Eventati Book app will only display vendor information, handle bookings, and process payments
- The app will not include functionality for vendors to upload images directly
- The `ServiceGalleryExample` demonstrates how to display service images, but in the actual app, the upload functionality should be removed
- Only the display functionality for vendor images should be used in production

## Supabase Storage Examples

### Image Galleries

The following examples demonstrate how to implement image galleries using Supabase Storage:

- **VenueGalleryExample**: Shows how to display and upload images for venues
- **EventGalleryExample**: Shows how to display and upload images for events
- **ServiceGalleryExample**: Shows how to display and upload images for services (catering, photography, etc.)

### How to Use

1. Import the example component:
   ```dart
   import 'package:eventati_book/examples/venue_gallery_example.dart';
   ```

2. Use the component in your screen:
   ```dart
   VenueGalleryExample(venue: venue)
   ```

### Integration Steps

To integrate these examples into your actual screens:

1. Copy the relevant code from the example to your screen
2. Adapt the code to fit your screen's layout and state management
3. Test the integration to ensure it works as expected

## Common Widgets Used

These examples use the following common widgets:

- **ImageGallery**: A widget that displays a gallery of images with pagination and full-screen viewing
- **CachedNetworkImageWidget**: A widget that displays a network image with caching and loading states

## Supabase Storage Integration

These examples demonstrate the following Supabase Storage features:

- Image upload with progress tracking
- Image compression and optimization
- Thumbnail generation
- Secure access control
- Organized folder structure

## Notes

- These examples are meant to be used as reference implementations and may need to be adapted to fit your specific use case
- The examples assume that the necessary Supabase Storage setup has been completed
- Error handling is included to demonstrate best practices
