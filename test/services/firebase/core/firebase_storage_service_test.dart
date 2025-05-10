import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:eventati_book/services/firebase/core/firebase_storage_service.dart';
import '../../../helpers/firebase_test_helper.dart';

// Mock File
class MockFile extends Mock implements File {}

// Use a real Uint8List for testing instead of mocking
Uint8List createMockUint8List() {
  return Uint8List.fromList([0, 1, 2, 3, 4, 5]);
}

// Mock ImageUtils
class MockImageUtils extends Mock {
  static Future<File> compressImage(
    File file, {
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
  }) async {
    return file;
  }

  static Future<File> createThumbnail(
    File file, {
    int maxDimension = 200,
    int quality = 70,
  }) async {
    return file;
  }

  static Future<Size> getImageDimensions(File file) async {
    return const Size(800, 600);
  }

  static Future<double> getFileSizeInKB(File file) async {
    return 100.0;
  }

  static String getImageFormat(File file) {
    return 'jpeg';
  }
}

void main() {
  late FirebaseStorageService storageService;
  late MockFirebaseStorage mockStorage;
  late MockStorageReference mockReference;
  late MockUploadTask mockUploadTask;
  late MockTaskSnapshot mockTaskSnapshot;
  late MockFile mockFile;
  late Uint8List mockData;

  setUp(() {
    // Create mocks
    mockStorage = MockFirebaseStorage();
    mockReference = MockStorageReference();
    mockUploadTask = MockUploadTask();
    mockTaskSnapshot = MockTaskSnapshot();
    mockFile = MockFile();
    mockData = createMockUint8List();

    // Setup mock behavior
    when(() => mockStorage.ref(any())).thenReturn(mockReference);
    when(() => mockStorage.ref().child(any())).thenReturn(mockReference);
    when(() => mockReference.putFile(any(), any())).thenReturn(mockUploadTask);
    when(() => mockReference.putData(any(), any())).thenReturn(mockUploadTask);
    when(() => mockUploadTask.snapshot).thenReturn(mockTaskSnapshot);
    when(() => mockTaskSnapshot.ref).thenReturn(mockReference);
    when(
      () => mockReference.getDownloadURL(),
    ).thenAnswer((_) async => 'https://example.com/test.jpg');
    when(() => mockFile.path).thenReturn('/test/path/image.jpg');

    // Create service with mocks
    storageService = FirebaseStorageService(storage: mockStorage);
  });

  group('FirebaseStorageService', () {
    test('can be instantiated', () {
      expect(storageService, isNotNull);
    });

    test('uploadFile uploads file and returns download URL', () async {
      // Arrange
      const path = 'test/path/image.jpg';

      // Act
      final result = await storageService.uploadFile(path, mockFile);

      // Assert
      verify(() => mockStorage.ref().child(path)).called(1);
      verify(() => mockReference.putFile(mockFile, any())).called(1);
      verify(() => mockReference.getDownloadURL()).called(1);
      expect(result, 'https://example.com/test.jpg');
    });

    test('uploadData uploads data and returns download URL', () async {
      // Arrange
      const path = 'test/path/image.jpg';

      // Act
      final result = await storageService.uploadData(path, mockData);

      // Assert
      verify(() => mockStorage.ref().child(path)).called(1);
      verify(() => mockReference.putData(mockData, any())).called(1);
      verify(() => mockReference.getDownloadURL()).called(1);
      expect(result, 'https://example.com/test.jpg');
    });

    test('uploadFile with metadata includes metadata in upload', () async {
      // Arrange
      const path = 'test/path/image.jpg';
      final metadata = {'test': 'value'};

      // Act
      await storageService.uploadFile(path, mockFile, metadata: metadata);

      // Assert
      verify(
        () => mockReference.putFile(
          mockFile,
          any(
            that: predicate<SettableMetadata>(
              (m) => m.customMetadata?['test'] == 'value',
            ),
          ),
        ),
      ).called(1);
    });

    test('uploadFileWithProgress reports progress', () async {
      // Arrange
      const path = 'test/path/image.jpg';
      double? reportedProgress;

      // Setup progress reporting
      when(
        () => mockUploadTask.snapshotEvents,
      ).thenAnswer((_) => Stream.value(mockTaskSnapshot));
      when(() => mockTaskSnapshot.bytesTransferred).thenReturn(50);
      when(() => mockTaskSnapshot.totalBytes).thenReturn(100);

      // Act
      await storageService.uploadFileWithProgress(
        path,
        mockFile,
        onProgress: (progress) {
          reportedProgress = progress;
        },
      );

      // Assert
      expect(reportedProgress, 0.5);
    });

    test('deleteFile deletes file from storage', () async {
      // Arrange
      const path = 'test/path/image.jpg';
      when(() => mockReference.delete()).thenAnswer((_) async {});

      // Act
      await storageService.deleteFile(path);

      // Assert
      verify(() => mockStorage.ref().child(path)).called(1);
      verify(() => mockReference.delete()).called(1);
    });

    test('getDownloadURL returns download URL for a file', () async {
      // Arrange
      const path = 'test/path/image.jpg';

      // Act
      final result = await storageService.getDownloadURL(path);

      // Assert
      verify(() => mockStorage.ref().child(path)).called(1);
      verify(() => mockReference.getDownloadURL()).called(1);
      expect(result, 'https://example.com/test.jpg');
    });

    test('generatePath creates a unique path with timestamp', () {
      // Arrange
      const userId = 'user123';
      const folder = 'images';
      const fileName = 'test.jpg';

      // Act
      final result = storageService.generatePath(userId, folder, fileName);

      // Assert
      expect(result, contains('user123/images/'));
      expect(result, endsWith('.jpg'));
    });
  });
}
