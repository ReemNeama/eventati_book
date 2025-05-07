import 'dart:io';
import 'dart:typed_data';

import 'package:eventati_book/services/interfaces/storage_service_interface.dart';
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
}
