import 'dart:io';
import 'package:supabase/supabase.dart';

// Supabase configuration
const String supabaseUrl = 'https://zyycmxzabfadkyzpsper.supabase.co';
const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5eWNteHphYmZhZGt5enBzcGVyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjkyMjMyOCwiZXhwIjoyMDYyNDk4MzI4fQ.7NIGlM6A0xxKlCsgoz0gSSiscxroRUzMnuoXQuH5V8g';

// List of tables to check
const List<String> tables = [
  'users',
  'services',
  'bookings',
  'notifications',
  'events',
  'tasks',
  'task_categories',
  'task_dependencies',
  'guests',
  'budget_items',
  'wizard_states',
  'wizard_connections',
  'service_reviews',
  'payments',
];

void main() async {
  print('Checking Supabase tables...');

  // Initialize Supabase client
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    // Check each table
    for (final table in tables) {
      try {
        print('Checking table: $table');
        final response = await supabase.from(table).select('*').limit(1);
        print('  Table $table exists with ${response.length} rows');
      } catch (e) {
        print('  Error checking table $table: $e');
      }
    }
    
    print('Supabase table check completed');
  } catch (e) {
    print('Error checking Supabase tables: $e');
    exit(1);
  }
}
