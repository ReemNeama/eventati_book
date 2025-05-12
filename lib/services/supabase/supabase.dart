/// Supabase services
///
/// This barrel file exports all Supabase services.
library;

// Core services
export 'core/custom_analytics_service.dart';
export 'core/custom_messaging_service.dart';
export 'core/supabase_auth_service.dart';
export 'core/supabase_storage_service.dart';

// Database services
export 'database/booking_database_service.dart';
export 'database/budget_database_service.dart';
export 'database/event_database_service.dart';
export 'database/guest_database_service.dart';
export 'database/service_database_service.dart';
export 'database/task_database_service.dart';
export 'database/user_database_service.dart';
export 'database/vendor_recommendation_database_service.dart';
export 'database/wizard_state_database_service.dart';
export 'database/wizard_connection_database_service.dart';

// Utility services
export 'utils/database_service.dart';
export 'utils/supabase_exceptions.dart';

// Test utilities
export 'test/task_test_data_generator.dart';
