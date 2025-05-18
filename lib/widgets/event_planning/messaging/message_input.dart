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
      return isDarkMode
          ? Color.fromRGBO(
            AppColors.disabled.r.toInt(),
            AppColors.disabled.g.toInt(),
            AppColors.disabled.b.toInt(),
            0.7,
          )
          : Color.fromRGBO(
            AppColors.disabled.r.toInt(),
            AppColors.disabled.g.toInt(),
            AppColors.disabled.b.toInt(),
            0.3,
          );
    }
  }

  /// Get the appropriate color for the send icon based on whether a message can be sent
  Color _getSendIconColor(bool isDarkMode) {
    if (_canSend) {
      return Colors.white;
    } else {
      // Use a disabled color based on theme
      return isDarkMode
          ? Color.fromRGBO(
            AppColors.disabled.r.toInt(),
            AppColors.disabled.g.toInt(),
            AppColors.disabled.b.toInt(),
            0.4,
          )
          : Color.fromRGBO(
            AppColors.disabled.r.toInt(),
            AppColors.disabled.g.toInt(),
            AppColors.disabled.b.toInt(),
            0.6,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = UIUtils.isDarkMode(context);
    final primaryColor = isDarkMode ? AppColorsDark.primary : AppColors.primary;
    final backgroundColor =
        isDarkMode
            ? AppColorsDark.inputFieldBackground
            : Color.fromRGBO(
              AppColors.disabled.r.toInt(),
              AppColors.disabled.g.toInt(),
              AppColors.disabled.b.toInt(),
              0.1,
            );
    final textColor = isDarkMode ? Colors.white : AppColors.textPrimary;
    final hintColor =
        isDarkMode
            ? Color.fromRGBO(
              Colors.white.r.toInt(),
              Colors.white.g.toInt(),
              Colors.white.b.toInt(),
              0.7,
            )
            : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              Colors.black.r.toInt(),
              Colors.black.g.toInt(),
              Colors.black.b.toInt(),
              0.10,
            ), // 0.1 * 255 = 25.5 ≈ 26
            blurRadius: 4.0,
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
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor:
                    isDarkMode
                        ? Color.fromRGBO(
                          AppColors.disabled.r.toInt(),
                          AppColors.disabled.g.toInt(),
                          AppColors.disabled.b.toInt(),
                          0.8,
                        )
                        : Colors.white,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: _canSend ? (_) => _handleSend() : null,
            ),
          ),
          const SizedBox(width: 8.0),
          Material(
            color: _getSendButtonColor(primaryColor, isDarkMode),
            borderRadius: BorderRadius.circular(24.0),
            child: InkWell(
              onTap: _canSend ? _handleSend : null,
              borderRadius: BorderRadius.circular(24.0),
              child: Container(
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  Icons.send,
                  color: _getSendIconColor(isDarkMode),
                  size: 24.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
