import 'package:eventati_book/utils/database_utils.dart';

class Vendor {
  final String id;
  final String name;
  final String serviceType;
  final String? email;
  final String? phone;
  final String? contactPerson;
  final String? notes;
  final String? website;
  final double? rating;
  final String? imageUrl;

  Vendor({
    required this.id,
    required this.name,
    required this.serviceType,
    this.email,
    this.phone,
    this.contactPerson,
    this.notes,
    this.website,
    this.rating,
    this.imageUrl,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'serviceType': serviceType,
      'email': email,
      'phone': phone,
      'contactPerson': contactPerson,
      'notes': notes,
      'website': website,
      'rating': rating,
      'imageUrl': imageUrl,
    };
  }

  /// Create from JSON
  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'],
      name: json['name'] ?? '',
      serviceType: json['serviceType'] ?? '',
      email: json['email'],
      phone: json['phone'],
      contactPerson: json['contactPerson'],
      notes: json['notes'],
      website: json['website'],
      rating: json['rating'] != null ? (json['rating']).toDouble() : null,
      imageUrl: json['imageUrl'],
    );
  }

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'name': name,
      'serviceType': serviceType,
      'email': email,
      'phone': phone,
      'contactPerson': contactPerson,
      'notes': notes,
      'website': website,
      'rating': rating,
      'imageUrl': imageUrl,
      'createdAt': DbFieldValue.serverTimestamp(),
      'updatedAt': DbFieldValue.serverTimestamp(),
    };
  }

  /// Create from database document
  factory Vendor.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return Vendor(
      id: doc.id,
      name: data['name'] ?? '',
      serviceType: data['serviceType'] ?? '',
      email: data['email'],
      phone: data['phone'],
      contactPerson: data['contactPerson'],
      notes: data['notes'],
      website: data['website'],
      rating: data['rating'] != null ? (data['rating']).toDouble() : null,
      imageUrl: data['imageUrl'],
    );
  }
}

class Message {
  final String id;
  final String vendorId;
  final String content;
  final DateTime timestamp;
  final bool isFromUser;
  final List<String> attachments;
  final bool isRead;
  final String? userId;
  final String? eventId;
  final String? replyToMessageId;

  Message({
    required this.id,
    required this.vendorId,
    required this.content,
    required this.timestamp,
    required this.isFromUser,
    this.attachments = const [],
    this.isRead = false,
    this.userId,
    this.eventId,
    this.replyToMessageId,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendorId': vendorId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isFromUser': isFromUser,
      'attachments': attachments,
      'isRead': isRead,
      'userId': userId,
      'eventId': eventId,
      'replyToMessageId': replyToMessageId,
    };
  }

  /// Create from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      vendorId: json['vendorId'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isFromUser: json['isFromUser'] ?? true,
      attachments:
          json['attachments'] != null
              ? List<String>.from(json['attachments'])
              : [],
      isRead: json['isRead'] ?? false,
      userId: json['userId'],
      eventId: json['eventId'],
      replyToMessageId: json['replyToMessageId'],
    );
  }

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'vendorId': vendorId,
      'content': content,
      'timestamp': DbTimestamp.fromDate(timestamp).toIso8601String(),
      'isFromUser': isFromUser,
      'attachments': attachments,
      'isRead': isRead,
      'userId': userId,
      'eventId': eventId,
      'replyToMessageId': replyToMessageId,
      'createdAt': DbFieldValue.serverTimestamp(),
    };
  }

  /// Create from database document
  factory Message.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return Message(
      id: doc.id,
      vendorId: data['vendorId'] ?? '',
      content: data['content'] ?? '',
      timestamp:
          data['timestamp'] != null
              ? DateTime.parse(data['timestamp'])
              : DateTime.now(),
      isFromUser: data['isFromUser'] ?? true,
      attachments:
          data['attachments'] != null
              ? List<String>.from(data['attachments'])
              : [],
      isRead: data['isRead'] ?? false,
      userId: data['userId'],
      eventId: data['eventId'],
      replyToMessageId: data['replyToMessageId'],
    );
  }
}

class Conversation {
  final String vendorId;
  final List<Message> messages;
  final DateTime lastMessageTime;
  final bool hasUnreadMessages;
  final String? vendorName;
  final String? vendorImageUrl;
  final String? eventId;

  Conversation({
    required this.vendorId,
    required this.messages,
    required this.lastMessageTime,
    this.hasUnreadMessages = false,
    this.vendorName,
    this.vendorImageUrl,
    this.eventId,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'hasUnreadMessages': hasUnreadMessages,
      'vendorName': vendorName,
      'vendorImageUrl': vendorImageUrl,
      'eventId': eventId,
    };
  }

  /// Create from JSON
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      vendorId: json['vendorId'] ?? '',
      messages:
          json['messages'] != null
              ? (json['messages'] as List)
                  .map((m) => Message.fromJson(m as Map<String, dynamic>))
                  .toList()
              : [],
      lastMessageTime:
          json['lastMessageTime'] != null
              ? DateTime.parse(json['lastMessageTime'])
              : DateTime.now(),
      hasUnreadMessages: json['hasUnreadMessages'] ?? false,
      vendorName: json['vendorName'],
      vendorImageUrl: json['vendorImageUrl'],
      eventId: json['eventId'],
    );
  }

  /// Convert to database document
  Map<String, dynamic> toDatabaseDoc() {
    return {
      'vendorId': vendorId,
      'lastMessageTime':
          DbTimestamp.fromDate(lastMessageTime).toIso8601String(),
      'hasUnreadMessages': hasUnreadMessages,
      'vendorName': vendorName,
      'vendorImageUrl': vendorImageUrl,
      'eventId': eventId,
      'updatedAt': DbFieldValue.serverTimestamp(),
    };
  }

  /// Create from database document
  factory Conversation.fromDatabaseDoc(DbDocumentSnapshot doc) {
    final data = doc.getData();
    if (data.isEmpty) {
      throw Exception('Document data was null');
    }

    return Conversation(
      vendorId: data['vendorId'] ?? '',
      messages: [], // Messages are loaded separately from a subcollection
      lastMessageTime:
          data['lastMessageTime'] != null
              ? DateTime.parse(data['lastMessageTime'])
              : DateTime.now(),
      hasUnreadMessages: data['hasUnreadMessages'] ?? false,
      vendorName: data['vendorName'],
      vendorImageUrl: data['vendorImageUrl'],
      eventId: data['eventId'],
    );
  }
}
