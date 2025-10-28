import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // استيراد FirebaseAuth للتحقق من تسجيل الدخول
import '../models/chat_message.dart';
import '../models/chat_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

import 'chat_notification_service.dart'; // استيراد Flutter UI لعرض الرسائل

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // مثيل لـ FirebaseAuth
  final ChatNotificationServiceV1 _chatNotificationService = ChatNotificationServiceV1(); // استيراد الخدمة الجديدة

  // ✅ دالة لإرجاع معرف المستخدم الحالي
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // ✅ جلب محادثات المستخدم من Firestore مع التحقق من البيانات
Stream<List<Chat>> getUserChats(String userId) {
  if (userId.isEmpty) {
    return const Stream.empty(); // ✅ إذا المستخدم فارغ نرجع ستريم فارغ
  }

  return _firestore
      .collection('chats')
      .where('userId', isEqualTo: userId) // ✅ جلب كل المحادثات الخاصة بالمستخدم
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

  // ✅ إنشاء محادثة أو استرجاع محادثة موجودة باستخدام `providerId` الصحيح
  Future<String> getOrCreateChat(String? userId, String? serviceId) async {
    if (userId == null || serviceId == null) {
      print("⚠️ خطأ: userId أو serviceId هو null، لا يمكن إنشاء محادثة.");
      throw Exception("userId أو serviceId غير صالح!");
    }

    // 🔹 احصل على `providerId` من `service_providers`
    DocumentSnapshot serviceSnapshot =
        await _firestore.collection('service_providers').doc(serviceId).get();

    if (!serviceSnapshot.exists) {
      print("⚠️ الخدمة غير موجودة!");
      throw Exception("الخدمة غير موجودة!");
    }

    String providerId = serviceSnapshot['userId']; // ✅ معرف مقدم الخدمة

    String chatId = userId.hashCode <= providerId.hashCode
        ? '$userId\_$serviceId'
        : '$serviceId\_$userId';

    DocumentSnapshot chatSnapshot =
        await _firestore.collection('chats').doc(chatId).get();

    if (!chatSnapshot.exists) {
      print("🆕 يتم إنشاء محادثة جديدة مع مقدم الخدمة: $providerId");

      await _firestore.collection('chats').doc(chatId).set({
        'userId': userId,
        'providerId': providerId, // ✅ تخزين معرف مقدم الخدمة وليس معرف الخدمة
        'serviceId': serviceId, 
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      }).then((_) {
        print("✅ تم إنشاء المحادثة بنجاح!");
      }).catchError((error) {
        print("❌ خطأ في إنشاء المحادثة: $error");
      });
    } else {
      print("🔁 المحادثة موجودة مسبقًا، لن يتم إنشاؤها مرة أخرى.");
    }

    return chatId;
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
  await _chatNotificationService.sendNotificationToProvider(
    message.receiverId, // هنا مستقبل الرسالة هو مقدم الخدمة
    message.text,
    message.senderId, // اسم المرسل (المستخدم) - بإمكانك استخدام اسم حقيقي بدل ID إذا متوفر
  );
  }

  
  Future<String?> checkLoginStatus(BuildContext context) async {
    User? user = _auth.currentUser;
    final theme = Theme.of(context);
    if (user == null) {
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'خطأ ❌',
              style: GoogleFonts.elMessiri(
                fontSize: 18,
                color: theme.colorScheme.secondary,  
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'يرجى تسجيل الدخول أولاً',
              style: GoogleFonts.elMessiri(
                fontSize: 14,
                color: theme.colorScheme.secondary,  
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login'); 
                },
                child: Text(
                  'تسجيل الدخول',
                  style: GoogleFonts.elMessiri(
                    fontSize: 12,
                    color: theme.colorScheme.secondary, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
      

      return null;
    } else {
      
      
      return user.uid;
    }
  }




    // ✅ جلب بيانات مقدم الخدمة
  Future<Map<String, String>?> getProviderDetails(String providerId) async {
    try {
      DocumentSnapshot providerDoc =
          await _firestore.collection('service_providers').doc(providerId).get();

      if (!providerDoc.exists) return null;

      return {
        'companyName': providerDoc['companyName'] ?? 'مقدم خدمة غير معروف',
        'companyLogo': providerDoc['companyLogo'] ?? '',
      };
    } catch (e) {
      print("❌ خطأ أثناء جلب بيانات مقدم الخدمة: $e");
      return null;
    }
  }
}
