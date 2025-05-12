import 'package:eventati_book/utils/database_utils.dart';

/// Service model representing a vendor service
class Service {
  /// Unique identifier for the service
  final String id;

  /// Name of the service
  final String name;

  /// Description of the service
  final String description;

  /// Category ID of the service
  final String categoryId;

  /// Vendor ID who provides this service
  final String vendorId;

  /// Price of the service
  final double price;

  /// Currency of the price (e.g., USD, EUR)
  final String currency;

  /// Whether the price is per hour
  final bool isPricePerHour;

  /// Minimum booking hours (if applicable)
  final int? minimumBookingHours;

  /// Maximum capacity (if applicable)
  final int? maximumCapacity;

  /// List of image URLs for the service
  final List<String> imageUrls;

  /// List of thumbnail URLs for the service
  final List<String> thumbnailUrls;

  /// Average rating of the service
  final double averageRating;

  /// Number of reviews for the service
  final int reviewCount;

  /// Location of the service (if applicable)
  final String? location;

  /// Whether the service is available for booking
  final bool isAvailable;

  /// Whether the service is featured
  final bool isFeatured;

  /// Tags associated with the service
  final List<String> tags;

  /// Creation date of the service
  final DateTime createdAt;

  /// Last update date of the service
  final DateTime updatedAt;

  /// Constructor
  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.vendorId,
    required this.price,
    this.currency = 'USD',
    this.isPricePerHour = false,
    this.minimumBookingHours,
    this.maximumCapacity,
    this.imageUrls = const [],
    this.thumbnailUrls = const [],
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.location,
    this.isAvailable = true,
    this.isFeatured = false,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a Service from JSON data
  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      categoryId: json['category_id'],
      vendorId: json['vendor_id'],
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      isPricePerHour: json['is_price_per_hour'] ?? false,
      minimumBookingHours: json['minimum_booking_hours'],
      maximumCapacity: json['maximum_capacity'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      thumbnailUrls: List<String>.from(json['thumbnail_urls'] ?? []),
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      location: json['location'],
      isAvailable: json['is_available'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Convert Service to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'vendor_id': vendorId,
      'price': price,
      'currency': currency,
      'is_price_per_hour': isPricePerHour,
      'minimum_booking_hours': minimumBookingHours,
      'maximum_capacity': maximumCapacity,
      'image_urls': imageUrls,
      'thumbnail_urls': thumbnailUrls,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'location': location,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a Service from a database document
  factory Service.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return Service(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['category_id'] ?? '',
      vendorId: data['vendor_id'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'USD',
      isPricePerHour: data['is_price_per_hour'] ?? false,
      minimumBookingHours: data['minimum_booking_hours'],
      maximumCapacity: data['maximum_capacity'],
      imageUrls:
          data['image_urls'] != null
              ? List<String>.from(data['image_urls'])
              : [],
      thumbnailUrls:
          data['thumbnail_urls'] != null
              ? List<String>.from(data['thumbnail_urls'])
              : [],
      averageRating: (data['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['review_count'] ?? 0,
      location: data['location'],
      isAvailable: data['is_available'] ?? true,
      isFeatured: data['is_featured'] ?? false,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
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

  /// Convert Service to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'name': name,
      'description': description,
      'category_id': categoryId,
      'vendor_id': vendorId,
      'price': price,
      'currency': currency,
      'is_price_per_hour': isPricePerHour,
      'minimum_booking_hours': minimumBookingHours,
      'maximum_capacity': maximumCapacity,
      'image_urls': imageUrls,
      'thumbnail_urls': thumbnailUrls,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'location': location,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'tags': tags,
      'created_at': DbTimestamp.fromDate(createdAt).toIso8601String(),
      'updated_at': DbTimestamp.fromDate(updatedAt).toIso8601String(),
    };
  }

  /// Create a copy of the Service with updated fields
  Service copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? vendorId,
    double? price,
    String? currency,
    bool? isPricePerHour,
    int? minimumBookingHours,
    int? maximumCapacity,
    List<String>? imageUrls,
    List<String>? thumbnailUrls,
    double? averageRating,
    int? reviewCount,
    String? location,
    bool? isAvailable,
    bool? isFeatured,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      vendorId: vendorId ?? this.vendorId,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isPricePerHour: isPricePerHour ?? this.isPricePerHour,
      minimumBookingHours: minimumBookingHours ?? this.minimumBookingHours,
      maximumCapacity: maximumCapacity ?? this.maximumCapacity,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnailUrls: thumbnailUrls ?? this.thumbnailUrls,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      location: location ?? this.location,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
