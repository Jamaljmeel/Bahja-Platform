import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _serviceAccountPath = 'asset/config/service-account.json';

  // ✅ دالة لجلب التوكن
  Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    return token;
  }

  // ✅ دالة لحفظ التوكن في Firestore
  Future<void> saveUserToken(String userId) async {
    String? token = await getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ✅ الاستماع لتحديث التوكن
  void listenToTokenRefresh(String userId) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('🔄 Token تم تحديثه: $newToken');
      await saveUserToken(userId);
    });
  }

 Future<void> sendBookingCompletNotification({
  required String userId,
  required String bookingId,
  required double refundAmount,
  required BuildContext context,
}) async {
  try {
    // 1. جلب بيانات الحجز والمستخدم
    final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (!bookingDoc.exists || !userDoc.exists) {
      throw Exception('البيانات غير موجودة');
    }

    final token = userDoc['fcmToken'] as String?;
    final serviceName = bookingDoc['serviceName'] as String? ?? 'الخدمة';
    final providerName = FirebaseAuth.instance.currentUser?.displayName ?? 'مقدم الخدمة';

    if (token == null) {
      throw Exception('لا يوجد token إشعارات للمستخدم');
    }

    // 2. صياغة رسالة الرفض الجديدة حسب الطلب
    final title = 'تم الموافقة على حجزك';
    final body = refundAmount > 0 
        ? 'لقد تم الموافقة على حجزك لخدمة "$serviceName" وتم تحويل المبلغ المحجوز ${NumberFormat('#,###', 'ar').format(refundAmount)} ريال إلى محفظة خدمة "$serviceName" '
        : 'لقد تم الموافقة على حجزك لخدمة "$serviceName"';

    // 3. إرسال الإشعار عبر FCM
    await _sendFcmNotification(
      token: token,
      title: title,
      body: body,
      bookingId: bookingId,
    );

    // 4. حفظ الإشعار في Firestore مع معلومات الإرجاع
    await _firestore.collection('notifications').add({
      'userId': userId,
      'bookingId': bookingId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'booking_rejected',
      'refundAmount': refundAmount,
      'serviceName': serviceName,
    });

  } catch (e) {}
}

  // ✅ دالة إرسال إشعار رفض الحجز مع إرجاع المبلغ
 Future<void> sendBookingRejectionNotification({
  required String userId,
  required String bookingId,
  required double refundAmount,
  required BuildContext context,
}) async {
  try {
    // 1. جلب بيانات الحجز والمستخدم
    final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (!bookingDoc.exists || !userDoc.exists) {
      throw Exception('البيانات غير موجودة');
    }

    final token = userDoc['fcmToken'] as String?;
    final serviceName = bookingDoc['serviceName'] as String? ?? 'الخدمة';
    final providerName = FirebaseAuth.instance.currentUser?.displayName ?? 'مقدم الخدمة';

    if (token == null) {
      throw Exception('لا يوجد token إشعارات للمستخدم');
    }

    // 2. صياغة رسالة الرفض الجديدة حسب الطلب
    final title = 'تم رفض حجزك';
    final body = refundAmount > 0 
        ? 'لقد تم رفض حجزك لخدمة "$serviceName" وتم إرجاع المبلغ المحجوز ${NumberFormat('#,###', 'ar').format(refundAmount)} ريال إلى محفظتك'
        : 'لقد تم رفض حجزك لخدمة "$serviceName"';

    // 3. إرسال الإشعار عبر FCM
    await _sendFcmNotification(
      token: token,
      title: title,
      body: body,
      bookingId: bookingId,
    );

    // 4. حفظ الإشعار في Firestore مع معلومات الإرجاع
    await _firestore.collection('notifications').add({
      'userId': userId,
      'bookingId': bookingId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'booking_rejected',
      'refundAmount': refundAmount,
      'serviceName': serviceName,
    });

  } catch (e) {}
}

  // ✅ دالة إرسال إشعار FCM
  Future<void> _sendFcmNotification({
    required String token,
    required String title,
    required String body,
    String? bookingId,
  }) async {
    try {
      final jsonString = await rootBundle.loadString(_serviceAccountPath);
      final serviceAccountJson = json.decode(jsonString) as Map<String, dynamic>;
      
      final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final authClient = await clientViaServiceAccount(accountCredentials, scopes);

      final projectId = serviceAccountJson['project_id'];
      final url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
      
      final message = {
        "message": {
          "token": token,
          "notification": {
            "title": title,
            "body": body,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "type": "booking_update",
            if (bookingId != null) "booking_id": bookingId,
          }
        }
      };

      final response = await authClient.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(message),
      );

      if (response.statusCode != 200) {
        throw Exception('فشل إرسال الإشعار: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في إرسال FCM: $e');
    }
  }

  // ✅ دالة لحفظ الإشعار في Firestore
  Future<void> _saveNotificationToFirestore({
    required String userId,
    required String bookingId,
    required String title,
    required String body,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'bookingId': bookingId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'booking_status',
    });
  }

  // ✅ دالة لعرض رسالة نجاح
  void _showSuccessSnackbar(BuildContext context, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('تم إرسال الإشعار بنجاح'),
          ],
        ),
        backgroundColor: color,
      ),
    );
  }

  // ✅ دالة لعرض رسالة خطأ
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }
}