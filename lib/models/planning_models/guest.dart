import 'package:eventati_book/utils/database_utils.dart';

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

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'name': name,
      'description': description,
      'color': color,
      // Don't store guests here, they are stored in a subcollection
      'createdAt': DbFieldValue.serverTimestamp(),
      'updatedAt': DbFieldValue.serverTimestamp(),
    };
  }

  /// Create from database document
  factory GuestGroup.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return GuestGroup(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      color: data['color'],
      guests: [], // Guests are loaded separately from a subcollection
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

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'groupId': groupId,
      'rsvpStatus': rsvpStatus.toString().split('.').last,
      'rsvpResponseDate': rsvpResponseDate?.toIso8601String(),
      'plusOne': plusOne,
      'plusOneCount': plusOneCount,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      groupId: json['groupId'],
      rsvpStatus: _parseRsvpStatus(json['rsvpStatus']),
      rsvpResponseDate:
          json['rsvpResponseDate'] != null
              ? DateTime.parse(json['rsvpResponseDate'])
              : null,
      plusOne: json['plusOne'] ?? false,
      plusOneCount: json['plusOneCount'],
      notes: json['notes'],
    );
  }

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'groupId': groupId,
      'rsvpStatus': rsvpStatus.toString().split('.').last,
      'rsvpResponseDate':
          rsvpResponseDate != null
              ? DbTimestamp.fromDate(rsvpResponseDate!).toIso8601String()
              : null,
      'plusOne': plusOne,
      'plusOneCount': plusOneCount,
      'notes': notes,
      'createdAt': DbFieldValue.serverTimestamp(),
      'updatedAt': DbFieldValue.serverTimestamp(),
    };
  }

  /// Create from database document
  factory Guest.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return Guest(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'],
      phone: data['phone'],
      groupId: data['groupId'],
      rsvpStatus: _parseRsvpStatus(data['rsvpStatus']),
      rsvpResponseDate:
          data['rsvpResponseDate'] != null
              ? DateTime.parse(data['rsvpResponseDate'])
              : null,
      plusOne: data['plusOne'] ?? false,
      plusOneCount: data['plusOneCount'],
      notes: data['notes'],
    );
  }

  /// Parse RSVP status from string
  static RsvpStatus _parseRsvpStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return RsvpStatus.confirmed;
      case 'declined':
        return RsvpStatus.declined;
      case 'tentative':
        return RsvpStatus.tentative;
      case 'pending':
      default:
        return RsvpStatus.pending;
    }
  }
}
