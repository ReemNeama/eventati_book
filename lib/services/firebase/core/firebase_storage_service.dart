import 'dart:io';
import 'dart:typed_data';

import 'package:eventati_book/services/interfaces/storage_service_interface.dart';
import 'package:eventati_book/utils/image_utils.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path_util;

/// Implementation of StorageServiceInterface using Firebase Storage
class FirebaseStorageService implements StorageServiceInterface {
  /// Firebase Storage instance
  final FirebaseStorage _storage;

  /// Constructor
  FirebaseStorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadFile(
    String path,
    File file, {
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask =
          metadata != null
              ? ref.putFile(file, SettableMetadata(customMetadata: metadata))
              : ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Logger.e('Error uploading file: $e', tag: 'FirebaseStorageService');
      rethrow;
    }
  }

  @override
  Future<String> uploadData(
    String path,
    Uint8List data, {
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask =
          metadata != null
              ? ref.putData(data, SettableMetadata(customMetadata: metadata))
              : ref.putData(data);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Logger.e('Error uploading data: $e', tag: 'FirebaseStorageService');
      rethrow;
    }
  }

  @override
  Future<File> downloadFile(String path, String localPath) async {
    try {
      final ref = _storage.ref().child(path);
      final file = File(localPath);
      await ref.writeToFile(file);
      return file;
    } catch (e) {
      Logger.e('Error downloading file: $e', tag: 'FirebaseStorageService');
      rethrow;
    }
  }

