import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:eventati_book/utils/logger.dart';

/// Utility functions for image operations
class ImageUtils {
  /// Maximum image dimension for profile images
  static const int profileImageMaxDimension = 500;

  /// Maximum image dimension for venue/event images
  static const int venueImageMaxDimension = 1200;

  /// Maximum image dimension for thumbnail images
  static const int thumbnailMaxDimension = 200;

  /// JPEG quality for profile images (0-100)
  static const int profileImageQuality = 85;

  /// JPEG quality for venue/event images (0-100)
  static const int venueImageQuality = 80;

  /// JPEG quality for thumbnail images (0-100)
  static const int thumbnailQuality = 70;

  /// Compress and resize an image file
  ///
  /// [file] The image file to compress
  /// [maxWidth] Maximum width of the compressed image
  /// [maxHeight] Maximum height of the compressed image
  /// [quality] JPEG quality (0-100)
  /// Returns the compressed image file
  static Future<File> compressImage(
    File file, {
    int maxWidth = venueImageMaxDimension,
    int maxHeight = venueImageMaxDimension,
    int quality = venueImageQuality,
  }) async {
    try {
      // Create a temporary file path
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}',
      );

      // Use image_picker to compress the image
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (xFile == null) {
        throw Exception('Failed to compress image');
      }

      // Copy the compressed image to the temporary file
      final compressedFile = File(xFile.path);
      final bytes = await compressedFile.readAsBytes();
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
  /// [maxDimension] Maximum dimension (width or height) of the thumbnail
  /// [quality] JPEG quality (0-100)
  /// Returns the thumbnail file
  static Future<File> createThumbnail(
    File file, {
    int maxDimension = thumbnailMaxDimension,
    int quality = thumbnailQuality,
  }) async {
    try {
      // Create a temporary file path
      final tempDir = await getTemporaryDirectory();
      final tempPath = path.join(
        tempDir.path,
        'thumbnail_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}',
      );

      // Use image_picker to create a thumbnail
      final picker = ImagePicker();
      final xFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxDimension.toDouble(),
        maxHeight: maxDimension.toDouble(),
        imageQuality: quality,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (xFile == null) {
        throw Exception('Failed to create thumbnail');
      }

      // Copy the thumbnail to the temporary file
      final thumbnailFile = File(xFile.path);
      final bytes = await thumbnailFile.readAsBytes();
      final result = await File(tempPath).writeAsBytes(bytes);

      return result;
    } catch (e) {
      Logger.e('Error creating thumbnail: $e', tag: 'ImageUtils');
      // If thumbnail creation fails, create a simple compressed version
      return compressImage(
        file,
        maxWidth: thumbnailMaxDimension,
        maxHeight: thumbnailMaxDimension,
        quality: thumbnailQuality,
      );
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
}
