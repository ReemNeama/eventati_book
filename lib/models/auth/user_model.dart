/// Model representing a user in the application
class UserModel {
  /// Unique identifier for the user
  final String id;

  /// User's display name
  final String? name;

  /// User's email address
  final String? email;

  /// URL to the user's profile photo
  final String? photoUrl;

  /// Creates a new user model
  UserModel({required this.id, this.name, this.email, this.photoUrl});

  /// Creates a user model from a map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String?,
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  /// Converts the user model to a map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'photoUrl': photoUrl};
  }
}
