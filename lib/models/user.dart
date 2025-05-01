class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final DateTime createdAt;
  final List<String> favoriteVenues;
  final List<String> favoriteServices;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.createdAt,
    this.favoriteVenues = const [],
    this.favoriteServices = const [],
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
    );
  }
}
