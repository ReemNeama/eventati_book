import 'dart:io';
import 'dart:typed_data';

import 'package:eventati_book/services/interfaces/storage_service_interface.dart';
import 'package:eventati_book/services/supabase/core/supabase_storage_service.dart';
import 'package:eventati_book/utils/image_utils.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Utility functions for file operations
class FileUtils {
  /// Storage service instance
  static StorageServiceInterface? _storageService;

  /// Set the storage service
  static void setStorageService(StorageServiceInterface storageService) {
    _storageService = storageService;
  }

  /// Get the storage service
  static StorageServiceInterface get storageService {
    _storageService ??= SupabaseStorageService();
    return _storageService!;
  }

  /// Get the application documents directory
  static Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Get the temporary directory
  static Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Get a file from the application documents directory
  static Future<File> getFile(String fileName) async {
    final directory = await getAppDirectory();
    return File(path.join(directory.path, fileName));
  }

  /// Save a string to a file in the application documents directory
  static Future<File> saveStringToFile(String content, String fileName) async {
    final file = await getFile(fileName);
    return file.writeAsString(content);
  }

  /// Read a string from a file in the application documents directory
  static Future<String> readStringFromFile(String fileName) async {
    try {
      final file = await getFile(fileName);
      return await file.readAsString();
    } catch (e) {
      Logger.e('Error reading file: $e', tag: 'FileUtils');
      return '';
    }
  }

  /// Delete a file from the application documents directory
  static Future<bool> deleteFile(String fileName) async {
    try {
      final file = await getFile(fileName);
      await file.delete();
      return true;
    } catch (e) {
      Logger.e('Error deleting file: $e', tag: 'FileUtils');
      return false;
    }
  }

  /// Check if a file exists in the application documents directory
  static Future<bool> fileExists(String fileName) async {
    final file = await getFile(fileName);
    return file.exists();
  }

