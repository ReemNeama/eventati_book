/// A review for a service
class ServiceReview {
  /// Unique identifier for the review
  final String id;

  /// ID of the service being reviewed
  final String serviceId;

  /// ID of the user who wrote the review
  final String userId;

  /// Name of the user who wrote the review
  final String userName;

  /// Rating (1-5)
  final double rating;

  /// Review text
  final String comment;

  /// Optional images attached to the review
  final List<String> imageUrls;

  /// Whether the review is from a verified purchase/booking
  final bool isVerified;

  /// When the review was created
  final DateTime createdAt;

  /// When the review was last updated
  final DateTime updatedAt;

  /// Constructor
  const ServiceReview({
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

  /// Create a ServiceReview from a JSON map
  factory ServiceReview.fromJson(Map<String, dynamic> json) {
    return ServiceReview(
      id: json['id'] as String,
      serviceId: json['service_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      imageUrls:
          (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Convert the ServiceReview to a JSON map
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

  /// Create a copy of this ServiceReview with the given fields replaced
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
