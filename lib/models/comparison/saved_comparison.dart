import 'package:eventati_book/models/models.dart';

/// A model representing a saved comparison
class SavedComparison {
  /// The unique ID of the saved comparison
  final String id;

  /// The ID of the user who saved the comparison
  final String userId;

  /// The type of service being compared (Venue, Catering, Photographer, Planner)
  final String serviceType;

  /// The IDs of the services being compared
  final List<ServiceReference> services;

  /// The name of the saved comparison
  final String name;

  /// An optional description of the saved comparison
  final String? description;

  /// When the comparison was created
  final DateTime createdAt;

  /// A token for sharing the comparison
  final String? sharingToken;

  /// Constructor
  SavedComparison({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.services,
    required this.name,
    this.description,
    required this.createdAt,
    this.sharingToken,
  });

  /// Create a SavedComparison from JSON
  factory SavedComparison.fromJson(Map<String, dynamic> json) {
    return SavedComparison(
      id: json['id'],
      userId: json['user_id'],
      serviceType: json['service_type'],
      services:
          (json['services'] as List)
              .map((service) => ServiceReference.fromJson(service))
              .toList(),
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      sharingToken: json['sharing_token'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'service_type': serviceType,
      'services': services.map((service) => service.toJson()).toList(),
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'sharing_token': sharingToken,
    };
  }
}

/// A reference to a service in a saved comparison
class ServiceReference {
  /// The ID of the service
  final String id;

  /// The name of the service
  final String name;

  /// The type of service (Venue, Catering, Photographer, Planner)
  final String type;

  /// Constructor
  ServiceReference({required this.id, required this.name, required this.type});

  /// Create a ServiceReference from JSON
  factory ServiceReference.fromJson(Map<String, dynamic> json) {
    return ServiceReference(
      id: json['id'],
      name: json['name'],
      type: json['type'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'type': type};
  }
}
