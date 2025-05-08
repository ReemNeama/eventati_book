import 'package:cloud_firestore/cloud_firestore.dart';

class CateringService {
  final String id;
  final String name;
  final String description;
  final double rating;
  final List<String> cuisineTypes;
  final int minCapacity;
  final int maxCapacity;
  final double pricePerPerson;
  final String imageUrl;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CateringService({
    this.id = '',
    required this.name,
    required this.description,
    required this.rating,
    required this.cuisineTypes,
    required this.minCapacity,
    required this.maxCapacity,
    required this.pricePerPerson,
    required this.imageUrl,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a CateringService from a Firestore document
  factory CateringService.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data was null');
    }

    return CateringService(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      cuisineTypes: List<String>.from(data['cuisineTypes'] ?? []),
      minCapacity: data['minCapacity'] ?? 0,
      maxCapacity: data['maxCapacity'] ?? 0,
      pricePerPerson: (data['pricePerPerson'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      userId: data['userId'],
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  /// Convert CateringService to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'rating': rating,
      'cuisineTypes': cuisineTypes,
      'minCapacity': minCapacity,
      'maxCapacity': maxCapacity,
      'pricePerPerson': pricePerPerson,
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy of the CateringService with updated fields
  CateringService copyWith({
    String? id,
    String? name,
    String? description,
    double? rating,
    List<String>? cuisineTypes,
    int? minCapacity,
    int? maxCapacity,
    double? pricePerPerson,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CateringService(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      minCapacity: minCapacity ?? this.minCapacity,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
