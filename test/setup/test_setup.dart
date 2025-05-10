import 'package:flutter_test/flutter_test.dart';
import '../helpers/firebase_test_helper.dart';

/// Initialize test environment
Future<void> setupTestEnvironment() async {
  // Initialize WidgetsFlutterBinding
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup Firebase mocks
  await FirebaseTestHelper.setupFirebaseMocks();
}
