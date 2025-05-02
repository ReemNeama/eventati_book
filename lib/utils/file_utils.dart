import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Utility functions for file operations
class FileUtils {
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
      return '';
    }
  }

  /// Check if a file exists in the application documents directory
  static Future<bool> fileExists(String fileName) async {
    final file = await getFile(fileName);
    return file.exists();
  }

  /// Delete a file from the application documents directory
  static Future<void> deleteFile(String fileName) async {
    final file = await getFile(fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get the file extension from a file path
  static String getFileExtension(String filePath) {
    return path.extension(filePath);
  }

  /// Get the file name from a file path
  static String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Get the file name without extension from a file path
  static String getFileNameWithoutExtension(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  /// Get the file size in bytes
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  /// Get a human-readable file size string
  static Future<String> getHumanReadableFileSize(String filePath) async {
    final bytes = await getFileSize(filePath);
    return formatBytes(bytes);
  }

  /// Format bytes to a human-readable string
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  /// Create a directory if it doesn't exist
  static Future<Directory> createDirectoryIfNotExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    
    if (await directory.exists()) {
      return directory;
    }
    
    return await directory.create(recursive: true);
  }

  /// List all files in a directory
  static Future<List<FileSystemEntity>> listFiles(String directoryPath) async {
    final directory = Directory(directoryPath);
    
    if (!await directory.exists()) {
      return [];
    }
    
    return directory.listSync();
  }

  /// Copy a file to a new location
  static Future<File> copyFile(String sourcePath, String destinationPath) async {
    final sourceFile = File(sourcePath);
    return sourceFile.copy(destinationPath);
  }
}

// Helper functions
double log(num x) => log10(x);
double log10(num x) => log2(x) / log2(10);
double log2(num x) => (x > 0) ? (log(x) / ln2) : double.nan;
const double ln2 = 0.6931471805599453;
double pow(num x, num exponent) => x.toDouble() * exponent.toDouble();
