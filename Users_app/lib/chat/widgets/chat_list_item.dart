import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../models/chat_model.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatListItem({
    Key? key,
    required this.chat,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage: chat.providerImage.isNotEmpty
            ? NetworkImage(chat.providerImage)
            : null,
        child: chat.providerImage.isEmpty 
            ? Icon(Icons.person, color: theme.colorScheme.onSecondary)
            : null,
        backgroundColor: theme.colorScheme.secondaryContainer,
      ),
      title: Text(
        chat.providerName,
        style: AppTextStyles.medium(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.small(context),
      ),
      trailing: Text(
        _formatTime(chat.lastMessageTime),
        style: AppTextStyles.extraSmall(context).copyWith(
          color: theme.hintColor,
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      return "${timestamp.hour}:${timestamp.minute}";
    } else if (timestamp.difference(now).inDays == -1) {
      return "أمس";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }
}