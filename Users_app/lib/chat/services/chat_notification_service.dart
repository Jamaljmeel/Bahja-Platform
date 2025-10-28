import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart'; // مكتبة مصادقة Google APIs
import '../../services/notification_service .dart';

class ChatNotificationServiceV1 {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // بيانات الخدمة (من ملف JSON الخاص بـ Service Account)
  final String projectId = 'gam-app-313a5'; // ضع هنا project_id
  final String clientEmail =
      'firebase-adminsdk-fbsvc@gam-app-313a5.iam.gserviceaccount.com'; // client_email
  final String privateKey =
      '''-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDy6mQxYxRpFDSC\nkJsDWkb267Fl5WltDO3roY/2bjZJmV3asvhvZTAre6UfaF4OuZmMy2sIkvlhXJqp\nyFdN1Ttm0rJKE9aoVfMGPg8m7jern30xGcyoEQhoo2ta2eOjyxLt8kogLOwDWh+b\nuhfpfLyy+1wObhqZyYUovzF+1NJr2Et78N8q0yZMyLkvotG+g7jBgRroShvRf0Xk\ns48gxFtO3ET2osjZjOSQ5s+ISmuTjsNGzOEdfkt1NekPZQjWjyEWjmTVmCCFgJsP\n2GbSkmjMJu16g3sTS0KbKTsd9SDiAU3wXtU7CwSjgwRiMxfnZT8pWTPpvi9XMKEf\n1LPxiIwfAgMBAAECggEAHjXNUSEP3EOhhi1iwed71OCaFuCRnHjTrA7TPyQUx1F2\nDSld4Ui11WqSrhXGQNGPSaXQwWe58QRZzcy3Itxmf1Krzq+p7hSGXVvheYd9z+/N\nW4poW+yGXbEZPFrFx0yNpZ8Q3fCIR6BxNuZNbAHR2/aLy9WgpEieMWOZzbq9EqE9\nNRXCfp5J6q1f4i79xzoffuHg+VnY3X0nQPwFqCQfEOgXmBazu46t3wPXXS+VmYDL\nrVuPOBtCSyzbYyCWV2oW+FzBmV/L0+i28pLTlc4BVKrImKuXEe9Mv0JbqSqXMnay\nLX/hsAD3X9nCGK9LldkRH9wa0zpm5+eJ+h1A1Lv1EQKBgQD9Vic18e6moH1T8wdw\nl5WAj2BOTXxO4IlHsJVBgkw5snwUpr5r/9oEvrd93CSmhu1nJqaBIL0pc0rIV/xV\nkK0ezfvFrAtIP+NcsYHI8GnidaLehIvEsfhtAFhhwvFJQ09WbaXqIW7b5k84dlK8\n9LHarpVFI5eGdqwAoHZx1rUhTwKBgQD1eDDKVM5uxqc/36/gCb0mx3+El5MLAsTw\npW8NNaHyLqSdC3U+K9YaFC82gLHUZ9h+LxfcjPhWZmQ5Q15qLxT9UoW2uxJn3jLJ\ndGkMhJZz0R4kroGLNSKRjheBoQyoJLCYmhK6EvJJaQmVmeLkE2SSewJqU7hw3W0O\n4UtqGs0UMQKBgQD3Xj2RXjgS+hkGdQMpvModq2J1cxHTj0pc9x72xX0axZ6FJ8A+\ngqhnA7b2LZSYCp4bn9Dru4UZyVsXP1rETi3NK4MRpImrtb6TjzxUcfRiTU2Ii9JS\ncRlLjg++/fRO/muk0BI3CQhPrpZiYp8tpJ1aFCjrRvK5OH2Bay3cwLNC3wKBgQDJ\nNmmAIT5KLcrBIAIR+smzNQsBTCI7f1yiCmnagSEr3TIQjWjgupw5Klx9J8cdXrZm\n0QGVR3T1ld8H1YJaNhfVg0SaQgRXYhttaWAG49RUQZGc7fLAgqDAgaIhHzu5xMGB\nhaJeJtO2e0Rg/hCvdnoVXIHhWJky4z7XWLQx2KBMsQKBgBhfFMblb/YQp3zOSueu\nBNw5q6hAZ1JKHhwoPl/FCrSSWTEUc78MnBrNJL0zV9h2o41qbU0S0pNa5/6P/JyJ\novBOxV+LnHm46yrsBedoC1zQ9jdq0JfsWPe7ea89rv8aPb/fi0fMm5cvVOr97002\nMwvcilnuqVIinRPKYYmgqZGK\n-----END PRIVATE KEY-----\n'''; // private_key

  // ✅ إرسال إشعار لمقدم الخدمة
  Future<void> sendNotificationToProvider(
      String providerId, String message, String senderName) async {
    await _sendNotification(
      receiverId: providerId,
      messageBody: message,
      senderName: senderName,
      title: 'رسالة جديدة من $senderName',
    );
  }

  // ✅ الدالة العامة لإرسال الإشعارات
  Future<void> _sendNotification({
    required String receiverId,
    required String messageBody,
    required String senderName,
    required String title,
  }) async {
    try {
      // ✅ جلب FCM Token لمقدم الخدمة
      String? token = await _getToken(receiverId);

      if (token == null) {
        print('❌ لا يوجد FCM Token لهذا المستخدم');
        return;
      }

      // ✅ الحصول على Access Token
      String accessToken = await _getAccessToken();

      // رابط API V1
      final url =
          'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      // بيانات الإشعار
      final body = jsonEncode({
        "message": {
          "token": token,
          "notification": {
            "title": title,
            "body": messageBody,
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "senderName": senderName,
          }
        }
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('✅ تم إرسال الإشعار بنجاح');
      } else {
        print('❌ فشل في إرسال الإشعار. الحالة: ${response.statusCode}');
        print('Body: ${response.body}');
      }
    } catch (e) {
      print('❌ خطأ أثناء إرسال الإشعار: $e');
    }
  }

  // ✅ جلب FCM Token من Firestore
  Future<String?> _getToken(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('providers').doc(userId).get();

      if (doc.exists && doc['fcmToken'] != null) {
        return doc['fcmToken'];
      } else {
        print('❌ مقدم الخدمة غير موجود أو لا يملك FCM Token');
        return null;
      }
    } catch (e) {
      print('❌ خطأ في جلب التوكن: $e');
      return null;
    }
  }

  // ✅ توليد Access Token لاستخدام FCM V1
  Future<String> _getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials(
      clientEmail,
      ClientId('', ''),
      privateKey.replaceAll(r'\n', '\n'),
    );

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final accessToken = client.credentials.accessToken.data;

    client.close();
    return accessToken;
  }

  // ✅ تحديث التوكن (خاص بالمستخدمين فقط)
  Future<void> updateToken(String userId, String token) async {
    await _notificationService.saveUserToken(userId);
  }

}