  @override
  Future<String> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      Logger.e('Error getting download URL: $e', tag: 'FirebaseStorageService');
      rethrow;
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      Logger.e('Error deleting file: $e', tag: 'FirebaseStorageService');
      rethrow;
    }
  }

  @override
  Future<List<String>> listFiles(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final result = await ref.listAll();
      return result.items.map((item) => item.fullPath).toList();
    } catch (e) {
      Logger.e('Error listing files: $e', tag: 'FirebaseStorageService');
      rethrow;
    }
  }

  @override
  Future<Map<String, String>> getMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = await ref.getMetadata();
      return metadata.customMetadata ?? {};
    } catch (e) {
      Logger.e('Error getting metadata: $e', tag: 'FirebaseStorageService');
      rethrow;
    }
  }

  @override
  Future<Map<String, String>> updateMetadata(
    String path,
    Map<String, String> metadata,
  ) async {
    try {
      final ref = _storage.ref().child(path);
      final updatedMetadata = await ref.updateMetadata(
        SettableMetadata(customMetadata: metadata),
      );
      return updatedMetadata.customMetadata ?? {};
    } catch (e) {
      Logger.e('Error updating metadata: $e', tag: 'FirebaseStorageService');
      rethrow;
    }
  }

  @override
  Future<int> getFileSize(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      Logger.e('Error getting file size: $e', tag: 'FirebaseStorageService');
      rethrow;
    }
  }

  @override
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getMetadata();
      return true;
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        return false;
      }
      Logger.e(
        'Error checking if file exists: $e',
        tag: 'FirebaseStorageService',
      );
      rethrow;
    }
  }

  @override
  Future<String> getSignedUrl(String path, {Duration? expiration}) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
      // Note: Firebase Storage in Flutter doesn't directly support signed URLs
      // This is a simplified implementation that returns a regular download URL
    } catch (e) {
      Logger.e('Error getting signed URL: $e', tag: 'FirebaseStorageService');
      rethrow;
    }
  }

  @override
  Future<String> uploadFileWithProgress(
    String path,
    File file, {
    Function(double)? onProgress,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask =
          metadata != null
              ? ref.putFile(file, SettableMetadata(customMetadata: metadata))
              : ref.putFile(file);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Logger.e(
        'Error uploading file with progress: $e',
        tag: 'FirebaseStorageService',
      );
      rethrow;
    }
  }

  @override
  Future<String> uploadDataWithProgress(
    String path,
    Uint8List data, {
    Function(double)? onProgress,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask =
          metadata != null
              ? ref.putData(data, SettableMetadata(customMetadata: metadata))
              : ref.putData(data);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Logger.e(
        'Error uploading data with progress: $e',
        tag: 'FirebaseStorageService',
      );
      rethrow;
    }
  }

  @override
  Future<File> downloadFileWithProgress(
    String path,
    String localPath, {
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final file = File(localPath);

      // Get the total size of the file
      final metadata = await ref.getMetadata();
      final totalBytes = metadata.size ?? 0;

      // Create a temporary file to track progress
      final tempFile = File('${localPath}_temp');
      final downloadTask = ref.writeToFile(tempFile);

      if (onProgress != null && totalBytes > 0) {
        downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / totalBytes;
          onProgress(progress);
        });
      }

      await downloadTask;

      // Rename the temp file to the final file
      await tempFile.rename(localPath);

      return file;
    } catch (e) {
      Logger.e(
        'Error downloading file with progress: $e',
        tag: 'FirebaseStorageService',
      );
      rethrow;
    }
  }

  /// Generate a unique file path for storage
  ///
  /// [userId] The ID of the user
  /// [folder] The folder to store the file in
  /// [fileName] The name of the file
  /// Returns a unique path for the file
  String generatePath(String userId, String folder, String fileName) {
    final extension = path_util.extension(fileName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$userId/$folder/$timestamp$extension';
  }

  /// Upload an image file with compression
  ///
  /// [path] The path to store the file at
  /// [file] The image file to upload
  /// [maxWidth] Maximum width of the compressed image
  /// [maxHeight] Maximum height of the compressed image
  /// [quality] JPEG quality (0-100)
  /// [onProgress] Callback for upload progress (0.0 to 1.0)
  /// [metadata] Optional metadata for the file
  /// Returns the download URL for the uploaded file
  Future<String> uploadImageWithCompression(
    String path,
    File file, {
    int maxWidth = ImageUtils.venueImageMaxDimension,
    int maxHeight = ImageUtils.venueImageMaxDimension,
    int quality = ImageUtils.venueImageQuality,
    Function(double)? onProgress,
    Map<String, String>? metadata,
  }) async {
    try {
      // Compress the image
      final compressedFile = await ImageUtils.compressImage(
        file,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );

      // Add image dimensions to metadata
      final size = await ImageUtils.getImageDimensions(compressedFile);
      final fileSize = await ImageUtils.getFileSizeInKB(compressedFile);
      final format = ImageUtils.getImageFormat(compressedFile);

      final imageMetadata = {
        'width': size.width.toInt().toString(),
        'height': size.height.toInt().toString(),
        'size_kb': fileSize.toInt().toString(),
        'format': format,
        'compressed': 'true',
        'original_name': path_util.basename(file.path),
      };

      // Merge with provided metadata
      final mergedMetadata = {...imageMetadata, ...(metadata ?? {})};

      // Upload the compressed file with progress tracking
      return await uploadFileWithProgress(
        path,
        compressedFile,
        onProgress: onProgress,
        metadata: mergedMetadata,
      );
    } catch (e) {
      Logger.e(
        'Error uploading image with compression: $e',
        tag: 'FirebaseStorageService',
      );
      rethrow;
    }
  }

  /// Upload an image with thumbnail generation
  ///
  /// [mainPath] The path to store the main image at
  /// [thumbnailPath] The path to store the thumbnail at
  /// [file] The image file to upload
  /// [maxWidth] Maximum width of the compressed main image
  /// [maxHeight] Maximum height of the compressed main image
  /// [quality] JPEG quality for the main image (0-100)
  /// [thumbnailMaxDimension] Maximum dimension for the thumbnail
  /// [thumbnailQuality] JPEG quality for the thumbnail (0-100)
  /// [onMainProgress] Callback for main image upload progress (0.0 to 1.0)
  /// [onThumbnailProgress] Callback for thumbnail upload progress (0.0 to 1.0)
  /// [metadata] Optional metadata for both files
  /// Returns a map with download URLs for both the main image and thumbnail
  Future<Map<String, String>> uploadImageWithThumbnail(
    String mainPath,
    String thumbnailPath,
    File file, {
    int maxWidth = ImageUtils.venueImageMaxDimension,
    int maxHeight = ImageUtils.venueImageMaxDimension,
    int quality = ImageUtils.venueImageQuality,
    int thumbnailMaxDimension = ImageUtils.thumbnailMaxDimension,
    int thumbnailQuality = ImageUtils.thumbnailQuality,
    Function(double)? onMainProgress,
    Function(double)? onThumbnailProgress,
    Map<String, String>? metadata,
  }) async {
    try {
      // Compress the main image
      final compressedFile = await ImageUtils.compressImage(
        file,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );

      // Create a thumbnail
      final thumbnailFile = await ImageUtils.createThumbnail(
        file,
        maxDimension: thumbnailMaxDimension,
        quality: thumbnailQuality,
      );

      // Add image dimensions to metadata
      final size = await ImageUtils.getImageDimensions(compressedFile);
      final fileSize = await ImageUtils.getFileSizeInKB(compressedFile);
      final format = ImageUtils.getImageFormat(compressedFile);

      final imageMetadata = {
        'width': size.width.toInt().toString(),
        'height': size.height.toInt().toString(),
        'size_kb': fileSize.toInt().toString(),
        'format': format,
        'compressed': 'true',
        'original_name': path_util.basename(file.path),
      };

      // Merge with provided metadata
      final mergedMetadata = {...imageMetadata, ...(metadata ?? {})};

      // Upload both files concurrently
      final mainUploadFuture = uploadFileWithProgress(
        mainPath,
        compressedFile,
        onProgress: onMainProgress,
        metadata: mergedMetadata,
      );

      final thumbnailUploadFuture = uploadFileWithProgress(
        thumbnailPath,
        thumbnailFile,
        onProgress: onThumbnailProgress,
        metadata: {
          ...mergedMetadata,
          'is_thumbnail': 'true',
          'thumbnail_dimension': thumbnailMaxDimension.toString(),
        },
      );

      // Wait for both uploads to complete
      final results = await Future.wait([
        mainUploadFuture,
        thumbnailUploadFuture,
      ]);

      return {'mainUrl': results[0], 'thumbnailUrl': results[1]};
    } catch (e) {
      Logger.e(
        'Error uploading image with thumbnail: $e',
        tag: 'FirebaseStorageService',
      );
      rethrow;
    }
  }

  /// Generate a path for a user profile image
  static String userProfileImagePath(String userId) {
    return 'users/$userId/profile_image';
  }

  /// Generate a path for an event image
  static String eventImagePath(String eventId, String imageId) {
    return 'events/$eventId/images/$imageId';
  }

  /// Generate a path for an event thumbnail
  static String eventThumbnailPath(String eventId, String imageId) {
    return 'events/$eventId/thumbnails/$imageId';
  }

  /// Generate a path for a venue image
  static String venueImagePath(String venueId, String imageId) {
    return 'venues/$venueId/images/$imageId';
  }

  /// Generate a path for a venue thumbnail
  static String venueThumbnailPath(String venueId, String imageId) {
    return 'venues/$venueId/thumbnails/$imageId';
  }

  /// Generate a path for a guest photo
  static String guestPhotoPath(String eventId, String guestId) {
    return 'guests/$eventId/$guestId/photo';
  }

  /// Generate a path for a service image (catering, photographer, etc.)
  static String serviceImagePath(
    String serviceType,
    String serviceId,
    String imageId,
  ) {
    return 'services/$serviceType/$serviceId/images/$imageId';
  }

  /// Generate a path for a service thumbnail
  static String serviceThumbnailPath(
    String serviceType,
    String serviceId,
    String imageId,
  ) {
    return 'services/$serviceType/$serviceId/thumbnails/$imageId';
  }
}
