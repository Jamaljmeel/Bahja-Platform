import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../models/chat_message_model.dart';

class ChatBubbleWidget extends StatelessWidget {
  final ChatMessage message;
  final bool isDarkMode;

  const ChatBubbleWidget({
    Key? key,
    required this.message,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLongText = message.text.length > 60;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: message.isUserMessage 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: isLongText ? 14 : 12,
              ),
              decoration: BoxDecoration(
                color: message.isUserMessage
                    ? theme.primaryColor
                    : AppColors.inputFillColor(context),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.isUserMessage ? 20 : 0),
                  topRight: Radius.circular(message.isUserMessage ? 0 : 20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: !message.isUserMessage ? Border.all(
                  color: AppColors.borderColor(context).withOpacity(0.2),
                  width: 1,
                ) : null,
                boxShadow: [
                  if (!isDarkMode)
                    BoxShadow(
                      color: AppColors.borderColor(context).withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: message.isUserMessage
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppTextStyles.large(context).copyWith(
                      color: message.isUserMessage
                          ? AppColors.backgroundColor(context)
                          : AppColors.textColor(context),
                    ),
                    textAlign: message.isUserMessage ? TextAlign.end : TextAlign.start,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.extraSmall(context).copyWith(
                      color: message.isUserMessage
                          ? AppColors.backgroundColor(context).withOpacity(0.7)
                          : AppColors.grey,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}