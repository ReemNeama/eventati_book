import 'package:eventati_book/models/service_models/service.dart';
import 'package:eventati_book/models/service_models/service_category.dart';
import 'package:eventati_book/models/service_models/service_review.dart';
import 'package:eventati_book/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling service-related database operations with Supabase
class ServiceDatabaseService {
  /// Supabase client
  final SupabaseClient _supabase;

  /// Table name for services
  static const String _servicesTable = 'services';

  /// Table name for service categories
  static const String _categoriesTable = 'service_categories';

  /// Table name for service reviews
  static const String _reviewsTable = 'service_reviews';

  /// Constructor
  ServiceDatabaseService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  /// Get all services
  Future<List<Service>> getServices() async {
    try {
      final response = await _supabase.from(_servicesTable).select();

      return response.map<Service>((data) => Service.fromJson(data)).toList();
    } catch (e) {
      Logger.e('Error getting services: $e', tag: 'ServiceDatabaseService');
      return [];
    }
  }

  /// Get a service by ID
  Future<Service?> getService(String id) async {
    try {
      final response =
          await _supabase
              .from(_servicesTable)
              .select()
              .eq('id', id)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return Service.fromJson(response);
    } catch (e) {
      Logger.e('Error getting service: $e', tag: 'ServiceDatabaseService');
      return null;
    }
  }

  /// Get a venue by ID
  Future<Service?> getVenue(String id) async {
    try {
      final response =
          await _supabase.from('venues').select().eq('id', id).maybeSingle();

      if (response == null) {
        return null;
      }

      return Service.fromJson(response);
    } catch (e) {
      Logger.e('Error getting venue: $e', tag: 'ServiceDatabaseService');
      return null;
    }
  }

  /// Get services by category
  Future<List<Service>> getServicesByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from(_servicesTable)
          .select()
          .eq('category_id', categoryId);

