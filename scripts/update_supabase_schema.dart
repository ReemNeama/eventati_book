import 'dart:io';
import 'utils/logger.dart';

// Configuration
const String modelsDir = 'lib/models';

// Model to table mapping
const Map<String, String> modelToTableMapping = {
  'user_models/user.dart': 'users',
  'service_models/service.dart': 'services',
  'service_models/booking.dart': 'bookings',
  'notification_models/notification.dart': 'notifications',
  'event_models/event.dart': 'events',
  'planning_models/task.dart': 'tasks',
  'planning_models/guest.dart': 'guests',
  'planning_models/budget_item.dart': 'budget_items',
  'event_models/wizard_state.dart': 'wizard_states',
  'event_models/wizard_connection.dart': 'wizard_connections',
  'service_models/service_review.dart': 'service_reviews',
  'service_models/payment.dart': 'payments',
};

// Type mapping from Dart to PostgreSQL
const Map<String, String> dartToPostgresTypeMapping = {
  'String': 'text',
  'int': 'integer',
  'double': 'numeric',
  'bool': 'boolean',
  'DateTime': 'timestamp with time zone',
  'Map<String, dynamic>': 'jsonb',
  'List<String>': 'text[]',
  'List<int>': 'integer[]',
  'List<double>': 'numeric[]',
};

// Convert camelCase to snake_case
String camelToSnake(String input) {
  return input.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (match) => '_${match.group(0)!.toLowerCase()}',
  );
}

// Class to represent a model field
class ModelField {
  final String name;
  final String type;
  final bool isNullable;

  ModelField({
    required this.name,
    required this.type,
    required this.isNullable,
  });

  String get snakeCaseName => camelToSnake(name);

  String get postgresType {
    String baseType = dartToPostgresTypeMapping[type] ?? 'text';

    // Handle List types that aren't in the mapping
    if (type.startsWith('List<') &&
        !dartToPostgresTypeMapping.containsKey(type)) {
      baseType = 'jsonb';
    }

    return baseType;
  }

  String get sqlDefinition {
    return '$snakeCaseName $postgresType${isNullable ? '' : ' NOT NULL'}';
  }

  @override
  String toString() {
    return '$type${isNullable ? '?' : ''} $name';
  }
}

// Parse model fields from file content (simplified)
List<ModelField> parseModelFields(String content) {
  final fields = <ModelField>[];
  final classRegex = RegExp(
    r'class\s+(\w+)\s+{([^}]*)}',
    multiLine: true,
    dotAll: true,
  );
  final fieldRegex = RegExp(
    r'final\s+([\w<>,\s]+)(\??)\s+(\w+)(?:\s*=\s*[^;]+)?;',
    multiLine: true,
  );

  final classMatch = classRegex.firstMatch(content);
  if (classMatch != null) {
    final classBody = classMatch.group(2)!;
    final fieldMatches = fieldRegex.allMatches(classBody);

    for (final match in fieldMatches) {
      final type = match.group(1)!.trim();
      final isNullable = match.group(2) == '?';
      final name = match.group(3)!;

      // Skip getters and computed properties
      if (!classBody.contains('get $name')) {
        fields.add(ModelField(name: name, type: type, isNullable: isNullable));
      }
    }
  }

  return fields;
}

// Generate SQL to create or update a table
String generateTableSQL(String tableName, List<ModelField> fields) {
  final buffer = StringBuffer();

  // Start with table creation
  buffer.writeln('-- SQL for table: $tableName');
  buffer.writeln('CREATE TABLE IF NOT EXISTS $tableName (');

  // Add id field if not present
  if (!fields.any((field) => field.name == 'id')) {
    buffer.writeln('  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),');
  } else {
    // Find the id field
    final idField = fields.firstWhere((field) => field.name == 'id');
    buffer.writeln('  ${idField.snakeCaseName} uuid PRIMARY KEY,');
  }

  // Add other fields
  for (int i = 0; i < fields.length; i++) {
    final field = fields[i];
    if (field.name != 'id') {
      buffer.write('  ${field.sqlDefinition}');
      if (i < fields.length - 1) {
        buffer.writeln(',');
      } else {
        buffer.writeln();
      }
    }
  }

  buffer.writeln(');');

  // Add alter table statements for existing tables
  buffer.writeln('\n-- Alter table statements to add missing columns:');
  for (final field in fields) {
    if (field.name != 'id') {
      buffer.writeln(
        'ALTER TABLE $tableName ADD COLUMN IF NOT EXISTS ${field.sqlDefinition};',
      );
    }
  }

  return buffer.toString();
}

// Main function
void main() async {
  Logger.i('Updating Supabase schema SQL...');

  final sqlBuffer = StringBuffer();
  sqlBuffer.writeln('-- SQL to update Supabase schema to match models');
  sqlBuffer.writeln('-- Generated on ${DateTime.now()}');
  sqlBuffer.writeln('\n-- Enable UUID extension if not already enabled');
  sqlBuffer.writeln('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";\n');

  // Process each model
  for (final entry in modelToTableMapping.entries) {
    final modelPath = entry.key;
    final tableName = entry.value;

    Logger.i('Processing model: $modelPath for table: $tableName');

    // Read model file
    final modelFile = File('$modelsDir/$modelPath');
    if (!await modelFile.exists()) {
      Logger.w('Model file not found: ${modelFile.path}');
      continue;
    }

    final modelContent = await modelFile.readAsString();

    // Parse model fields
    final fields = parseModelFields(modelContent);

    if (fields.isEmpty) {
      Logger.w('No fields found in model: $modelPath');
      continue;
    }

    Logger.i('Found ${fields.length} fields');
    for (final field in fields) {
      Logger.d('  ${field.toString()} -> ${field.sqlDefinition}');
    }

    // Generate SQL
    final sql = generateTableSQL(tableName, fields);
    sqlBuffer.writeln(sql);
    sqlBuffer.writeln('\n');
  }

  // Write SQL to file
  final sqlFile = File('scripts/supabase_schema.sql');
  await sqlFile.writeAsString(sqlBuffer.toString());

  Logger.i('SQL schema generated and saved to scripts/supabase_schema.sql');
}
