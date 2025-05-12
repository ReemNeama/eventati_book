import 'package:flutter/material.dart';
import 'package:eventati_book/utils/database_utils.dart';

/// Service category model
class ServiceCategory {
  /// Unique identifier for the category
  final String id;

  /// Name of the category
  final String name;

  /// Description of the category
  final String description;

  /// Icon name for the category
  final String icon;

  /// Image URL for the category
  final String? imageUrl;

  /// Order of the category in the list
  final int order;

  /// Whether the category is active
  final bool isActive;

  /// Creation date of the category
  final DateTime createdAt;

  /// Last update date of the category
  final DateTime updatedAt;

  /// Constructor
  ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.imageUrl,
    this.order = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a ServiceCategory from JSON data
  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      imageUrl: json['image_url'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Convert ServiceCategory to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'image_url': imageUrl,
      'order': order,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a ServiceCategory from a database document
  factory ServiceCategory.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return ServiceCategory(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? 'category',
      imageUrl: data['image_url'],
      order: data['order'] ?? 0,
      isActive: data['is_active'] ?? true,
      createdAt:
          data['created_at'] != null
              ? DateTime.parse(data['created_at'])
              : DateTime.now(),
      updatedAt:
          data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : DateTime.now(),
    );
  }

  /// Convert ServiceCategory to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'image_url': imageUrl,
      'order': order,
      'is_active': isActive,
      'created_at': DbTimestamp.fromDate(createdAt).toIso8601String(),
      'updated_at': DbTimestamp.fromDate(updatedAt).toIso8601String(),
    };
  }

  /// Create a copy of the ServiceCategory with updated fields
  ServiceCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? imageUrl,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the icon as a Flutter IconData object
  IconData getIconData() {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'location_on':
        return Icons.location_on;
      case 'event':
        return Icons.event;
      case 'music_note':
        return Icons.music_note;
      case 'cake':
        return Icons.cake;
      case 'local_florist':
        return Icons.local_florist;
      case 'directions_car':
        return Icons.directions_car;
      case 'celebration':
        return Icons.celebration;
      case 'people':
        return Icons.people;
      case 'videocam':
        return Icons.videocam;
      case 'mic':
        return Icons.mic;
      case 'local_bar':
        return Icons.local_bar;
      case 'hotel':
        return Icons.hotel;
      case 'security':
        return Icons.security;
      default:
        return Icons.category;
    }
  }
}
