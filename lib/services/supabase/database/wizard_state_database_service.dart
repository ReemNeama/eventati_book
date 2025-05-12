import 'package:eventati_book/models/event_models/event_template.dart';
import 'package:eventati_book/models/event_models/wizard_state.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling wizard state database operations with Supabase
class WizardStateDatabaseService {
  // No database service needed

  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for wizard states
  static const String _wizardStatesTable = 'wizard_states';

  /// Constructor
  WizardStateDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Save wizard state to Supabase
  Future<void> saveWizardState(WizardState wizardState) async {
    try {
      final data = wizardState.toJson();

      // Check if the wizard state already exists
      final existingState =
          await _supabase
              .from(_wizardStatesTable)
              .select()
              .eq('id', wizardState.id)
              .maybeSingle();

      if (existingState != null) {
        // Update existing state
        await _supabase
            .from(_wizardStatesTable)
            .update(data)
            .eq('id', wizardState.id);
      } else {
        // Insert new state
        await _supabase.from(_wizardStatesTable).insert(data);
      }

      Logger.i(
        'Saved wizard state: ${wizardState.id}',
        tag: 'WizardStateDatabaseService',
      );
    } catch (e) {
      Logger.e(
        'Error saving wizard state: $e',
        tag: 'WizardStateDatabaseService',
      );
      rethrow;
    }
  }

  /// Get wizard state from Supabase
  Future<WizardState?> getWizardState(String id) async {
    try {
      final data =
          await _supabase
              .from(_wizardStatesTable)
              .select()
              .eq('id', id)
              .maybeSingle();

      if (data == null) {
        Logger.i(
          'No wizard state found with id: $id',
          tag: 'WizardStateDatabaseService',
        );
        return null;
      }

      return WizardState.fromJson(data);
    } catch (e) {
      Logger.e(
        'Error getting wizard state: $e',
        tag: 'WizardStateDatabaseService',
      );
      return null;
    }
  }

  /// Delete wizard state from Supabase
  Future<void> deleteWizardState(String id) async {
    try {
      await _supabase.from(_wizardStatesTable).delete().eq('id', id);

      Logger.i('Deleted wizard state: $id', tag: 'WizardStateDatabaseService');
    } catch (e) {
      Logger.e(
        'Error deleting wizard state: $e',
        tag: 'WizardStateDatabaseService',
      );
      rethrow;
    }
  }

  /// Get all wizard states for a user
  Future<List<WizardState>> getWizardStatesForUser(String userId) async {
    try {
      final data = await _supabase
          .from(_wizardStatesTable)
          .select()
          .eq('user_id', userId);

      final result = <WizardState>[];
      for (final item in data) {
        final state = WizardState.fromJson(item);
        if (state != null) {
          result.add(state);
        }
      }

      return result;
    } catch (e) {
      Logger.e(
        'Error getting wizard states for user: $e',
        tag: 'WizardStateDatabaseService',
      );
      return [];
    }
  }

  /// Get wizard state by event template
  Future<WizardState?> getWizardStateByTemplate(
    String userId,
    EventTemplate template,
  ) async {
    try {
      final data =
          await _supabase
              .from(_wizardStatesTable)
              .select()
              .eq('user_id', userId)
              .eq('template_id', template.id)
              .maybeSingle();

      if (data == null) {
        Logger.i(
          'No wizard state found for template: ${template.id}',
          tag: 'WizardStateDatabaseService',
        );
        return null;
      }

      return WizardState.fromJson(data);
    } catch (e) {
      Logger.e(
        'Error getting wizard state by template: $e',
        tag: 'WizardStateDatabaseService',
      );
      return null;
    }
  }
}
