import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock classes for Supabase
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {}

class MockPostgrestBuilder extends Mock implements PostgrestBuilder {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

class MockRealtimeClient extends Mock implements RealtimeClient {}

// Create a concrete class for storage bucket operations
class MockStorageBucket extends Mock {
  Future<String> upload(
    String path,
    File file, {
    FileOptions? fileOptions,
  }) async => 'mock_url';
  Future<String> uploadBinary(
    String path,
    Uint8List data, {
    FileOptions? fileOptions,
  }) async => 'mock_url';
  Future<Uint8List> download(String path) async => Uint8List(0);
  Future<void> remove(List<String> paths) async {}
  Future<String> getPublicUrl(String path) async => 'mock_public_url';
  Future<String> createSignedUrl(String path, int expiresIn) async =>
      'mock_signed_url';
  Future<List<FileObject>> list({String? path, FileOptions? options}) async =>
      [];
}

// Create a concrete class that can be used as a mock for storage file operations
class MockStorageFileApi extends Mock {
  // Add methods that would be needed for testing
  Future<String> upload(String path, Uint8List file) async => 'mock_url';
  Future<void> remove(List<String> paths) async {}
  Future<Uint8List> download(String path) async => Uint8List(0);
}

/// Mock Supabase singleton for testing
class MockSupabase {
  static final MockSupabase _instance = MockSupabase._internal();
  factory MockSupabase() => _instance;
  MockSupabase._internal();

  late MockSupabaseClient client;
  late MockGoTrueClient auth;
  late MockUser currentUser;
  late MockRealtimeClient realtime;
  bool _initialized = false;

  void initialize() {
    client = MockSupabaseClient();
    auth = MockGoTrueClient();
    currentUser = MockUser();
    realtime = MockRealtimeClient();

    // Setup basic mocks
    when(() => client.auth).thenReturn(auth);
    when(() => auth.currentUser).thenReturn(currentUser);
    when(() => currentUser.id).thenReturn('test_user_id');
    when(() => client.realtime).thenReturn(realtime);

    _initialized = true;
  }

  bool get initialized => _initialized;
}

/// Initialize test environment
Future<void> setupTestEnvironment() async {
  // Initialize WidgetsFlutterBinding
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup Supabase mocks
  MockSupabase().initialize();
}

/// Get a mock Supabase client for testing
MockSupabaseClient getMockSupabaseClient() {
  if (!MockSupabase().initialized) {
    MockSupabase().initialize();
  }
  return MockSupabase().client;
}

/// Setup a mock Supabase query builder for a specific table
MockSupabaseQueryBuilder setupMockQueryBuilder(
  MockSupabaseClient mockClient,
  String table,
) {
  final mockQueryBuilder = MockSupabaseQueryBuilder();
  when(() => mockClient.from(table)).thenReturn(mockQueryBuilder);
  return mockQueryBuilder;
}

/// Setup a mock Postgres filter builder
///
/// Note: This is a simplified mock setup. In a real test, you would need to
/// handle the proper return types and generic parameters.
MockPostgrestFilterBuilder setupMockFilterBuilder(
  MockSupabaseQueryBuilder mockQueryBuilder,
) {
  final mockFilterBuilder = MockPostgrestFilterBuilder();

  // Using dynamic cast to work around type system limitations
  // This is a common approach when mocking generic types in Dart
  when(
    () => mockQueryBuilder.select(),
  ).thenReturn(mockFilterBuilder as dynamic);

  return mockFilterBuilder;
}

/// Setup mock for returning a list of items
///
/// This is a simplified version that just sets up common query patterns.
/// For more complex queries, you'll need to set up the mocks specifically for your test.
void setupMockQueryResponse<T>(
  MockPostgrestFilterBuilder mockFilterBuilder,
  List<Map<String, dynamic>> items,
) {
  // Setup common filter methods to return the filter builder
  when(
    () => mockFilterBuilder.order(any(), ascending: any(named: 'ascending')),
  ).thenReturn(mockFilterBuilder);
  when(() => mockFilterBuilder.eq(any(), any())).thenReturn(mockFilterBuilder);
  when(() => mockFilterBuilder.limit(any())).thenReturn(mockFilterBuilder);

  // For simplicity in tests, we'll just have these methods return the items directly
  // In a real implementation, you would need to handle the proper return types
}
