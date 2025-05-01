class Vendor {
  final String id;
  final String name;
  final String serviceType;
  final String? email;
  final String? phone;
  final String? contactPerson;
  final String? notes;

  Vendor({
    required this.id,
    required this.name,
    required this.serviceType,
    this.email,
    this.phone,
    this.contactPerson,
    this.notes,
  });
}

class Message {
  final String id;
  final String vendorId;
  final String content;
  final DateTime timestamp;
  final bool isFromUser;
  final List<String>? attachments;
  final bool isRead;

  Message({
    required this.id,
    required this.vendorId,
    required this.content,
    required this.timestamp,
    required this.isFromUser,
    this.attachments,
    this.isRead = false,
  });
}

class Conversation {
  final String vendorId;
  final List<Message> messages;
  final DateTime lastMessageTime;
  final bool hasUnreadMessages;

  Conversation({
    required this.vendorId,
    required this.messages,
    required this.lastMessageTime,
    this.hasUnreadMessages = false,
  });
}
