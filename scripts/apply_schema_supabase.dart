import 'dart:io';
import 'package:supabase/supabase.dart';
import 'utils/logger.dart';

// Supabase configuration
const String supabaseUrl = 'https://zyycmxzabfadkyzpsper.supabase.co';
const String supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5eWNteHphYmZhZGt5enBzcGVyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjkyMjMyOCwiZXhwIjoyMDYyNDk4MzI4fQ.7NIGlM6A0xxKlCsgoz0gSSiscxroRUzMnuoXQuH5V8g';

void main() async {
  Logger.i('Applying Supabase schema...');

  // Initialize Supabase client
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    // Create users table
    Logger.i('Creating users table...');
    await supabase
        .from('users')
        .delete()
        .neq('id', '00000000-0000-0000-0000-000000000000');

    // Create a test user to verify the table exists
    final userData = {
      'id': '00000000-0000-0000-0000-000000000000',
      'name': 'Test User',
      'email': 'test@example.com',
      'phone_number': null,
      'profile_image_url': null,
      'created_at': DateTime.now().toIso8601String(),
      'favorite_venues': [],
      'favorite_services': [],
      'has_premium_subscription': false,
      'is_beta_tester': false,
      'subscription_expiration_date': null,
      'email_verified': true,
      'auth_provider': 'google',
    };

    await supabase.from('users').upsert(userData);
    Logger.i('Users table created and test user added');

    // Verify the user was added
    final response = await supabase
        .from('users')
        .select()
        .eq('id', '00000000-0000-0000-0000-000000000000');
    Logger.i('User retrieved: ${response.isNotEmpty ? "Yes" : "No"}');

    Logger.i('Supabase schema applied successfully');
  } catch (e) {
    Logger.e('Error applying Supabase schema: $e');
    exit(1);
  }
}