  /// Pick an image from the gallery or camera
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      Logger.e('Error picking image: $e', tag: 'FileUtils');
      return null;
    }
  }

  /// Upload a file to Supabase Storage
  static Future<String?> uploadFile(
    String userId,
    String folder,
    File file, {
    Function(double)? onProgress,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileName = path.basename(file.path);
      final storagePath = '$userId/$folder/$fileName';

      if (onProgress != null) {
        return await storageService.uploadFileWithProgress(
          storagePath,
          file,
          onProgress: onProgress,
          metadata: metadata,
        );
      } else {
        return await storageService.uploadFile(
          storagePath,
          file,
          metadata: metadata,
        );
      }
    } catch (e) {
      Logger.e('Error uploading file: $e', tag: 'FileUtils');
      return null;
    }
  }

  /// Upload image data to Supabase Storage
  static Future<String?> uploadImageData(
    String userId,
    String folder,
    Uint8List data,
    String fileName, {
    Function(double)? onProgress,
    Map<String, String>? metadata,
  }) async {
    try {
      final storagePath = '$userId/$folder/$fileName';

      if (onProgress != null) {
        return await storageService.uploadDataWithProgress(
          storagePath,
          data,
          onProgress: onProgress,
          metadata: metadata,
        );
      } else {
        return await storageService.uploadData(
          storagePath,
          data,
          metadata: metadata,
        );
      }
    } catch (e) {
      Logger.e('Error uploading image data: $e', tag: 'FileUtils');
      return null;
    }
  }

  /// Download a file from Supabase Storage
  static Future<File?> downloadFile(
    String storagePath,
    String localFileName, {
    Function(double)? onProgress,
  }) async {
    try {
      final directory = await getAppDirectory();
      final localPath = path.join(directory.path, localFileName);

      if (onProgress != null) {
        return await storageService.downloadFileWithProgress(
          storagePath,
          localPath,
          onProgress: onProgress,
        );
      } else {
        return await storageService.downloadFile(storagePath, localPath);
      }
    } catch (e) {
      Logger.e('Error downloading file: $e', tag: 'FileUtils');
      return null;
    }
  }

  /// Delete a file from Supabase Storage
  static Future<bool> deleteStorageFile(String storagePath) async {
    try {
      await storageService.deleteFile(storagePath);
      return true;
    } catch (e) {
      Logger.e('Error deleting storage file: $e', tag: 'FileUtils');
      return false;
    }
  }

  /// Get a download URL for a file in Supabase Storage
  static Future<String?> getDownloadURL(String storagePath) async {
    try {
      return await storageService.getDownloadURL(storagePath);
    } catch (e) {
      Logger.e('Error getting download URL: $e', tag: 'FileUtils');
      return null;
    }
  }

  /// Get the file size in a human-readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Upload a profile image to Supabase Storage
  static Future<String?> uploadProfileImage(
    String userId,
    File imageFile, {
    Function(double)? onProgress,
  }) async {
    try {
      // Get the storage service
      final storage = storageService;

      // Generate the storage path
      final storagePath = 'profiles/$userId/profile.jpg';

      // Upload the image with compression
      return await storage.uploadImageWithCompression(
        storagePath,
        imageFile,
        maxWidth: ImageUtils.profileImageMaxDimension,
        maxHeight: ImageUtils.profileImageMaxDimension,
        quality: ImageUtils.profileImageQuality,
        onProgress: onProgress,
        metadata: {
          'userId': userId,
          'contentType': 'profile_image',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      Logger.e('Error uploading profile image: $e', tag: 'FileUtils');
      return null;
    }
  }

  /// Upload an event image to Supabase Storage
  static Future<Map<String, String>?> uploadEventImage(
    String eventId,
    File imageFile, {
    Function(double)? onMainProgress,
    Function(double)? onThumbnailProgress,
  }) async {
    try {
      // Generate a unique ID for the image
      final imageId = const Uuid().v4();

      // Get the storage service
      final storage = storageService;

      // Generate the storage paths
      final mainPath = 'events/$eventId/images/$imageId.jpg';
      final thumbnailPath = 'events/$eventId/thumbnails/$imageId.jpg';

      // Upload the image with thumbnail
      final result = await storage.uploadImageWithThumbnail(
        mainPath,
        thumbnailPath,
        imageFile,
        maxWidth: ImageUtils.eventImageMaxWidth,
        maxHeight: ImageUtils.eventImageMaxHeight,
        quality: ImageUtils.eventImageQuality,
        onMainProgress: onMainProgress,
        onThumbnailProgress: onThumbnailProgress,
        metadata: {
          'eventId': eventId,
          'imageId': imageId,
          'contentType': 'event_image',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      return result;
    } catch (e) {
      Logger.e('Error uploading event image: $e', tag: 'FileUtils');
      return null;
    }
  }

  /// Upload a venue image to Supabase Storage
  static Future<Map<String, String>?> uploadVenueImage(
    String venueId,
    File imageFile, {
    Function(double)? onMainProgress,
    Function(double)? onThumbnailProgress,
  }) async {
    try {
      // Generate a unique ID for the image
      final imageId = const Uuid().v4();

      // Get the storage service
      final storage = storageService;

      // Generate the storage paths
      final mainPath = 'venues/$venueId/images/$imageId.jpg';
      final thumbnailPath = 'venues/$venueId/thumbnails/$imageId.jpg';

      // Upload the image with thumbnail
      final result = await storage.uploadImageWithThumbnail(
        mainPath,
        thumbnailPath,
        imageFile,
        maxWidth: ImageUtils.venueImageMaxWidth,
        maxHeight: ImageUtils.venueImageMaxHeight,
        quality: ImageUtils.venueImageQuality,
        onMainProgress: onMainProgress,
        onThumbnailProgress: onThumbnailProgress,
        metadata: {
          'venueId': venueId,
          'imageId': imageId,
          'contentType': 'venue_image',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      return result;
    } catch (e) {
      Logger.e('Error uploading venue image: $e', tag: 'FileUtils');
      return null;
    }
  }

  /// Upload a guest photo to Supabase Storage
  static Future<String?> uploadGuestPhoto(
    String eventId,
    String guestId,
    File imageFile, {
    Function(double)? onProgress,
  }) async {
    try {
      // Get the storage service
      final storage = storageService;

      // Generate the storage path
      final storagePath = 'events/$eventId/guests/$guestId/photo.jpg';

      // Compress the image
      final compressedImage = await ImageUtils.compressImage(
        imageFile,
        quality: ImageUtils.profileImageQuality,
      );

      // Upload the image
      return await storage.uploadFile(
        storagePath,
        compressedImage,
        metadata: {
          'eventId': eventId,
          'guestId': guestId,
          'contentType': 'guest_photo',
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      Logger.e('Error uploading guest photo: $e', tag: 'FileUtils');
      return null;
    }
  }

  /// IMPORTANT: This method is for demonstration purposes only.
  /// In the actual Eventati Book app, vendors will have their own separate admin projects/applications
  /// where they can upload their details and images. The Eventati Book app will only display vendor
  /// information, handle bookings, and process payments. The app will not include functionality for
  /// vendors to upload images directly.
  ///
  /// Upload a service image to Supabase Storage - FOR DEMONSTRATION PURPOSES ONLY
  /// This should NOT be used in the production app as vendors will use separate admin projects for uploads.
  static Future<Map<String, String>?> uploadServiceImage(
    String serviceType,
    String serviceId,
    File imageFile, {
    Function(double)? onMainProgress,
    Function(double)? onThumbnailProgress,
  }) async {
    // This method is intentionally left as a demonstration only.
    // In production, this functionality should be removed or disabled.
    Logger.w(
      'Service image upload functionality should not be used in production. '
      'Vendors will use separate admin projects for uploads.',
      tag: 'FileUtils',
    );

    try {
      // Generate a unique ID for the image
      final imageId = const Uuid().v4();

      // Get the storage service
      final storage = storageService;

      // Generate the storage paths
      final mainPath = 'services/$serviceType/$serviceId/images/$imageId.jpg';
      final thumbnailPath =
          'services/$serviceType/$serviceId/thumbnails/$imageId.jpg';

      // Upload the image with thumbnail
      final result = await storage.uploadImageWithThumbnail(
        mainPath,
        thumbnailPath,
        imageFile,
        maxWidth: ImageUtils.venueImageMaxWidth,
        maxHeight: ImageUtils.venueImageMaxHeight,
        quality: ImageUtils.venueImageQuality,
        onMainProgress: onMainProgress,
        onThumbnailProgress: onThumbnailProgress,
        metadata: {
          'serviceType': serviceType,
          'serviceId': serviceId,
          'imageId': imageId,
          'contentType': 'service_image',
          'uploadedAt': DateTime.now().toIso8601String(),
          'demo_only': 'true', // Mark as demo only
        },
      );

      return result;
    } catch (e) {
      Logger.e('Error uploading service image: $e', tag: 'FileUtils');
      return null;
    }
  }

  /// Get the current user ID
  static String? getCurrentUserId() {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id;
  }
}
