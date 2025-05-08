import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final List<String> favoriteVenues;
  final List<String> favoriteServices;

  /// Whether the user has a premium subscription
  final bool hasPremiumSubscription;

  /// Whether the user is a beta tester
  final bool isBetaTester;

  /// User subscription expiration date
  final DateTime? subscriptionExpirationDate;

  /// Whether the user's email is verified
  final bool emailVerified;

  /// Authentication provider (email, google, facebook, apple)
  final String authProvider;

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
    this.hasPremiumSubscription = false,
    this.isBetaTester = false,
    this.subscriptionExpirationDate,
    this.emailVerified = false,
    this.authProvider = 'email',
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
      hasPremiumSubscription: json['hasPremiumSubscription'] as bool? ?? false,
      isBetaTester: json['isBetaTester'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
      authProvider: json['authProvider'] as String? ?? 'email',
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
      'hasPremiumSubscription': hasPremiumSubscription,
      'isBetaTester': isBetaTester,
      'emailVerified': emailVerified,
      'authProvider': authProvider,
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
      hasPremiumSubscription: data['hasPremiumSubscription'] ?? false,
      isBetaTester: data['isBetaTester'] ?? false,
      emailVerified: data['emailVerified'] ?? false,
      authProvider: data['authProvider'] ?? 'email',
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
      'hasPremiumSubscription': hasPremiumSubscription,
      'isBetaTester': isBetaTester,
      'emailVerified': emailVerified,
      'authProvider': authProvider,
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
    bool? hasPremiumSubscription,
    bool? isBetaTester,
    bool? emailVerified,
    String? authProvider,
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
      hasPremiumSubscription:
          hasPremiumSubscription ?? this.hasPremiumSubscription,
      isBetaTester: isBetaTester ?? this.isBetaTester,
      emailVerified: emailVerified ?? this.emailVerified,
      authProvider: authProvider ?? this.authProvider,
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

  /// Create a User from a Firebase Auth user
  ///
  /// This method creates a basic User object from a Firebase Auth user.
  /// Additional user data should be fetched from Firestore and merged with this user.
  ///
  /// [firebaseUser] The Firebase Auth user
  /// [firestoreData] Optional additional data from Firestore
  static User fromFirebaseUser(
    firebase_auth.User firebaseUser, [
    Map<String, dynamic>? firestoreData,
  ]) {
    // Determine auth provider from Firebase user providers or Firestore data
    String authProvider = 'email';
    if (firestoreData != null && firestoreData.containsKey('authProvider')) {
      authProvider = firestoreData['authProvider'];
    } else if (firebaseUser.providerData.isNotEmpty) {
      final providerId = firebaseUser.providerData[0].providerId;
      if (providerId.contains('google')) {
        authProvider = 'google';
      } else if (providerId.contains('facebook')) {
        authProvider = 'facebook';
      } else if (providerId.contains('apple')) {
        authProvider = 'apple';
      }
    }

    return User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? '',
      phoneNumber: firebaseUser.phoneNumber,
      profileImageUrl: firebaseUser.photoURL,
      createdAt:
          firestoreData?['createdAt'] != null
              ? (firestoreData!['createdAt'] as Timestamp).toDate()
              : firebaseUser.metadata.creationTime ?? DateTime.now(),
      favoriteVenues:
          firestoreData?['favoriteVenues'] != null
              ? List<String>.from(firestoreData!['favoriteVenues'])
              : [],
      favoriteServices:
          firestoreData?['favoriteServices'] != null
              ? List<String>.from(firestoreData!['favoriteServices'])
              : [],
      hasPremiumSubscription: firestoreData?['hasPremiumSubscription'] ?? false,
      isBetaTester: firestoreData?['isBetaTester'] ?? false,
      emailVerified: firebaseUser.emailVerified,
      authProvider: authProvider,
      subscriptionExpirationDate:
          firestoreData?['subscriptionExpirationDate'] != null
              ? (firestoreData!['subscriptionExpirationDate'] as Timestamp)
                  .toDate()
              : null,
    );
  }
}
