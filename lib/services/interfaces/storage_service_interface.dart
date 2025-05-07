import 'dart:io';
import 'dart:typed_data';

/// Interface for storage services
abstract class StorageServiceInterface {
  /// Upload a file to storage
  /// 
  /// [path] The path to store the file at
  /// [file] The file to upload
  /// [metadata] Optional metadata for the file
  /// Returns the download URL for the uploaded file
  Future<String> uploadFile(
    String path,
    File file, {
    Map<String, String>? metadata,
  });

  /// Upload data to storage
  /// 
  /// [path] The path to store the data at
  /// [data] The data to upload
  /// [metadata] Optional metadata for the file
  /// Returns the download URL for the uploaded data
  Future<String> uploadData(
    String path,
    Uint8List data, {
    Map<String, String>? metadata,
  });

  /// Download a file from storage
  /// 
  /// [path] The path to the file in storage
  /// [localPath] The local path to save the file to
  /// Returns the local file
  Future<File> downloadFile(String path, String localPath);

  /// Get a download URL for a file in storage
  /// 
  /// [path] The path to the file in storage
  /// Returns the download URL
  Future<String> getDownloadURL(String path);

  /// Delete a file from storage
  /// 
  /// [path] The path to the file in storage
  Future<void> deleteFile(String path);

  /// List files in a directory
  /// 
  /// [path] The path to the directory in storage
  /// Returns a list of file paths
  Future<List<String>> listFiles(String path);

  /// Get metadata for a file
  /// 
  /// [path] The path to the file in storage
  /// Returns the metadata for the file
  Future<Map<String, String>> getMetadata(String path);

  /// Update metadata for a file
  /// 
  /// [path] The path to the file in storage
  /// [metadata] The new metadata for the file
  /// Returns the updated metadata
  Future<Map<String, String>> updateMetadata(
    String path,
    Map<String, String> metadata,
  );

  /// Get the size of a file in storage
  /// 
  /// [path] The path to the file in storage
  /// Returns the size of the file in bytes
  Future<int> getFileSize(String path);

  /// Check if a file exists in storage
  /// 
  /// [path] The path to the file in storage
  /// Returns true if the file exists, false otherwise
  Future<bool> fileExists(String path);

  /// Create a signed URL for a file in storage
  /// 
  /// [path] The path to the file in storage
  /// [expiration] The expiration time for the URL
  /// Returns the signed URL
  Future<String> getSignedUrl(String path, {Duration? expiration});

  /// Upload a file with progress tracking
  /// 
  /// [path] The path to store the file at
  /// [file] The file to upload
  /// [onProgress] Callback for upload progress (0.0 to 1.0)
  /// [metadata] Optional metadata for the file
  /// Returns the download URL for the uploaded file
  Future<String> uploadFileWithProgress(
    String path,
    File file, {
    Function(double)? onProgress,
    Map<String, String>? metadata,
  });

  /// Upload data with progress tracking
  /// 
  /// [path] The path to store the data at
  /// [data] The data to upload
  /// [onProgress] Callback for upload progress (0.0 to 1.0)
  /// [metadata] Optional metadata for the file
  /// Returns the download URL for the uploaded data
  Future<String> uploadDataWithProgress(
    String path,
    Uint8List data, {
    Function(double)? onProgress,
    Map<String, String>? metadata,
  });

  /// Download a file with progress tracking
  /// 
  /// [path] The path to the file in storage
  /// [localPath] The local path to save the file to
  /// [onProgress] Callback for download progress (0.0 to 1.0)
  /// Returns the local file
  Future<File> downloadFileWithProgress(
    String path,
    String localPath, {
    Function(double)? onProgress,
  });
}
