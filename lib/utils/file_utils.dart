import 'dart:io';
import 'dart:typed_data';

import 'package:eventati_book/services/firebase/core/firebase_storage_service.dart';
import 'package:eventati_book/services/interfaces/storage_service_interface.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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
    _storageService ??= FirebaseStorageService();
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

  /// Upload a file to Firebase Storage
  static Future<String?> uploadFile(
    String userId,
    String folder,
    File file, {
    Function(double)? onProgress,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileName = path.basename(file.path);
      final storagePath = (storageService as FirebaseStorageService)
          .generatePath(userId, folder, fileName);

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

  /// Upload image data to Firebase Storage
  static Future<String?> uploadImageData(
    String userId,
    String folder,
    Uint8List data,
    String fileName, {
    Function(double)? onProgress,
    Map<String, String>? metadata,
  }) async {
    try {
      final storagePath = (storageService as FirebaseStorageService)
          .generatePath(userId, folder, fileName);

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

  /// Download a file from Firebase Storage
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

  /// Delete a file from Firebase Storage
  static Future<bool> deleteStorageFile(String storagePath) async {
    try {
      await storageService.deleteFile(storagePath);
      return true;
    } catch (e) {
      Logger.e('Error deleting storage file: $e', tag: 'FileUtils');
      return false;
    }
  }

  /// Get a download URL for a file in Firebase Storage
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
}
