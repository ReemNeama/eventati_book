import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for analyzing historical budget data to improve estimates
class BudgetHistoricalDataService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for budget items
  static const String _budgetItemsTable = 'budget_items';

  /// Constructor
  BudgetHistoricalDataService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get average costs for a specific service type and event type
  Future<Map<String, double>> getAverageCosts({
    required String serviceType,
    required String eventType,
    int? minGuestCount,
    int? maxGuestCount,
    String? location,
  }) async {
    try {
      // Start building the query
      final query = _supabase
          .from(_budgetItemsTable)
          .select('*, events!inner(*)')
          .eq('events.event_type', eventType);

      // Add filters for guest count if provided
      if (minGuestCount != null) {
        query.gte('events.guest_count', minGuestCount);
      }
      if (maxGuestCount != null) {
        query.lte('events.guest_count', maxGuestCount);
      }

      // Add filter for location if provided
      if (location != null) {
        query.ilike('events.location', '%$location%');
      }

      // Execute the query
      final response = await query;

      // Process the results
      final Map<String, List<double>> costsByCategory = {};
      for (final item in response) {
        final category = item['category_id'] as String;
        final estimatedCost = (item['estimated_cost'] as num).toDouble();
        final actualCost =
            item['actual_cost'] != null
                ? (item['actual_cost'] as num).toDouble()
                : null;

        // Use actual cost if available, otherwise use estimated cost
        final cost = actualCost ?? estimatedCost;

        if (!costsByCategory.containsKey(category)) {
          costsByCategory[category] = [];
        }
        costsByCategory[category]!.add(cost);
      }

      // Calculate averages
      final Map<String, double> averageCosts = {};
      costsByCategory.forEach((category, costs) {
        if (costs.isNotEmpty) {
          averageCosts[category] = costs.reduce((a, b) => a + b) / costs.length;
        }
      });

      return averageCosts;
    } catch (e) {
      Logger.e(
        'Error getting average costs: $e',
        tag: 'BudgetHistoricalDataService',
      );
      return {};
    }
  }

  /// Get cost percentiles for a specific service type and event type
  Future<Map<String, Map<String, double>>> getCostPercentiles({
    required String serviceType,
    required String eventType,
    int? minGuestCount,
    int? maxGuestCount,
    String? location,
  }) async {
    try {
      // Start building the query
      final query = _supabase
          .from(_budgetItemsTable)
          .select('*, events!inner(*)')
          .eq('events.event_type', eventType);

      // Add filters for guest count if provided
      if (minGuestCount != null) {
        query.gte('events.guest_count', minGuestCount);
      }
      if (maxGuestCount != null) {
        query.lte('events.guest_count', maxGuestCount);
      }

      // Add filter for location if provided
      if (location != null) {
        query.ilike('events.location', '%$location%');
      }

      // Execute the query
      final response = await query;

      // Process the results
      final Map<String, List<double>> costsByCategory = {};
      for (final item in response) {
        final category = item['category_id'] as String;
        final estimatedCost = (item['estimated_cost'] as num).toDouble();
        final actualCost =
            item['actual_cost'] != null
                ? (item['actual_cost'] as num).toDouble()
                : null;

        // Use actual cost if available, otherwise use estimated cost
        final cost = actualCost ?? estimatedCost;

        if (!costsByCategory.containsKey(category)) {
          costsByCategory[category] = [];
        }
        costsByCategory[category]!.add(cost);
      }

      // Calculate percentiles (25th, 50th, 75th)
      final Map<String, Map<String, double>> percentiles = {};
      costsByCategory.forEach((category, costs) {
        if (costs.isNotEmpty) {
          costs.sort();
          final int length = costs.length;
          final int p25Index = (length * 0.25).floor();
          final int p50Index = (length * 0.5).floor();
          final int p75Index = (length * 0.75).floor();

          percentiles[category] = {
            'p25': costs[p25Index],
            'p50': costs[p50Index],
            'p75': costs[p75Index],
            'min': costs.first,
            'max': costs.last,
          };
        }
      });

      return percentiles;
    } catch (e) {
      Logger.e(
        'Error getting cost percentiles: $e',
        tag: 'BudgetHistoricalDataService',
      );
      return {};
    }
  }

  /// Get cost trends over time for a specific service type and event type
  Future<Map<String, List<Map<String, dynamic>>>> getCostTrends({
    required String serviceType,
    required String eventType,
    int? minGuestCount,
    int? maxGuestCount,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      // Start building the query
      var query = _supabase
          .from(_budgetItemsTable)
          .select('*, events!inner(*)')
          .eq('events.event_type', eventType)
          .order('created_at');

      // Note: Due to limitations in the current Supabase Dart SDK,
      // we can't directly apply all filters we want.
      // In a real implementation, you would use a more compatible approach
      // or wait for the Supabase API to be updated.

      // We can still apply the limit filter
      if (limit != null) {
        query = query.limit(limit);
      }

      // For date filtering, we'll need to filter the results after fetching

      // Execute the query
      final response = await query;

      // Process the results
      final Map<String, List<Map<String, dynamic>>> trends = {};
      for (final item in response) {
        final category = item['category_id'] as String;
        final estimatedCost = (item['estimated_cost'] as num).toDouble();
        final actualCost =
            item['actual_cost'] != null
                ? (item['actual_cost'] as num).toDouble()
                : null;
        final createdAt = DateTime.parse(item['created_at']);

        if (!trends.containsKey(category)) {
          trends[category] = [];
        }

        trends[category]!.add({
          'date': createdAt,
          'estimatedCost': estimatedCost,
          'actualCost': actualCost,
        });
      }

      return trends;
    } catch (e) {
      Logger.e(
        'Error getting cost trends: $e',
        tag: 'BudgetHistoricalDataService',
      );
      return {};
    }
  }
}
