import 'package:eventati_book/utils/database_utils.dart';

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

  /// Alias for id (for compatibility with other systems)
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

  /// Create a User from a database document
  factory User.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
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
              ? DateTime.parse(data['createdAt'])
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
              ? DateTime.parse(data['subscriptionExpirationDate'])
              : null,
    );
  }

  /// Convert User to database data
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'createdAt': DbTimestamp.fromDate(createdAt).toIso8601String(),
      'favoriteVenues': favoriteVenues,
      'favoriteServices': favoriteServices,
      'hasPremiumSubscription': hasPremiumSubscription,
      'isBetaTester': isBetaTester,
      'emailVerified': emailVerified,
      'authProvider': authProvider,
      'subscriptionExpirationDate':
          subscriptionExpirationDate != null
              ? DbTimestamp.fromDate(
                subscriptionExpirationDate!,
              ).toIso8601String()
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

  /// Create a User from a Supabase Auth user
  ///
  /// This method creates a basic User object from a Supabase Auth user.
  /// Additional user data should be fetched from the database and merged with this user.
  ///
  /// [supabaseUser] The Supabase Auth user
  /// [userData] Optional additional data from the database
  static User fromSupabaseUser(
    User supabaseUser, [
    Map<String, dynamic>? userData,
  ]) {
    // Determine auth provider
    String authProvider = 'email';
    if (userData != null && userData.containsKey('authProvider')) {
      authProvider = userData['authProvider'];
    } else if (supabaseUser.email.contains('google')) {
      authProvider = 'google';
    } else if (supabaseUser.email.contains('apple')) {
      authProvider = 'apple';
    }

    return User(
      id: supabaseUser.id,
      name: userData?['name'] ?? supabaseUser.email.split('@')[0],
      email: supabaseUser.email,
      phoneNumber: userData?['phoneNumber'],
      profileImageUrl: userData?['profileImageUrl'],
      createdAt:
          userData?['createdAt'] != null
              ? DateTime.parse(userData!['createdAt'])
              : DateTime.now(),
      favoriteVenues:
          userData?['favoriteVenues'] != null
              ? List<String>.from(userData!['favoriteVenues'])
              : [],
      favoriteServices:
          userData?['favoriteServices'] != null
              ? List<String>.from(userData!['favoriteServices'])
              : [],
      hasPremiumSubscription: userData?['hasPremiumSubscription'] ?? false,
      isBetaTester: userData?['isBetaTester'] ?? false,
      emailVerified: userData?['emailVerified'] ?? false,
      authProvider: authProvider,
      subscriptionExpirationDate:
          userData?['subscriptionExpirationDate'] != null
              ? DateTime.parse(userData!['subscriptionExpirationDate'])
              : null,
    );
  }
}
