enum RsvpStatus { pending, confirmed, declined, tentative }

class GuestGroup {
  final String id;
  final String name;
  final String? description;
  final String? color;
  final List<Guest> guests;

  GuestGroup({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.guests = const [],
  });

  GuestGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    List<Guest>? guests,
  }) {
    return GuestGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      guests: guests ?? this.guests,
    );
  }
}

class Guest {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? groupId;
  final RsvpStatus rsvpStatus;
  final DateTime? rsvpResponseDate;
  final bool plusOne;
  final int? plusOneCount;
  final String? notes;

  Guest({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.groupId,
    this.rsvpStatus = RsvpStatus.pending,
    this.rsvpResponseDate,
    this.plusOne = false,
    this.plusOneCount,
    this.notes,
  });

  String get fullName => '$firstName $lastName';

  Guest copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? groupId,
    RsvpStatus? rsvpStatus,
    DateTime? rsvpResponseDate,
    bool? plusOne,
    int? plusOneCount,
    String? notes,
  }) {
    return Guest(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      groupId: groupId ?? this.groupId,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      rsvpResponseDate: rsvpResponseDate ?? this.rsvpResponseDate,
      plusOne: plusOne ?? this.plusOne,
      plusOneCount: plusOneCount ?? this.plusOneCount,
      notes: notes ?? this.notes,
    );
  }
}