      return response.map<Service>((data) => Service.fromJson(data)).toList();
    } catch (e) {
      Logger.e(
        'Error getting services by category: $e',
        tag: 'ServiceDatabaseService',
      );
      return [];
    }
  }

  /// Get all service categories
  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      final response = await _supabase.from(_categoriesTable).select();

      return response
          .map<ServiceCategory>(
            (data) => ServiceCategory(
              id: data['id'] as String,
              name: data['name'] as String,
              description: data['description'] as String? ?? '',
              icon: data['icon'] as String? ?? 'category',
              imageUrl: data['image_url'] as String?,
              order: data['order'] as int? ?? 0,
              isActive: data['is_active'] as bool? ?? true,
              createdAt: DateTime.parse(
                data['created_at'] as String? ??
                    DateTime.now().toIso8601String(),
              ),
              updatedAt: DateTime.parse(
                data['updated_at'] as String? ??
                    DateTime.now().toIso8601String(),
              ),
            ),
          )
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting service categories: $e',
        tag: 'ServiceDatabaseService',
      );
      return [];
    }
  }

  /// Get a service category by ID
  Future<ServiceCategory?> getServiceCategory(String id) async {
    try {
      final response =
          await _supabase
              .from(_categoriesTable)
              .select()
              .eq('id', id)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return ServiceCategory(
        id: response['id'] as String,
        name: response['name'] as String,
        description: response['description'] as String? ?? '',
        icon: response['icon'] as String? ?? 'category',
        imageUrl: response['image_url'] as String?,
        order: response['order'] as int? ?? 0,
        isActive: response['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(
          response['created_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          response['updated_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      Logger.e(
        'Error getting service category: $e',
        tag: 'ServiceDatabaseService',
      );
      return null;
    }
  }

  /// Get reviews for a service
  Future<List<ServiceReview>> getServiceReviews(String serviceId) async {
    try {
      final response = await _supabase
          .from(_reviewsTable)
          .select()
          .eq('service_id', serviceId);

      return response
          .map<ServiceReview>((data) => ServiceReview.fromJson(data))
          .toList();
    } catch (e) {
      Logger.e(
        'Error getting service reviews: $e',
        tag: 'ServiceDatabaseService',
      );
      return [];
    }
  }

  /// Add a review for a service
  Future<void> addServiceReview(String serviceId, ServiceReview review) async {
    try {
      final data = review.toJson();
      data['service_id'] = serviceId;

      // Check if review already exists
      final existingReview =
          await _supabase
              .from(_reviewsTable)
              .select()
              .eq('id', review.id)
              .maybeSingle();

      if (existingReview != null) {
        // Update existing review
        await _supabase.from(_reviewsTable).update(data).eq('id', review.id);

        Logger.i(
          'Updated review for service: $serviceId',
          tag: 'ServiceDatabaseService',
        );
      } else {
        // Insert new review
        await _supabase.from(_reviewsTable).insert(data);

        Logger.i(
          'Added review for service: $serviceId',
          tag: 'ServiceDatabaseService',
        );
      }

      // Update service average rating
      await _updateServiceAverageRating(serviceId);
    } catch (e) {
      Logger.e(
        'Error adding service review: $e',
        tag: 'ServiceDatabaseService',
      );
      rethrow;
    }
  }

  /// Delete a review for a service
  Future<void> deleteServiceReview(String reviewId) async {
    try {
      // Get the review to find the service ID
      final review =
          await _supabase
              .from(_reviewsTable)
              .select()
              .eq('id', reviewId)
              .single();

      final serviceId = review['service_id'] as String;

      // Delete the review
      await _supabase.from(_reviewsTable).delete().eq('id', reviewId);

      Logger.i('Deleted review: $reviewId', tag: 'ServiceDatabaseService');

      // Update service average rating
      await _updateServiceAverageRating(serviceId);
    } catch (e) {
      Logger.e(
        'Error deleting service review: $e',
        tag: 'ServiceDatabaseService',
      );
      rethrow;
    }
  }

  /// Update the average rating for a service
  Future<void> _updateServiceAverageRating(String serviceId) async {
    try {
      // Get all reviews for the service
      final reviews = await getServiceReviews(serviceId);

      if (reviews.isEmpty) {
        // No reviews, set rating to 0
        await _supabase
            .from(_servicesTable)
            .update({'average_rating': 0.0, 'review_count': 0})
            .eq('id', serviceId);
        return;
      }

      // Calculate average rating
      final totalRating = reviews.fold<double>(
        0.0,
        (sum, review) => sum + review.rating,
      );
      final averageRating = totalRating / reviews.length;

      // Update service
      await _supabase
          .from(_servicesTable)
          .update({
            'average_rating': averageRating,
            'review_count': reviews.length,
          })
          .eq('id', serviceId);

      Logger.i(
        'Updated average rating for service: $serviceId',
        tag: 'ServiceDatabaseService',
      );
    } catch (e) {
      Logger.e(
        'Error updating service average rating: $e',
        tag: 'ServiceDatabaseService',
      );
      // Don't rethrow, this is a background operation
    }
  }

  /// Search services by name or description
  Future<List<Service>> searchServices(String query) async {
    try {
      final response = await _supabase
          .from(_servicesTable)
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%');

      return response.map<Service>((data) => Service.fromJson(data)).toList();
    } catch (e) {
      Logger.e('Error searching services: $e', tag: 'ServiceDatabaseService');
      return [];
    }
  }

  /// Filter services by multiple criteria
  Future<List<Service>> filterServices({
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? location,
  }) async {
    try {
      var query = _supabase.from(_servicesTable).select();

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }

      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }

      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      if (location != null) {
        query = query.eq('location', location);
      }

      final response = await query;

      return response.map<Service>((data) => Service.fromJson(data)).toList();
    } catch (e) {
      Logger.e('Error filtering services: $e', tag: 'ServiceDatabaseService');
      return [];
    }
  }
}
