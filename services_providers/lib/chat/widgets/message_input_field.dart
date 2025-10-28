import 'package:flutter/material.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isDark;

  const MessageInputField({
    Key? key,
    required this.controller,
    required this.onSend,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.blueGrey.shade800, Colors.blueGrey.shade700]
                : [Colors.blue[50]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "اكتب رسالتك...",
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : theme.colorScheme.onSecondaryContainer.withOpacity(0.6),
                  ),
                 border: InputBorder.none, // إزالة البوردر
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                minLines: 1,
                maxLines: 5, // للسماح بتوسيع الحقل مع النص الطويل
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send, color: isDark ? Colors.white : Colors.blue[700]),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
