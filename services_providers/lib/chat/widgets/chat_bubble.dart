import 'package:flutter/material.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showDate)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                date,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        Align(
          alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
          child: GestureDetector(
            onLongPress: () {
              // ⚙️ خيارات (نسخ، حذف، إعادة إرسال...)
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.7, // ✅ حد أقصى فقط
              ),
              child: IntrinsicWidth( // ✅ لأخذ حجم النص الطبيعي
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? (isDark ? Colors.blueGrey.shade700 : Colors.blue[100])
                        : (isDark ? Colors.blueGrey.shade900 : Colors.blue[600]),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
                      bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // ✅ لضبط الحجم على حسب النص
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          color: isMe ? Colors.black87 : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          time,
                          style: TextStyle(
                            color: isMe ? Colors.black54 : Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
