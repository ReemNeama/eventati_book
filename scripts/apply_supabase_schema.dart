import 'dart:io';
import 'package:supabase/supabase.dart';
import 'utils/logger.dart';

// Supabase configuration
const String supabaseUrl = 'https://zyycmxzabfadkyzpsper.supabase.co';
const String supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5eWNteHphYmZhZGt5enBzcGVyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjkyMjMyOCwiZXhwIjoyMDYyNDk4MzI4fQ.7NIGlM6A0xxKlCsgoz0gSSiscxroRUzMnuoXQuH5V8g';

void main() async {
  Logger.i('Applying Supabase schema...');

  // Check if the service role key is provided
  if (supabaseKey.isEmpty) {
    Logger.e(
      'Supabase service role key is required. Please add it to the script.',
    );
    exit(1);
  }

  // Initialize Supabase client
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    // Read the exec_sql function SQL file
    final execSqlFile = File('scripts/create_exec_sql_function.sql');
    if (!await execSqlFile.exists()) {
      Logger.e('Exec SQL function file not found: ${execSqlFile.path}');
      exit(1);
    }

    final execSqlFunctionSql = await execSqlFile.readAsString();
    Logger.i(
      'Read exec_sql function SQL file (${execSqlFunctionSql.length} characters)',
    );

    // Read the schema SQL file
    final schemaFile = File('scripts/supabase_schema.sql');
    if (!await schemaFile.exists()) {
      Logger.e('Schema file not found: ${schemaFile.path}');
      exit(1);
    }

    final schemaSql = await schemaFile.readAsString();
    Logger.i('Read schema SQL file (${schemaSql.length} characters)');

    // Read the RLS policies SQL file
    final rlsFile = File('scripts/supabase_rls_policies.sql');
    if (!await rlsFile.exists()) {
      Logger.e('RLS policies file not found: ${rlsFile.path}');
      exit(1);
    }

    final rlsSql = await rlsFile.readAsString();
    Logger.i('Read RLS policies SQL file (${rlsSql.length} characters)');

    // Apply the exec_sql function SQL directly
    Logger.i('Creating exec_sql function...');
    try {
      // Try to execute the SQL directly using the SQL API
      await supabase.from('_sql').select().eq('query', execSqlFunctionSql);
      Logger.i('Exec SQL function created successfully');
    } catch (e) {
      Logger.w('Error creating exec_sql function: $e');
      // Continue anyway, as the function might already exist
    }

    // Apply the schema SQL
    Logger.i('Applying schema SQL...');
    try {
      await supabase.rpc('exec_sql', params: {'sql': schemaSql});
      Logger.i('Schema SQL applied successfully');
    } catch (e) {
      Logger.e('Error applying schema SQL: $e');
      // Try to apply the schema using the SQL API directly
      try {
        await supabase.from('_sql').select().eq('query', schemaSql);
        Logger.i('Schema SQL applied successfully using SQL API');
      } catch (e) {
        Logger.e('Error applying schema SQL using SQL API: $e');
        exit(1);
      }
    }

    // Apply the RLS policies SQL
    Logger.i('Applying RLS policies SQL...');
    try {
      await supabase.rpc('exec_sql', params: {'sql': rlsSql});
      Logger.i('RLS policies SQL applied successfully');
    } catch (e) {
      Logger.e('Error applying RLS policies SQL: $e');
      // Try to apply the RLS policies using the SQL API directly
      try {
        await supabase.from('_sql').select().eq('query', rlsSql);
        Logger.i('RLS policies SQL applied successfully using SQL API');
      } catch (e) {
        Logger.e('Error applying RLS policies SQL using SQL API: $e');
        exit(1);
      }
    }

    Logger.i('Supabase schema and RLS policies applied successfully');
  } catch (e) {
    Logger.e('Error applying Supabase schema: $e');
    exit(1);
  }
}
