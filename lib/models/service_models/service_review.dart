import 'package:eventati_book/utils/database_utils.dart';

/// Service review model
class ServiceReview {
  /// Unique identifier for the review
  final String id;

  /// ID of the service being reviewed
  final String serviceId;

  /// ID of the user who wrote the review
  final String userId;

  /// Name of the user who wrote the review
  final String userName;

  /// Rating given (1-5)
  final double rating;

  /// Review text
  final String comment;

  /// List of image URLs for the review
  final List<String> imageUrls;

  /// Whether the review is verified (user actually used the service)
  final bool isVerified;

  /// Creation date of the review
  final DateTime createdAt;

  /// Last update date of the review
  final DateTime updatedAt;

  /// Constructor
  ServiceReview({
    required this.id,
    required this.serviceId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a ServiceReview from JSON data
  factory ServiceReview.fromJson(Map<String, dynamic> json) {
    return ServiceReview(
      id: json['id'],
      serviceId: json['service_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Convert ServiceReview to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': serviceId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'image_urls': imageUrls,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a ServiceReview from a database document
  factory ServiceReview.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return ServiceReview(
      id: doc.id,
      serviceId: data['service_id'] ?? '',
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] ?? '',
      imageUrls:
          data['image_urls'] != null
              ? List<String>.from(data['image_urls'])
              : [],
      isVerified: data['is_verified'] ?? false,
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

  /// Convert ServiceReview to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'service_id': serviceId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'image_urls': imageUrls,
      'is_verified': isVerified,
      'created_at': DbTimestamp.fromDate(createdAt).toIso8601String(),
      'updated_at': DbTimestamp.fromDate(updatedAt).toIso8601String(),
    };
  }

  /// Create a copy of the ServiceReview with updated fields
  ServiceReview copyWith({
    String? id,
    String? serviceId,
    String? userId,
    String? userName,
    double? rating,
    String? comment,
    List<String>? imageUrls,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceReview(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
