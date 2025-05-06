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
      'subscriptionExpirationDate':
          subscriptionExpirationDate?.toIso8601String(),
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
