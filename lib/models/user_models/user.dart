import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final List<String> favoriteVenues;
  final List<String> favoriteServices;

  /// User role (user, admin, moderator, vendor, planner)
  final String role;

  /// Whether the user has a premium subscription
  final bool hasPremiumSubscription;

  /// Whether the user is a beta tester
  final bool isBetaTester;

  /// User subscription expiration date
  final DateTime? subscriptionExpirationDate;

  /// Whether the user's email is verified
  final bool emailVerified;

  /// Alias for id (for Firebase compatibility)
  String get uid => id;

  /// Alias for name (for compatibility)
  String get displayName => name;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.favoriteVenues = const [],
    this.favoriteServices = const [],
    this.role = 'user',
    this.hasPremiumSubscription = false,
    this.isBetaTester = false,
    this.subscriptionExpirationDate,
    this.emailVerified = false,
  });

  // Create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      favoriteVenues: List<String>.from(json['favoriteVenues'] ?? []),
      favoriteServices: List<String>.from(json['favoriteServices'] ?? []),
      role: json['role'] as String? ?? 'user',
      hasPremiumSubscription: json['hasPremiumSubscription'] as bool? ?? false,
      isBetaTester: json['isBetaTester'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
      subscriptionExpirationDate:
          json['subscriptionExpirationDate'] != null
              ? DateTime.parse(json['subscriptionExpirationDate'] as String)
              : null,
    );
  }

  // Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'favoriteVenues': favoriteVenues,
      'favoriteServices': favoriteServices,
      'role': role,
      'hasPremiumSubscription': hasPremiumSubscription,
      'isBetaTester': isBetaTester,
      'emailVerified': emailVerified,
      'subscriptionExpirationDate':
          subscriptionExpirationDate?.toIso8601String(),
    };
  }

  /// Create a User from a Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data was null');
    }

    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      profileImageUrl: data['profileImageUrl'],
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      favoriteVenues:
          data['favoriteVenues'] != null
              ? List<String>.from(data['favoriteVenues'])
              : [],
      favoriteServices:
          data['favoriteServices'] != null
              ? List<String>.from(data['favoriteServices'])
              : [],
      role: data['role'] ?? 'user',
      hasPremiumSubscription: data['hasPremiumSubscription'] ?? false,
      isBetaTester: data['isBetaTester'] ?? false,
      emailVerified: data['emailVerified'] ?? false,
      subscriptionExpirationDate:
          data['subscriptionExpirationDate'] != null
              ? (data['subscriptionExpirationDate'] as Timestamp).toDate()
              : null,
    );
  }

  /// Convert User to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'favoriteVenues': favoriteVenues,
      'favoriteServices': favoriteServices,
      'role': role,
      'hasPremiumSubscription': hasPremiumSubscription,
      'isBetaTester': isBetaTester,
      'emailVerified': emailVerified,
      'subscriptionExpirationDate':
          subscriptionExpirationDate != null
              ? Timestamp.fromDate(subscriptionExpirationDate!)
              : null,
    };
  }

  // Create a copy of the User with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? createdAt,
    List<String>? favoriteVenues,
    List<String>? favoriteServices,
    String? role,
    bool? hasPremiumSubscription,
    bool? isBetaTester,
    bool? emailVerified,
    DateTime? subscriptionExpirationDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      favoriteVenues: favoriteVenues ?? this.favoriteVenues,
      favoriteServices: favoriteServices ?? this.favoriteServices,
      role: role ?? this.role,
      hasPremiumSubscription:
          hasPremiumSubscription ?? this.hasPremiumSubscription,
      isBetaTester: isBetaTester ?? this.isBetaTester,
      emailVerified: emailVerified ?? this.emailVerified,
      subscriptionExpirationDate:
          subscriptionExpirationDate ?? this.subscriptionExpirationDate,
    );
  }

  /// Check if the user has an active subscription
  bool get hasActiveSubscription {
    if (!hasPremiumSubscription) return false;
    if (subscriptionExpirationDate == null) return false;
    return subscriptionExpirationDate!.isAfter(DateTime.now());
  }

  /// Check if the user is an admin
  bool get isAdmin => role == 'admin';

  /// Check if the user is a moderator
  bool get isModerator => role == 'moderator' || isAdmin;

  /// Check if the user is a vendor
  bool get isVendor => role == 'vendor';

  /// Check if the user is a planner
  bool get isPlanner => role == 'planner';
}
