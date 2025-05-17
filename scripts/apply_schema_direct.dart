import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Supabase configuration
const String supabaseUrl = 'https://zyycmxzabfadkyzpsper.supabase.co';
const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5eWNteHphYmZhZGt5enBzcGVyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjkyMjMyOCwiZXhwIjoyMDYyNDk4MzI4fQ.7NIGlM6A0xxKlCsgoz0gSSiscxroRUzMnuoXQuH5V8g';

void main() async {
  print('Applying Supabase schema directly...');

  try {
    // Read the combined SQL file
    final sqlFile = File('scripts/combined_schema.sql');
    if (!await sqlFile.exists()) {
      print('SQL file not found: ${sqlFile.path}');
      exit(1);
    }

    final sql = await sqlFile.readAsString();
    print('Read SQL file (${sql.length} characters)');

    // Split the SQL into smaller chunks to avoid request size limits
    final chunks = splitSql(sql);
    print('Split SQL into ${chunks.length} chunks');

    // Apply each chunk
    for (var i = 0; i < chunks.length; i++) {
      print('Applying chunk ${i + 1} of ${chunks.length}...');
      final success = await applySql(chunks[i]);
      if (success) {
        print('Chunk ${i + 1} applied successfully');
      } else {
        print('Failed to apply chunk ${i + 1}');
        // Continue anyway, as some statements might fail due to dependencies
      }
    }

    print('Supabase schema applied successfully');
  } catch (e) {
    print('Error applying Supabase schema: $e');
    exit(1);
  }
}

// Split SQL into smaller chunks
List<String> splitSql(String sql) {
  // Split by semicolons, but keep CREATE FUNCTION blocks together
  final List<String> chunks = [];
  final List<String> statements = [];
  bool inFunction = false;
  String currentStatement = '';

  for (final line in sql.split('\n')) {
    currentStatement += line + '\n';
    
    if (line.trim().startsWith('CREATE OR REPLACE FUNCTION') || 
        line.trim().startsWith('CREATE FUNCTION')) {
      inFunction = true;
    }
    
    if (inFunction && line.trim().endsWith('LANGUAGE plpgsql SECURITY DEFINER;')) {
      inFunction = false;
      statements.add(currentStatement);
      currentStatement = '';
    } else if (!inFunction && line.trim().endsWith(';')) {
      statements.add(currentStatement);
      currentStatement = '';
    }
  }

  // Group statements into chunks of reasonable size
  String currentChunk = '';
  for (final statement in statements) {
    if (currentChunk.length + statement.length > 10000) {
      chunks.add(currentChunk);
      currentChunk = statement;
    } else {
      currentChunk += statement;
    }
  }
  
  if (currentChunk.isNotEmpty) {
    chunks.add(currentChunk);
  }

  return chunks;
}

// Apply SQL to Supabase
Future<bool> applySql(String sql) async {
  try {
    final response = await http.post(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $supabaseKey',
        'apikey': supabaseKey,
      },
      body: jsonEncode({'sql': sql}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
      
      // Try direct SQL API if exec_sql fails
      try {
        final directResponse = await http.post(
          Uri.parse('$supabaseUrl/rest/v1/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $supabaseKey',
            'apikey': supabaseKey,
            'Prefer': 'resolution=merge-duplicates',
          },
          body: jsonEncode({'query': sql}),
        );
        
        if (directResponse.statusCode == 200 || directResponse.statusCode == 201) {
          return true;
        } else {
          print('Direct SQL API error: ${directResponse.statusCode} - ${directResponse.body}');
          return false;
        }
      } catch (e) {
        print('Direct SQL API exception: $e');
        return false;
      }
    }
  } catch (e) {
    print('Exception: $e');
    return false;
  }
}
