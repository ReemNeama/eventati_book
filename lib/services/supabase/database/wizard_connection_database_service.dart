import 'package:eventati_book/models/event_models/wizard_connection.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling wizard connection database operations with Supabase
class WizardConnectionDatabaseService {
  // No database service needed

  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for wizard connections
  static const String _wizardConnectionsTable = 'wizard_connections';

  /// Constructor
  WizardConnectionDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Save wizard connection to Supabase
  Future<void> saveWizardConnection(
    String userId,
    String eventId,
    Map<String, dynamic> connectionData,
  ) async {
    try {
      // Add user and event IDs to the data
      connectionData['user_id'] = userId;
      connectionData['event_id'] = eventId;

      // Check if the connection already exists
      final existingConnection =
          await _supabase
              .from(_wizardConnectionsTable)
              .select()
              .eq('user_id', userId)
              .eq('event_id', eventId)
              .maybeSingle();

      if (existingConnection != null) {
        // Update existing connection
        await _supabase
            .from(_wizardConnectionsTable)
            .update(connectionData)
            .eq('user_id', userId)
            .eq('event_id', eventId);
      } else {
        // Insert new connection
        await _supabase.from(_wizardConnectionsTable).insert(connectionData);
      }

      Logger.i(
        'Saved wizard connection for user: $userId, event: $eventId',
        tag: 'WizardConnectionDatabaseService',
      );
    } catch (e) {
      Logger.e(
        'Error saving wizard connection: $e',
        tag: 'WizardConnectionDatabaseService',
      );
      rethrow;
    }
  }

  /// Get wizard connection from Supabase
  Future<WizardConnection?> getWizardConnection(
    String userId,
    String eventId,
  ) async {
    try {
      final data =
          await _supabase
              .from(_wizardConnectionsTable)
              .select()
              .eq('user_id', userId)
              .eq('event_id', eventId)
              .maybeSingle();

      if (data == null) {
        Logger.i(
          'No wizard connection found for user: $userId, event: $eventId',
          tag: 'WizardConnectionDatabaseService',
        );
        return null;
      }

      return WizardConnection.fromJson(data);
    } catch (e) {
      Logger.e(
        'Error getting wizard connection: $e',
        tag: 'WizardConnectionDatabaseService',
      );
      return null;
    }
  }

  /// Delete wizard connection from Supabase
  Future<void> deleteWizardConnection(String userId, String eventId) async {
    try {
      await _supabase
          .from(_wizardConnectionsTable)
          .delete()
          .eq('user_id', userId)
          .eq('event_id', eventId);

      Logger.i(
        'Deleted wizard connection for user: $userId, event: $eventId',
        tag: 'WizardConnectionDatabaseService',
      );
    } catch (e) {
      Logger.e(
        'Error deleting wizard connection: $e',
        tag: 'WizardConnectionDatabaseService',
      );
      rethrow;
    }
  }

  /// Get all wizard connections for a user
  Future<List<WizardConnection>> getWizardConnectionsForUser(
    String userId,
  ) async {
    try {
      final data = await _supabase
          .from(_wizardConnectionsTable)
          .select()
          .eq('user_id', userId);

      return (data as List)
          .map((item) => WizardConnection.fromJson(item))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting wizard connections for user: $e',
        tag: 'WizardConnectionDatabaseService',
      );
      return [];
    }
  }
}
