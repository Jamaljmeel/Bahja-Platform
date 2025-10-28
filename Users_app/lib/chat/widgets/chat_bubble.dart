import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;
  final String date;
  final bool showDate;

  const ChatBubble({
    required this.text,
    required this.isMe,
    required this.time,
    required this.date,
    required this.showDate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = AppThemes.customColors(context);

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showDate)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                date,
                style: AppTextStyles.extraSmall(context).copyWith(
                  color: theme.hintColor,
                ),
              ),
            ),
          ),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : customColors.inputFillColor,
              borderRadius: BorderRadius.circular(12),
              border: !isMe ? Border.all(color: customColors.borderColor) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  text,
                  style: AppTextStyles.medium(context).copyWith(
                    color: isMe ? Colors.white : AppColors.textColor(context),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: AppTextStyles.extraSmall(context).copyWith(
                    color: isMe ? Colors.white70 : theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}