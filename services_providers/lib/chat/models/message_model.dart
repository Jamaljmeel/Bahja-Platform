import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
  });

factory Message.fromMap(Map<String, dynamic> data, String documentId) {
  return Message(
    messageId: documentId,
    senderId: data['senderId'] ?? "", // ✅ تأكد من عدم وجود null
    receiverId: data['receiverId'] ?? "", // ✅ تأكد من عدم وجود null
    text: data['text'] ?? "", // ✅ تأكد من عدم وجود null
    timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}


  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}
