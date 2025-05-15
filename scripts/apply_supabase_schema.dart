import 'dart:io';
import 'package:supabase/supabase.dart';
import 'utils/logger.dart';

// Supabase configuration
const String supabaseUrl = 'https://zyycmxzabfadkyzpsper.supabase.co';
const String supabaseKey = ''; // Add your service role key here

void main() async {
  Logger.i('Applying Supabase schema...');

  // Check if the service role key is provided
  if (supabaseKey.isEmpty) {
    Logger.e('Supabase service role key is required. Please add it to the script.');
    exit(1);
  }

  // Initialize Supabase client
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  try {
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

    // Apply the schema SQL
    Logger.i('Applying schema SQL...');
    final schemaResponse = await supabase.rpc('exec_sql', params: {'sql': schemaSql});
    Logger.i('Schema SQL applied successfully');

    // Apply the RLS policies SQL
    Logger.i('Applying RLS policies SQL...');
    final rlsResponse = await supabase.rpc('exec_sql', params: {'sql': rlsSql});
    Logger.i('RLS policies SQL applied successfully');

    Logger.i('Supabase schema and RLS policies applied successfully');
  } catch (e) {
    Logger.e('Error applying Supabase schema: $e');
    exit(1);
  }
}
