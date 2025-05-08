import 'package:cloud_firestore/cloud_firestore.dart';

class Photographer {
  final String id;
  final String name;
  final String description;
  final double rating;
  final List<String> styles;
  final double pricePerEvent;
  final String imageUrl;
  final List<String> equipment;
  final List<String> packages;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Photographer({
    this.id = '',
    required this.name,
    required this.description,
    required this.rating,
    required this.styles,
    required this.pricePerEvent,
    required this.imageUrl,
    required this.equipment,
    required this.packages,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a Photographer from a Firestore document
  factory Photographer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data was null');
    }

    return Photographer(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      styles: List<String>.from(data['styles'] ?? []),
      pricePerEvent: (data['pricePerEvent'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      equipment: List<String>.from(data['equipment'] ?? []),
      packages: List<String>.from(data['packages'] ?? []),
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

  /// Convert Photographer to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'rating': rating,
      'styles': styles,
      'pricePerEvent': pricePerEvent,
      'imageUrl': imageUrl,
      'equipment': equipment,
      'packages': packages,
      'userId': userId,
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy of the Photographer with updated fields
  Photographer copyWith({
    String? id,
    String? name,
    String? description,
    double? rating,
    List<String>? styles,
    double? pricePerEvent,
    String? imageUrl,
    List<String>? equipment,
    List<String>? packages,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Photographer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      styles: styles ?? this.styles,
      pricePerEvent: pricePerEvent ?? this.pricePerEvent,
      imageUrl: imageUrl ?? this.imageUrl,
      equipment: equipment ?? this.equipment,
      packages: packages ?? this.packages,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
