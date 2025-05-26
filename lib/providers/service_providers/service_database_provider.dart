import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/services/supabase/database/service_database_service.dart';
import 'package:eventati_book/utils/logger.dart';

/// Provider for service database operations
class ServiceDatabaseProvider extends ChangeNotifier {
  /// Service database service
  final ServiceDatabaseService _serviceDatabaseService;

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _error;

  /// Constructor
  ServiceDatabaseProvider({ServiceDatabaseService? serviceDatabaseService})
    : _serviceDatabaseService =
          serviceDatabaseService ?? ServiceDatabaseService();

  /// Get loading state
  bool get isLoading => _isLoading;

  /// Get error message
  String? get error => _error;

  /// Get service reviews
  Future<List<ServiceReview>> getServiceReviews(String serviceId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final reviews = await _serviceDatabaseService.getServiceReviews(
        serviceId,
      );

      _isLoading = false;
      notifyListeners();

      return reviews;
    } catch (e) {
      _error = 'Failed to get service reviews: ${e.toString()}';
      _isLoading = false;
      notifyListeners();

      Logger.e(_error!, tag: 'ServiceDatabaseProvider');
      return [];
    }
  }

  /// Add a service review
  Future<bool> addServiceReview(String serviceId, ServiceReview review) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _serviceDatabaseService.addServiceReview(serviceId, review);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Failed to add service review: ${e.toString()}';
      _isLoading = false;
      notifyListeners();

      Logger.e(_error!, tag: 'ServiceDatabaseProvider');
      return false;
    }
  }

  /// Delete a service review
  Future<bool> deleteServiceReview(String reviewId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _serviceDatabaseService.deleteServiceReview(reviewId);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Failed to delete service review: ${e.toString()}';
      _isLoading = false;
      notifyListeners();

      Logger.e(_error!, tag: 'ServiceDatabaseProvider');
      return false;
    }
  }

  /// Get a service by ID
  Future<Service?> getService(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final service = await _serviceDatabaseService.getService(id);

      _isLoading = false;
      notifyListeners();

      return service;
    } catch (e) {
      _error = 'Failed to get service: ${e.toString()}';
      _isLoading = false;
      notifyListeners();

      Logger.e(_error!, tag: 'ServiceDatabaseProvider');
      return null;
    }
  }

  /// Get a venue by ID
  Future<Service?> getVenue(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final venue = await _serviceDatabaseService.getVenue(id);

      _isLoading = false;
      notifyListeners();

      return venue;
    } catch (e) {
      _error = 'Failed to get venue: ${e.toString()}';
      _isLoading = false;
      notifyListeners();

      Logger.e(_error!, tag: 'ServiceDatabaseProvider');
      return null;
    }
  }
}
