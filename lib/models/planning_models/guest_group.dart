/// Model representing a group of guests for an event
class GuestGroup {
  /// Unique identifier for the group
  final String id;

  /// Name of the group (e.g., "Family", "Friends", "Colleagues")
  final String name;

  /// Optional description of the group
  final String? description;

  /// Color associated with the group (for UI display)
  final String color;

  /// Constructor
  const GuestGroup({
    required this.id,
    required this.name,
    this.description,
    required this.color,
  });

  /// Create a GuestGroup from a map
  factory GuestGroup.fromMap(Map<String, dynamic> map) {
    return GuestGroup(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      color: map['color'] as String,
    );
  }

  /// Convert GuestGroup to a map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description, 'color': color};
  }

  /// Create a copy of this GuestGroup with the given fields replaced
  GuestGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
  }) {
    return GuestGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
    );
  }

  @override
  String toString() {
    return 'GuestGroup(id: $id, name: $name, description: $description, color: $color)';
  }
}
