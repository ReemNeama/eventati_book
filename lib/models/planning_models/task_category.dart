import 'package:flutter/material.dart';
import 'package:eventati_book/utils/database_utils.dart';
import 'package:eventati_book/styles/app_colors.dart';

/// Task category model
class TaskCategory {
  /// Unique identifier for the category
  final String id;

  /// Name of the category
  final String name;

  /// Description of the category
  final String description;

  /// Icon name for the category
  final String icon;

  /// Color code for the category
  final String color;

  /// Order of the category in the list
  final int order;

  /// Whether the category is a default category
  final bool isDefault;

  /// Whether the category is active
  final bool isActive;

  /// Creation date of the category
  final DateTime createdAt;

  /// Last update date of the category
  final DateTime updatedAt;

  /// Constructor
  TaskCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.order = 0,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a TaskCategory from JSON data
  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      order: json['order'] ?? 0,
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Convert TaskCategory to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'order': order,
      'is_default': isDefault,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a TaskCategory from a database document
  factory TaskCategory.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return TaskCategory(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? 'task',
      color: data['color'] ?? '#4285F4',
      order: data['order'] ?? 0,
      isDefault: data['is_default'] ?? false,
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

  /// Convert TaskCategory to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'order': order,
      'is_default': isDefault,
      'is_active': isActive,
      'created_at': DbTimestamp.fromDate(createdAt).toIso8601String(),
      'updated_at': DbTimestamp.fromDate(updatedAt).toIso8601String(),
    };
  }

  /// Create a copy of the TaskCategory with updated fields
  TaskCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? color,
    int? order,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the color as a Flutter Color object
  Color getColorObject() {
    try {
      if (color.startsWith('#')) {
        return Color(int.parse('0xFF${color.substring(1)}'));
      } else {
        return AppColors.primary;
      }
    } catch (e) {
      return AppColors.primary;
    }
  }

  /// Get the icon as a Flutter IconData object
  IconData getIconData() {
    switch (icon) {
      case 'task_alt':
        return Icons.task_alt;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'location_on':
        return Icons.location_on;
      case 'restaurant':
        return Icons.restaurant;
      case 'mail':
        return Icons.mail;
      case 'celebration':
        return Icons.celebration;
      case 'brush':
        return Icons.brush;
      case 'music_note':
        return Icons.music_note;
      case 'people':
        return Icons.people;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'cake':
        return Icons.cake;
      case 'local_florist':
        return Icons.local_florist;
      case 'directions_car':
        return Icons.directions_car;
      case 'attach_money':
        return Icons.attach_money;
      case 'event':
        return Icons.event;
      default:
        return Icons.task_alt;
    }
  }
}
