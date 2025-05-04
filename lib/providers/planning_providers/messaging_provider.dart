import 'package:flutter/material.dart';
import 'package:eventati_book/models/models.dart';

/// Provider for managing vendor communications and messaging for an event.
///
/// The MessagingProvider is responsible for:
/// * Managing the list of vendors associated with an event
/// * Storing and retrieving message history with each vendor
/// * Sending new messages to vendors
/// * Tracking read/unread status of messages
/// * Organizing conversations by recency
///
/// Each event has its own messaging system, identified by the eventId.
/// This provider currently uses mock data, but would connect to a
/// database or API in a production environment.
///
/// Usage example:
/// ```dart
/// // Create a provider for a specific event
/// final messagingProvider = MessagingProvider(eventId: 'event123');
///
/// // Access the provider from the widget tree
/// final messagingProvider = Provider.of<MessagingProvider>(context);
///
/// // Get all vendors
/// final vendors = messagingProvider.vendors;
///
/// // Get messages for a specific vendor
/// final messages = messagingProvider.getMessagesForVendor('vendor1');
///
/// // Get all conversations sorted by recency
/// final conversations = messagingProvider.conversations;
///
/// // Send a message to a vendor
/// await messagingProvider.sendMessage(
///   'vendor1',
///   'Hello, I have a question about your services.',
///   null, // No attachments
/// );
///
/// // Mark all messages from a vendor as read
/// await messagingProvider.markMessagesAsRead('vendor1');
/// ```
class MessagingProvider extends ChangeNotifier {
  /// The unique identifier of the event this messaging system belongs to
  final String eventId;

  /// List of all vendors associated with the event
  List<Vendor> _vendors = [];

  /// Map of vendor IDs to their message history
  /// The key is the vendor ID and the value is a list of messages
  Map<String, List<Message>> _messages = {};

  /// Flag indicating if the provider is currently loading data
  bool _isLoading = false;

  /// Error message if an operation fails
  String? _error;

  /// Creates a new MessagingProvider for the specified event
  ///
  /// Automatically loads vendor and message data when instantiated
  MessagingProvider({required this.eventId}) {
    _loadVendorsAndMessages();
  }

  /// Returns the list of all vendors
  List<Vendor> get vendors => _vendors;

  /// Indicates if the provider is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the error message if an operation has failed, null otherwise
  String? get error => _error;

  /// Returns all messages exchanged with a specific vendor
  ///
  /// [vendorId] The ID of the vendor to get messages for
  ///
  /// Returns an empty list if no messages exist for the specified vendor
  List<Message> getMessagesForVendor(String vendorId) {
    return _messages[vendorId] ?? [];
  }

  /// Returns all conversations with vendors, sorted by most recent message first
  ///
  /// A conversation includes:
  /// - The vendor ID
  /// - All messages exchanged with that vendor
  /// - The timestamp of the most recent message
  /// - A flag indicating if there are unread messages from the vendor
  ///
  /// If a vendor has no messages, the conversation will still be included
  /// with an empty message list and the current time as the last message time.
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

  /// Loads the vendor and message data for the event
  ///
  /// This is called automatically when the provider is created.
  /// In a real application, this would fetch data from a database or API.
  /// Currently uses mock data for demonstration purposes.
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

  /// Sends a new message to a vendor
  ///
  /// [vendorId] The ID of the vendor to send the message to
  /// [content] The text content of the message
  /// [attachments] Optional list of attachment file paths or URLs
  ///
  /// Creates a new message with the current timestamp and adds it to the
  /// conversation with the specified vendor. Messages sent by the user
  /// are automatically marked as read.
  /// In a real application, this would send the message to a backend API.
  /// Notifies listeners when the operation completes.
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
        isRead: true, // User's own messages are always read
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

  /// Marks all unread messages from a vendor as read
  ///
  /// [vendorId] The ID of the vendor whose messages should be marked as read
  ///
  /// This method only affects messages from the vendor (not from the user)
  /// that are currently marked as unread. It creates new message objects
  /// with the isRead property set to true.
  /// In a real application, this would update the read status in a backend API.
  /// Notifies listeners when the operation completes.
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

  /// Loads mock data for testing and demonstration purposes
  ///
  /// This method creates sample vendors and message histories.
  /// In a real application, this would be replaced with data from a database or API.
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
