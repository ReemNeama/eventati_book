import 'package:eventati_book/utils/database_utils.dart';

class Venue {
  final String id;
  final String name;
  final String description;
  final double rating;
  final List<String> venueTypes;
  final int minCapacity;
  final int maxCapacity;
  final double pricePerEvent;
  final String imageUrl;
  final List<String> imageUrls;
  final List<String> features;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Venue({
    this.id = '',
    required this.name,
    required this.description,
    required this.rating,
    required this.venueTypes,
    required this.minCapacity,
    required this.maxCapacity,
    required this.pricePerEvent,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.features,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a Venue from a database document
  factory Venue.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return Venue(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      venueTypes: List<String>.from(data['venueTypes'] ?? []),
      minCapacity: data['minCapacity'] ?? 0,
      maxCapacity: data['maxCapacity'] ?? 0,
      pricePerEvent: (data['pricePerEvent'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      imageUrls:
          data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : [],
      features: List<String>.from(data['features'] ?? []),
      userId: data['userId'],
      createdAt:
          data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      updatedAt:
          data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }

  /// Convert Venue to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'name': name,
      'description': description,
      'rating': rating,
      'venueTypes': venueTypes,
      'minCapacity': minCapacity,
      'maxCapacity': maxCapacity,
      'pricePerEvent': pricePerEvent,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'features': features,
      'userId': userId,
      'createdAt':
          createdAt != null
              ? DbTimestamp.fromDate(createdAt!).toIso8601String()
              : DbFieldValue.serverTimestamp(),
      'updatedAt': DbFieldValue.serverTimestamp(),
    };
  }

  /// Create a copy of the Venue with updated fields
  Venue copyWith({
    String? id,
    String? name,
    String? description,
    double? rating,
    List<String>? venueTypes,
    int? minCapacity,
    int? maxCapacity,
    double? pricePerEvent,
    String? imageUrl,
    List<String>? imageUrls,
    List<String>? features,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Venue(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      venueTypes: venueTypes ?? this.venueTypes,
      minCapacity: minCapacity ?? this.minCapacity,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      pricePerEvent: pricePerEvent ?? this.pricePerEvent,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      features: features ?? this.features,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
