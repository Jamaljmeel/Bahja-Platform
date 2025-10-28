import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import 'chat_notification_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatNotificationServiceV1 _chatNotificationService = ChatNotificationServiceV1(); // استيراد الخدمة الجديدة
Stream<List<Chat>> getProviderChats(String providerId) {
  if (providerId.isEmpty) {
    return const Stream.empty(); // ✅ إذا المستخدم فارغ نرجع ستريم فارغ
  }

  return _firestore
      .collection('chats')
      .where('providerId', isEqualTo: providerId) // ✅ جلب كل المحادثات الخاصة بالمستخدم
      .orderBy('lastMessageTime', descending: true) // ✅ ترتيب حسب آخر رسالة
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          print("🔥 لا توجد محادثات لهذا المستخدم");
        }

        // ✅ تحويل جميع المحادثات إلى Chat بدون دمج
        List<Chat> chats = snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();

        // ✅ إرجاع القائمة كما هي (لكل خدمة محادثة منفصلة)
        return chats;
      })
      .handleError((error) {
        print("❌ خطأ في استرجاع المحادثات: $error");
        return []; // ✅ إرجاع قائمة فاضية في حال وجود خطأ
      });
}

  // ✅ دالة لإرجاع معرف المستخدم الحالي
  String? getCurrentproviderId() {
    return _auth.currentUser?.uid;
  }

  // إحضار جميع الرسائل داخل محادثة معينة
  Stream<List<Message>> getMessages(String chatId, String serviceId) {
    return _firestore
        .collection('chats')
        
        .doc(chatId)
        .collection('messages')
        .where('serviceId', isEqualTo: serviceId) 
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data(), doc.id)).toList());
  }

  // إرسال رسالة جديدة
  Future<void> sendMessage(String chatId, Message message, String serviceId) async {
    DocumentReference messageRef =
        _firestore.collection('chats').doc(chatId).collection('messages').doc();

    await messageRef.set({
      'messageId': messageRef.id,
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'serviceId': serviceId,
      'text': message.text,
      'timestamp': message.timestamp,
    });

    // تحديث آخر رسالة في المحادثة
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message.text,
      'lastMessageTime': message.timestamp,
    });

      // ✅ إرسال إشعار لمقدم الخدمة (لأن المرسل هو المستخدم)
  await _chatNotificationService.sendNotificationToUser(
    message.receiverId, // هنا مستقبل الرسالة هو مقدم الخدمة
    message.text,
    message.senderId, // اسم المرسل (المستخدم) - بإمكانك استخدام اسم حقيقي بدل ID إذا متوفر
  );
  }

Future<Map<String, String>?> getUserDetails(String userId) async {
  try {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists && userDoc.data() != null) {
      var data = userDoc.data() as Map<String, dynamic>;

      return {
        'userName': data['username'] ?? 'المستخدم غير معروف', // ✅ جلب من username
      };
    } else {
      print("❌ المستخدم غير موجود: $userId");
      return {'userName': 'المستخدم غير معروف'};
    }
  } catch (e) {
    print('❌ خطأ في جلب بيانات المستخدم: $e');
    return {'userName': 'المستخدم غير معروف'};
  }
}
}
