import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final String userId;
  final String providerId;
  final String serviceId;
  final String providerName;
  final String providerImage;
  final String lastMessage;
  final DateTime lastMessageTime;

  Chat({
    required this.chatId,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.providerName,
    required this.providerImage,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  // ✅ إضافة copyWith لتعديل خصائص معينة في كائن Chat
  Chat copyWith({
    String? chatId,
    String? userId,
    String? providerId,
    String? serviceId,
    String? providerName,
    String? providerImage,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) {
    return Chat(
      chatId: chatId ?? this.chatId,
      userId: userId ?? this.userId,
      providerId: providerId ?? this.providerId,
      serviceId: serviceId ?? this.serviceId,
      providerName: providerName ?? this.providerName,
      providerImage: providerImage ?? this.providerImage,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }

  // ✅ تحويل بيانات Firestore إلى كائن Chat
  factory Chat.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Chat(
      chatId: doc.id,
      userId: data['userId'] ?? '',
      providerId: data['providerId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      providerName: data['providerName'] ?? 'مقدم خدمة غير معروف',
      providerImage: data['providerImage'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
    );
  }

  // ✅ تحويل كائن Chat إلى JSON (لاستخدامه عند الحفظ في Firestore)
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'userId': userId,
      'providerId': providerId,
      'serviceId': serviceId,
      'providerName': providerName,
      'providerImage': providerImage,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
    };
  }
}
