enum RsvpStatus { pending, confirmed, declined, tentative }

class MealPreference {
  final String id;
  final String name;
  final String? description;

  MealPreference({
    required this.id,
    required this.name,
    this.description,
  });
}

class GuestGroup {
  final String id;
  final String name;
  final String? description;

  GuestGroup({
    required this.id,
    required this.name,
    this.description,
  });
}

class Guest {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? groupId;
  final RsvpStatus rsvpStatus;
  final String? mealPreferenceId;
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
    this.mealPreferenceId,
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
    String? mealPreferenceId,
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
      mealPreferenceId: mealPreferenceId ?? this.mealPreferenceId,
      plusOne: plusOne ?? this.plusOne,
      plusOneCount: plusOneCount ?? this.plusOneCount,
      notes: notes ?? this.notes,
    );
  }
}
