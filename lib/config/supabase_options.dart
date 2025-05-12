/// Supabase configuration options
class SupabaseOptions {
  /// Supabase URL
  static const String supabaseUrl = 'https://zyycmxzabfadkyzpsper.supabase.co';

  /// Supabase anonymous key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5eWNteHphYmZhZGt5enBzcGVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5MjIzMjgsImV4cCI6MjA2MjQ5ODMyOH0.zOvDkiN36YDrNJYgm6pMF447h18xsgOmHkTfFpzn5fQ';

  /// Supabase service role key (for admin operations)
  static const String supabaseServiceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5eWNteHphYmZhZGt5enBzcGVyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjkyMjMyOCwiZXhwIjoyMDYyNDk4MzI4fQ.7NIGlM6A0xxKlCsgoz0gSSiscxroRUzMnuoXQuH5V8g';

  /// Supabase project ID
  static const String supabaseProjectId = 'zyycmxzabfadkyzpsper';

  /// Supabase storage bucket name
  static const String supabaseStorageBucket = 'eventati-book';

  /// Supabase storage URL
  static String get supabaseStorageUrl =>
      '$supabaseUrl/storage/v1/object/$supabaseStorageBucket';
}
