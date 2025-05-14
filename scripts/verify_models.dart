import 'dart:io';

import 'package:supabase/supabase.dart';
import 'utils/logger.dart';
import 'package:path/path.dart' as path;

// Configuration
const String supabaseUrl = 'https://zyycmxzabfadkyzpsper.supabase.co';
const String supabaseKey = 'YOUR_SUPABASE_KEY'; // Replace with your key
const String modelsDir = 'lib/models';

// Table to model mapping
const Map<String, String> tableToModelMapping = {
  'users': 'user_models/user.dart',
  'services': 'service_models/service.dart',
  'bookings': 'service_models/booking.dart',
  'notifications': 'notification_models/notification.dart',
  'events': 'event_models/event.dart',
  'tasks': 'planning_models/task.dart',
  'guests': 'planning_models/guest.dart',
  'budget_items': 'planning_models/budget_item.dart',
  'wizard_states': 'event_models/wizard_state.dart',
  'wizard_connections': 'event_models/wizard_connection.dart',
  'service_reviews': 'service_models/service_review.dart',
  'payments': 'service_models/payment.dart',
};

// Type mapping from Postgres to Dart
const Map<String, String> typeMapping = {
  'uuid': 'String',
  'text': 'String',
  'integer': 'int',
  'numeric': 'double',
  'boolean': 'bool',
  'timestamp with time zone': 'DateTime',
  'jsonb': 'Map<String, dynamic>',
};

// Convert snake_case to camelCase
String snakeToCamel(String input) {
  return input.replaceAllMapped(
    RegExp(r'_([a-z])'),
    (match) => match.group(1)!.toUpperCase(),
  );
}

// Convert camelCase to snake_case
String camelToSnake(String input) {
  return input.replaceAllMapped(
    RegExp(r'[A-Z]'),
    (match) => '_${match.group(0)!.toLowerCase()}',
  );
}

// Class to represent a database column
class ColumnInfo {
  final String name;
  final String dataType;
  final bool isNullable;

  ColumnInfo({
    required this.name,
    required this.dataType,
    required this.isNullable,
  });

  String get dartType {
    final baseType = typeMapping[dataType] ?? 'dynamic';
    return isNullable ? '$baseType?' : baseType;
  }

  String get camelCaseName => snakeToCamel(name);

  @override
  String toString() {
    return '$dartType $camelCaseName';
  }
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

  @override
  String toString() {
    return '$type $name';
  }
}

// Main function
Future<void> main() async {
  Logger.i('Starting model verification...');

  // Create Supabase client
  final supabase = SupabaseClient(supabaseUrl, supabaseKey);

  // Get all tables and their schemas
  for (final entry in tableToModelMapping.entries) {
    final tableName = entry.key;
    final modelPath = entry.value;

    Logger.i('Checking table: $tableName against model: $modelPath');

    try {
      // Get table schema
      final response = await supabase.rpc(
        'get_table_schema',
        params: {'table_name': tableName},
      );

      if (response.error != null) {
        Logger.e(
          'Error getting schema for $tableName: ${response.error!.message}',
        );
        continue;
      }

      final columns =
          (response.data as List)
              .map(
                (col) => ColumnInfo(
                  name: col['column_name'],
                  dataType: col['data_type'],
                  isNullable: col['is_nullable'] == 'YES',
                ),
              )
              .toList();

      // Read model file
      final modelFile = File(path.join(modelsDir, modelPath));
      if (!await modelFile.exists()) {
        Logger.w('Model file not found: ${modelFile.path}');
        continue;
      }

      final modelContent = await modelFile.readAsString();

      // Parse model fields (simplified approach)
      final modelFields = parseModelFields(modelContent);

      // Compare and generate updates
      final updates = compareAndGenerateUpdates(columns, modelFields);

      if (updates.isEmpty) {
        Logger.i('Model is up-to-date with the database schema.');
      } else {
        Logger.w('Model needs updates:');
        for (final update in updates) {
          Logger.w('  - $update');
        }

        // Apply updates if needed
        final updatedContent = applyUpdates(modelContent, updates);
        if (updatedContent != modelContent) {
          await modelFile.writeAsString(updatedContent);
          Logger.i('Model updated successfully.');
        }
      }
    } catch (e) {
      Logger.e('Error processing $tableName: $e');
    }
  }

  Logger.i('Model verification completed.');
}

// Parse model fields from file content (simplified)
List<ModelField> parseModelFields(String content) {
  final fields = <ModelField>[];
  final classRegex = RegExp(r'class\s+(\w+)\s+{([^}]*)}', multiLine: true);
  final fieldRegex = RegExp(
    r'final\s+(\w+(?:<[^>]+>)?)\??\s+(\w+)(?:\s*=\s*[^;]+)?;',
    multiLine: true,
  );

  final classMatch = classRegex.firstMatch(content);
  if (classMatch != null) {
    final classBody = classMatch.group(2)!;
    final fieldMatches = fieldRegex.allMatches(classBody);

    for (final match in fieldMatches) {
      final type = match.group(1)!;
      final name = match.group(2)!;
      final isNullable = type.endsWith('?');
      fields.add(
        ModelField(
          name: name,
          type: isNullable ? type.substring(0, type.length - 1) : type,
          isNullable: isNullable,
        ),
      );
    }
  }

  return fields;
}

// Compare database columns with model fields and generate updates
List<String> compareAndGenerateUpdates(
  List<ColumnInfo> columns,
  List<ModelField> fields,
) {
  final updates = <String>[];

  // Check for missing fields
  for (final column in columns) {
    final matchingField = fields.firstWhere(
      (field) =>
          field.name == column.camelCaseName ||
          field.snakeCaseName == column.name,
      orElse: () => ModelField(name: '', type: '', isNullable: false),
    );

    if (matchingField.name.isEmpty) {
      updates.add(
        'Add missing field: ${column.dartType} ${column.camelCaseName}',
      );
    } else if (matchingField.type != typeMapping[column.dataType]) {
      updates.add(
        'Update field type: ${matchingField.name} from ${matchingField.type} to ${column.dartType}',
      );
    } else if (matchingField.isNullable != column.isNullable) {
      updates.add(
        'Update nullability: ${matchingField.name} should be ${column.isNullable ? 'nullable' : 'non-nullable'}',
      );
    }
  }

  return updates;
}

// Apply updates to model content
String applyUpdates(String content, List<String> updates) {
  // This is a simplified implementation
  // In a real implementation, you would parse the file and make specific changes

  // For now, we'll just add comments about needed updates
  if (updates.isNotEmpty) {
    final updateComments = updates.map((u) => '// TODO: $u').join('\n');
    return '$content\n\n// Model needs updates:\n$updateComments\n';
  }

  return content;
}
