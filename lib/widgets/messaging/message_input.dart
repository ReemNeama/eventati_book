import 'package:flutter/material.dart';
import 'package:eventati_book/utils/utils.dart';
import 'package:eventati_book/styles/app_colors.dart';
import 'package:eventati_book/styles/app_colors_dark.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;

  const MessageInput({super.key, required this.onSendMessage});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _textController = TextEditingController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateSendButton);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateSendButton);
    _textController.dispose();
    super.dispose();
  }

  void _updateSendButton() {
    final canSend = _textController.text.trim().isNotEmpty;
    if (canSend != _canSend) {
      setState(() {
        _canSend = canSend;
      });
    }
  }

  void _handleSend() {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _textController.clear();
    }
  }

  /// Get the appropriate color for the send button based on whether a message can be sent
  Color _getSendButtonColor(Color primaryColor, bool isDarkMode) {
    if (_canSend) {
      return primaryColor;
    } else {
      // Use a disabled color based on theme
      return isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    }
  }

  /// Get the appropriate color for the send icon based on whether a message can be sent
  Color _getSendIconColor(bool isDarkMode) {
    if (_canSend) {
      return Colors.white;
    } else {
      // Use a disabled color based on theme
      return isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode ? AppColorsDark.inputFieldBackground : Colors.grey[100];
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: hintColor),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.mediumPadding,
                  vertical: AppConstants.smallPadding + 2,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.largeBorderRadius + 8,
                  ),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _canSend ? (_) => _handleSend() : null,
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Material(
            color: _getSendButtonColor(primaryColor, isDarkMode),
            borderRadius: BorderRadius.circular(
              AppConstants.largeBorderRadius + 8,
            ),
            child: InkWell(
              onTap: _canSend ? _handleSend : null,
              borderRadius: BorderRadius.circular(
                AppConstants.largeBorderRadius + 8,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.smallPadding + 4),
                child: Icon(
                  Icons.send,
                  color: _getSendIconColor(isDarkMode),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
