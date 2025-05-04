import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';
import 'package:eventati_book/providers/messaging_provider.dart';
import 'package:eventati_book/models/models.dart';
import 'package:eventati_book/widgets/event_planning/messaging/message_bubble.dart';
import 'package:eventati_book/widgets/event_planning/messaging/message_input.dart';
import 'package:eventati_book/widgets/event_planning/messaging/date_separator.dart';
import 'package:intl/intl.dart';

class ConversationScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String vendorId;
  final String vendorName;

  const ConversationScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    required this.vendorId,
    required this.vendorName,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFirstLoad = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;

    return ChangeNotifierProvider(
      create: (_) => MessagingProvider(eventId: widget.eventId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.vendorName),
          backgroundColor: primaryColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<MessagingProvider>(
                builder: (context, messagingProvider, _) {
                  if (messagingProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (messagingProvider.error != null) {
                    return Center(
                      child: Text('Error: ${messagingProvider.error}'),
                    );
                  }

                  final messages = messagingProvider.getMessagesForVendor(
                    widget.vendorId,
                  );

                  // Mark messages as read
                  if (messages.isNotEmpty && _isFirstLoad) {
                    messagingProvider.markMessagesAsRead(widget.vendorId);
                    _isFirstLoad = false;
                  }

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message,
                            size: 64,
                            color: isDarkMode ? Colors.white54 : Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start a conversation with ${widget.vendorName}',
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Sort messages by timestamp (newest first for reversed ListView)
                  final sortedMessages = List<Message>.from(messages)
                    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    itemCount: sortedMessages.length,
                    itemBuilder: (context, index) {
                      final message = sortedMessages[index];
                      final Widget messageBubble = MessageBubble(
                        message: message,
                      );

                      // Add date separator if needed
                      if (index < sortedMessages.length - 1) {
                        final currentDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(message.timestamp);
                        final nextDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(sortedMessages[index + 1].timestamp);

                        if (currentDate != nextDate) {
                          return Column(
                            children: [
                              messageBubble,
                              DateSeparator(date: message.timestamp),
                            ],
                          );
                        }
                      } else if (index == sortedMessages.length - 1) {
                        // Always show date for the oldest message
                        return Column(
                          children: [
                            messageBubble,
                            DateSeparator(date: message.timestamp),
                          ],
                        );
                      }

                      return messageBubble;
                    },
                  );
                },
              ),
            ),
            Consumer<MessagingProvider>(
              builder: (context, messagingProvider, _) {
                return MessageInput(
                  onSendMessage: (content) {
                    messagingProvider
                        .sendMessage(widget.vendorId, content, null)
                        .then((_) {
                          // Scroll to bottom after sending a message
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            _scrollToBottom,
                          );
                        });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
