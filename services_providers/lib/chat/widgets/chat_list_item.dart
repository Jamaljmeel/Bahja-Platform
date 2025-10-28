import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final theme = Theme.of(context); // جلب الثيم
    final isDark = theme.brightness == Brightness.dark; // معرفة الوضع الحالي

    return Card(
      color: theme.colorScheme.secondaryContainer, // لون البطاقة من الثيم
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // زوايا دائرية
      ),
      child: ListTile(
        onTap: onTap, // تنفيذ الدالة عند الضغط
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: isDark
              ? Colors.blueGrey.shade700
              : Colors.blue.shade100, // لون الخلفية حسب الوضع
          child: Icon(
            Icons.person,
            size: 20,
            color: isDark ? Colors.white : Colors.blue.shade800, // لون الأيقونة حسب الوضع
          ),
        ),
        title: Text(
          chat.userName,
          style: GoogleFonts.elMessiri(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSecondaryContainer, // لون النص الأساسي
          ),
        ),
        subtitle: Text(
          chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7), // لون النص الثانوي
          ),
        ),
        trailing: Text(
          _formatTime(chat.lastMessageTime),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer.withOpacity(0.6), // لون الوقت
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // تنسيق الوقت
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return "$hour:$minute";
    } else if (timestamp.difference(now).inDays == -1) {
      return "أمس";
    } else {
      return "${timestamp.day}/${timestamp.month}/${timestamp.year}";
    }
  }
}
