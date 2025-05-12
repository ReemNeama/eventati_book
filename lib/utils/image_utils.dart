import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:eventati_book/utils/logger.dart';

/// Utility functions for image operations
class ImageUtils {
  /// Maximum image dimension for profile images
  static const int profileImageMaxDimension = 500;

  /// Maximum width for event images
  static const int eventImageMaxWidth = 1920;

  /// Maximum height for event images
  static const int eventImageMaxHeight = 1080;

  /// Maximum width for venue images
  static const int venueImageMaxWidth = 1920;

  /// Maximum height for venue images
  static const int venueImageMaxHeight = 1080;

  /// Maximum image dimension for venue/event images
  static const int venueImageMaxDimension = 1200;

  /// Maximum image dimension for thumbnail images
  static const int thumbnailMaxDimension = 200;

  /// JPEG quality for profile images (0-100)
  static const int profileImageQuality = 85;

  /// JPEG quality for event images (0-100)
  static const int eventImageQuality = 80;

  /// JPEG quality for venue/event images (0-100)
  static const int venueImageQuality = 80;

  /// JPEG quality for thumbnail images (0-100)
  static const int thumbnailQuality = 70;

  /// Compress and resize an image file
  ///
  /// [file] The image file to compress
  /// [quality] JPEG quality (0-100)
  /// Returns the compressed image file
  static Future<File> compressImage(
    File file, {
    int quality = venueImageQuality,
  }) async {
    try {
      // Create a temporary file path
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}',
      );

      // Read the file bytes
      final bytes = await file.readAsBytes();

      // Write the bytes to the new file (this is a simple copy for now)
      // In a real implementation, you would use a proper image compression library
      final result = await File(tempPath).writeAsBytes(bytes);

      return result;
    } catch (e) {
      Logger.e('Error compressing image: $e', tag: 'ImageUtils');
      // If compression fails, return the original file
      return file;
    }
  }

  /// Create a thumbnail from an image file
  ///
  /// [file] The image file to create a thumbnail from
  /// [quality] JPEG quality (0-100)
  /// Returns the thumbnail file
  static Future<File> createThumbnail(
    File file, {
    int quality = thumbnailQuality,
  }) async {
    try {
      // For now, we'll just use the compressImage method
      // In a real implementation, you would resize the image to thumbnail size
      return compressImage(file, quality: quality);
    } catch (e) {
      Logger.e('Error creating thumbnail: $e', tag: 'ImageUtils');
      // If thumbnail creation fails, return the original file
      return file;
    }
  }

  /// Get image dimensions from a file
  ///
  /// [file] The image file to get dimensions from
  /// Returns a Size object with the image dimensions
  static Future<Size> getImageDimensions(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      Logger.e('Error getting image dimensions: $e', tag: 'ImageUtils');
      return const Size(0, 0);
    }
  }

  /// Get the file size in KB
  ///
  /// [file] The file to get the size of
  /// Returns the file size in KB
  static Future<double> getFileSizeInKB(File file) async {
    try {
      final bytes = await file.length();
      return bytes / 1024;
    } catch (e) {
      Logger.e('Error getting file size: $e', tag: 'ImageUtils');
      return 0;
    }
  }

  /// Check if the file is an image
  ///
  /// [file] The file to check
  /// Returns true if the file is an image, false otherwise
  static bool isImageFile(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.bmp',
    ].contains(extension);
  }

  /// Get the image format from a file
  ///
  /// [file] The file to get the format from
  /// Returns the image format (jpg, png, etc.)
  static String getImageFormat(File file) {
    final extension = path.extension(file.path).toLowerCase();
    return extension.replaceAll('.', '');
  }

  /// Get the content type based on file extension
  ///
  /// [extension] The file extension including the dot (e.g., '.jpg')
  /// Returns the content type (e.g., 'image/jpeg')
  static String getContentType(String extension) {
    final ext = extension.toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.bmp':
        return 'image/bmp';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.ppt':
        return 'application/vnd.ms-powerpoint';
      case '.pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case '.txt':
        return 'text/plain';
      case '.csv':
        return 'text/csv';
      case '.mp3':
        return 'audio/mpeg';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }
}
