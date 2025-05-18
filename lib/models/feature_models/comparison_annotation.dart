import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:eventati_book/styles/app_colors.dart';


/// Model representing an annotation or highlight in a comparison
class ComparisonAnnotation {
  /// Unique identifier for the annotation
  final String id;

  /// Title or label for the annotation
  final String title;

  /// Content or text of the annotation
  final String content;

  /// Service ID that this annotation is associated with (optional)
  final String? serviceId;

  /// Feature or aspect that this annotation is highlighting (optional)
  final String? feature;

  /// Color of the highlight (stored as ARGB value)
  final int colorValue;

  /// Creation timestamp
  final DateTime createdAt;

  /// Constructor
  ComparisonAnnotation({
    String? id,
    required this.title,
    required this.content,
    this.serviceId,
    this.feature,
    Color? color,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       colorValue = color?.toARGB32() ?? AppColors.warning.toARGB32(),
       createdAt = createdAt ?? DateTime.now();

  /// Get the color as a Color object
  Color get color => Color(colorValue);

  /// Create a copy of this annotation with the given fields replaced with new values
  ComparisonAnnotation copyWith({
    String? title,
    String? content,
    String? serviceId,
    String? feature,
    Color? color,
  }) {
    return ComparisonAnnotation(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      serviceId: serviceId ?? this.serviceId,
      feature: feature ?? this.feature,
      color: color ?? Color(colorValue),
      createdAt: createdAt,
    );
  }

  /// Convert the annotation to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'serviceId': serviceId,
      'feature': feature,
      'colorValue': colorValue,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Create an annotation from a map
  factory ComparisonAnnotation.fromMap(Map<String, dynamic> map) {
    return ComparisonAnnotation(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      serviceId: map['serviceId'],
      feature: map['feature'],
      color: Color(map['colorValue']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  /// Convert the annotation to a JSON string
  String toJson() => map2Json(toMap());

  /// Create an annotation from a JSON string
  factory ComparisonAnnotation.fromJson(String source) =>
      ComparisonAnnotation.fromMap(json2Map(source));

  @override
  String toString() {
    return 'ComparisonAnnotation(id: $id, title: $title, content: $content, '
        'serviceId: $serviceId, feature: $feature, colorValue: $colorValue, '
        'createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ComparisonAnnotation &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.serviceId == serviceId &&
        other.feature == feature &&
        other.colorValue == colorValue &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        serviceId.hashCode ^
        feature.hashCode ^
        colorValue.hashCode ^
        createdAt.hashCode;
  }
}

/// Helper function to convert a map to a JSON string
/// This is a placeholder that should be replaced with the actual implementation
String map2Json(Map<String, dynamic> map) {
  // In a real implementation, this would use jsonEncode
  return map.toString();
}

/// Helper function to convert a JSON string to a map
/// This is a placeholder that should be replaced with the actual implementation
Map<String, dynamic> json2Map(String source) {
  // In a real implementation, this would use jsonDecode
  return {'id': 'placeholder'};
}
