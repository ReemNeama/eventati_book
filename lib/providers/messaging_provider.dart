import 'package:flutter/material.dart';
import 'package:eventati_book/models/vendor_message.dart';

class MessagingProvider extends ChangeNotifier {
  final String eventId;
  List<Vendor> _vendors = [];
  Map<String, List<Message>> _messages = {};
  bool _isLoading = false;
  String? _error;

  MessagingProvider({required this.eventId}) {
    _loadVendorsAndMessages();
  }

  // Getters
  List<Vendor> get vendors => _vendors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get messages for a specific vendor
  List<Message> getMessagesForVendor(String vendorId) {
    return _messages[vendorId] ?? [];
  }

  // Get all conversations
  List<Conversation> get conversations {
    return _vendors.map((vendor) {
        final vendorMessages = getMessagesForVendor(vendor.id);
        final hasUnread = vendorMessages.any((m) => !m.isRead && !m.isFromUser);
        final lastMessageTime =
            vendorMessages.isNotEmpty
                ? vendorMessages
                    .map((m) => m.timestamp)
                    .reduce((a, b) => a.isAfter(b) ? a : b)
                : DateTime.now();

        return Conversation(
          vendorId: vendor.id,
          messages: vendorMessages,
          lastMessageTime: lastMessageTime,
          hasUnreadMessages: hasUnread,
        );
      }).toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  // CRUD operations
  Future<void> _loadVendorsAndMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // In a real app, this would load from a database or API
      await Future.delayed(const Duration(milliseconds: 500));
      _loadMockData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendMessage(
    String vendorId,
    String content,
    List<String>? attachments,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would save to a database or API
      await Future.delayed(const Duration(milliseconds: 300));

      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vendorId: vendorId,
        content: content,
        timestamp: DateTime.now(),
        isFromUser: true,
        attachments: attachments,
        isRead: true,
      );

      if (_messages.containsKey(vendorId)) {
        _messages[vendorId]!.add(message);
      } else {
        _messages[vendorId] = [message];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markMessagesAsRead(String vendorId) async {
    if (!_messages.containsKey(vendorId)) return;

    final updatedMessages =
        _messages[vendorId]!.map((message) {
          if (!message.isRead && !message.isFromUser) {
            // Create a new message with isRead set to true
            return Message(
              id: message.id,
              vendorId: message.vendorId,
              content: message.content,
              timestamp: message.timestamp,
              isFromUser: message.isFromUser,
              attachments: message.attachments,
              isRead: true,
            );
          }
          return message;
        }).toList();

    _messages[vendorId] = updatedMessages;
    notifyListeners();
  }

  // Mock data for testing
  void _loadMockData() {
    _vendors = [
      Vendor(
        id: '1',
        name: 'Grand Plaza Hotel',
        serviceType: 'Venue',
        email: 'events@grandplaza.com',
        phone: '555-123-4567',
        contactPerson: 'Sarah Johnson',
      ),
      Vendor(
        id: '2',
        name: 'Gourmet Delights Catering',
        serviceType: 'Catering',
        email: 'info@gourmetdelights.com',
        phone: '555-987-6543',
        contactPerson: 'Michael Chen',
      ),
      Vendor(
        id: '3',
        name: 'David Wilson Photography',
        serviceType: 'Photography',
        email: 'david@wilsonphotography.com',
        phone: '555-456-7890',
        contactPerson: 'David Wilson',
      ),
    ];

    final now = DateTime.now();

    _messages = {
      '1': [
        Message(
          id: '1',
          vendorId: '1',
          content: 'Hello, I\'m interested in booking your venue for an event.',
          timestamp: now.subtract(const Duration(days: 5, hours: 3)),
          isFromUser: true,
          isRead: true,
        ),
        Message(
          id: '2',
          vendorId: '1',
          content:
              'Thank you for your interest! We\'d be happy to host your event. What date are you considering?',
          timestamp: now.subtract(const Duration(days: 5, hours: 2)),
          isFromUser: false,
          isRead: true,
        ),
        Message(
          id: '3',
          vendorId: '1',
          content: 'I\'m looking at June 15th. Do you have availability?',
          timestamp: now.subtract(const Duration(days: 5, hours: 1)),
          isFromUser: true,
          isRead: true,
        ),
        Message(
          id: '4',
          vendorId: '1',
          content:
              'Yes, June 15th is available. Would you like to schedule a tour?',
          timestamp: now.subtract(const Duration(days: 4, hours: 23)),
          isFromUser: false,
          isRead: false,
        ),
      ],
      '2': [
        Message(
          id: '5',
          vendorId: '2',
          content: 'Hi, I\'d like to discuss catering options for my event.',
          timestamp: now.subtract(const Duration(days: 3, hours: 5)),
          isFromUser: true,
          isRead: true,
        ),
        Message(
          id: '6',
          vendorId: '2',
          content:
              'Hello! We offer a variety of menu options. How many guests are you expecting?',
          timestamp: now.subtract(const Duration(days: 3, hours: 4)),
          isFromUser: false,
          isRead: true,
        ),
      ],
    };
  }
}
