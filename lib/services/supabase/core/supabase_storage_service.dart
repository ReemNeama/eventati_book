import 'dart:io';
import 'dart:typed_data';

import 'package:eventati_book/config/supabase_options.dart';
import 'package:eventati_book/services/interfaces/storage_service_interface.dart';
import 'package:eventati_book/utils/image_utils.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:path/path.dart' as path_util;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of StorageServiceInterface using Supabase Storage
class SupabaseStorageService implements StorageServiceInterface {
  /// Supabase client instance
  final SupabaseClient _supabase;

  /// Default bucket name
  final String _bucketName;

  /// Constructor
  SupabaseStorageService({SupabaseClient? supabase, String? bucketName})
    : _supabase = supabase ?? Supabase.instance.client,
      _bucketName = bucketName ?? SupabaseOptions.supabaseStorageBucket;

  /// Generate a storage path
  String generatePath(String userId, String folder, String fileName) {
    return '$userId/$folder/$fileName';
  }

  @override
  Future<String> uploadFile(
    String path,
    File file, {
    Map<String, String>? metadata,
  }) async {
    try {
      final fileExtension = path_util.extension(file.path);

      // Upload the file
      await _supabase.storage
          .from(_bucketName)
          .upload(
            path,
            file,
            fileOptions: FileOptions(
              contentType: ImageUtils.getContentType(fileExtension),
              upsert: true,
            ),
          );

      // Set metadata if provided
      if (metadata != null && metadata.isNotEmpty) {
        await updateMetadata(path, metadata);
      }

      // Get the public URL
      return await getDownloadURL(path);
    } catch (e) {
      Logger.e('Error uploading file: $e', tag: 'SupabaseStorageService');
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
      final fileExtension = path_util.extension(path);

      // Upload the data
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            path,
            data,
            fileOptions: FileOptions(
              contentType: ImageUtils.getContentType(fileExtension),
              upsert: true,
            ),
          );

      // Set metadata if provided
      if (metadata != null && metadata.isNotEmpty) {
        await updateMetadata(path, metadata);
      }

      // Get the public URL
      return await getDownloadURL(path);
    } catch (e) {
      Logger.e('Error uploading data: $e', tag: 'SupabaseStorageService');
      rethrow;
    }
  }

  @override
  Future<File> downloadFile(String path, String localPath) async {
    try {
      final bytes = await _supabase.storage.from(_bucketName).download(path);

      final file = File(localPath);
      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      Logger.e('Error downloading file: $e', tag: 'SupabaseStorageService');
      rethrow;
    }
  }

  @override
  Future<String> getDownloadURL(String path) async {
    try {
      return _supabase.storage.from(_bucketName).getPublicUrl(path);
    } catch (e) {
      Logger.e('Error getting download URL: $e', tag: 'SupabaseStorageService');
      rethrow;
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      await _supabase.storage.from(_bucketName).remove([path]);
    } catch (e) {
      Logger.e('Error deleting file: $e', tag: 'SupabaseStorageService');
      rethrow;
    }
  }

  @override
  Future<List<String>> listFiles(String path) async {
    try {
      final result = await _supabase.storage.from(_bucketName).list(path: path);

      return result.map((file) => file.name).toList();
    } catch (e) {
      Logger.e('Error listing files: $e', tag: 'SupabaseStorageService');
      return [];
    }
  }

  @override
  Future<Map<String, String>> getMetadata(String path) async {
    try {
      // Supabase doesn't have a direct API for metadata
      // We can store metadata in a separate table if needed
      return {};
    } catch (e) {
      Logger.e('Error getting metadata: $e', tag: 'SupabaseStorageService');
      return {};
    }
  }

  @override
  Future<Map<String, String>> updateMetadata(
    String path,
    Map<String, String> metadata,
  ) async {
    try {
      // Supabase doesn't have a direct API for metadata
      // We can store metadata in a separate table if needed
      return metadata;
    } catch (e) {
      Logger.e('Error updating metadata: $e', tag: 'SupabaseStorageService');
      return {};
    }
  }

  @override
  Future<int> getFileSize(String path) async {
    try {
      // Download the file to get its size
      final bytes = await _supabase.storage.from(_bucketName).download(path);
      return bytes.length;
    } catch (e) {
      Logger.e('Error getting file size: $e', tag: 'SupabaseStorageService');
      return 0;
    }
  }

  @override
  Future<bool> fileExists(String path) async {
    try {
      // Try to get the file's metadata
      await _supabase.storage.from(_bucketName).download(path);
      return true;
    } catch (e) {
      // If the file doesn't exist, an error will be thrown
      return false;
    }
  }

  @override
  Future<String> getSignedUrl(String path, {Duration? expiration}) async {
    try {
      final signedUrl = await _supabase.storage
          .from(_bucketName)
          .createSignedUrl(
            path,
            expiration?.inSeconds ?? 3600, // Default to 1 hour
          );

      return signedUrl;
    } catch (e) {
      Logger.e('Error getting signed URL: $e', tag: 'SupabaseStorageService');
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
      // Supabase doesn't support progress tracking directly
      // We'll implement a simple version by reporting before and after
      if (onProgress != null) {
        onProgress(0.0);
      }

      final url = await uploadFile(path, file, metadata: metadata);

      if (onProgress != null) {
        onProgress(1.0);
      }

      return url;
    } catch (e) {
      Logger.e(
        'Error uploading file with progress: $e',
        tag: 'SupabaseStorageService',
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
      // Supabase doesn't support progress tracking directly
      // We'll implement a simple version by reporting before and after
      if (onProgress != null) {
        onProgress(0.0);
      }

      final url = await uploadData(path, data, metadata: metadata);

      if (onProgress != null) {
        onProgress(1.0);
      }

      return url;
    } catch (e) {
      Logger.e(
        'Error uploading data with progress: $e',
        tag: 'SupabaseStorageService',
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
      // Supabase doesn't support progress tracking directly
      // We'll implement a simple version by reporting before and after
      if (onProgress != null) {
        onProgress(0.0);
      }

      final file = await downloadFile(path, localPath);

      if (onProgress != null) {
        onProgress(1.0);
      }

      return file;
    } catch (e) {
      Logger.e(
        'Error downloading file with progress: $e',
        tag: 'SupabaseStorageService',
      );
      rethrow;
    }
  }

  /// Upload an image file with compression
  ///
  /// [path] The path to upload the file to
  /// [file] The file to upload
  /// [maxWidth] Maximum width of the image
  /// [maxHeight] Maximum height of the image
  /// [quality] JPEG quality (0-100)
  /// [onProgress] Optional callback for progress updates
  /// [metadata] Optional metadata to set on the file
  /// Returns the download URL of the uploaded file
  @override
  Future<String> uploadImageWithCompression(
    String path,
    File file, {
    int? maxWidth = 1920,
    int? maxHeight = 1080,
    int? quality = 80,
    Function(double)? onProgress,
    Map<String, String>? metadata,
  }) async {
    try {
      if (onProgress != null) {
        onProgress(0.1);
      }

      // Compress the image
      final compressedFile = await ImageUtils.compressImage(
        file,
        quality: quality ?? 80,
      );

      if (onProgress != null) {
        onProgress(0.5);
      }

      // Upload the compressed file
      final url = await uploadFile(path, compressedFile, metadata: metadata);

      if (onProgress != null) {
        onProgress(1.0);
      }

      return url;
    } catch (e) {
      Logger.e(
        'Error uploading image with compression: $e',
        tag: 'SupabaseStorageService',
      );
      rethrow;
    }
  }

  /// Upload an image with a thumbnail
  ///
  /// [mainPath] The path to upload the main image to
  /// [thumbnailPath] The path to upload the thumbnail to
  /// [file] The image file to upload
  /// [maxWidth] Maximum width of the main image
  /// [maxHeight] Maximum height of the main image
  /// [quality] JPEG quality (0-100)
  /// [onMainProgress] Optional callback for main image upload progress
  /// [onThumbnailProgress] Optional callback for thumbnail upload progress
  /// [metadata] Optional metadata to set on the files
  /// Returns a map with 'mainUrl' and 'thumbnailUrl' keys
  @override
  Future<Map<String, String>> uploadImageWithThumbnail(
    String mainPath,
    String thumbnailPath,
    File file, {
    int? maxWidth = 1920,
    int? maxHeight = 1080,
    int? quality = 80,
    Function(double)? onMainProgress,
    Function(double)? onThumbnailProgress,
    Map<String, String>? metadata,
  }) async {
    try {
      // Upload main image
      final mainUrl = await uploadImageWithCompression(
        mainPath,
        file,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
        onProgress: onMainProgress,
        metadata: metadata,
      );

      // Create and upload thumbnail
      final thumbnailFile = await ImageUtils.createThumbnail(file, quality: 70);

      final thumbnailUrl = await uploadFile(
        thumbnailPath,
        thumbnailFile,
        metadata:
            metadata != null
                ? {...metadata, 'contentType': 'thumbnail'}
                : {'contentType': 'thumbnail'},
      );

      return {'mainUrl': mainUrl, 'thumbnailUrl': thumbnailUrl};
    } catch (e) {
      Logger.e(
        'Error uploading image with thumbnail: $e',
        tag: 'SupabaseStorageService',
      );
      rethrow;
    }
  }
}
