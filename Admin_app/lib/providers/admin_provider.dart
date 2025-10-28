import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> adminLogin(String email, String password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //notifyListeners();
//دالة الموافقة على الخدمة
  Future<void> approveService(String serviceId) async {
    await _firestore
        .collection('service_providers')
        .doc(serviceId)
        .update({'hasOffer': true});

    //
    //: جلب بيانات الخدمة للحصول على userId
    DocumentSnapshot serviceDoc =
        await _firestore.collection('service_providers').doc(serviceId).get();

    String userId = serviceDoc['userId'];

    // تحديث الحالة
    await _firestore
        .collection('service_providers')
        .doc(serviceId)
        .update({'hasOffer': true});

    // جلب توكن المستخدم
    /* DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    String? token = userDoc['fcmToken'];

    // إرسال الإشعار
    if (token != null) {
      await sendPushNotification(
        token: token,
        title: 'تمت الموافقة على خدمتك',
        body: 'لقد تمت الموافقة على الخدمة  .',
      );
    }*/
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    if (userDoc.exists) {
      String? token = userDoc['fcmToken'];
      //  إرسال الإشعار
      if (token != null) {
        await sendPushNotification(
          token: token,
          title: 'تمت الموافقة على خدمتك',
          body: 'لقد تمت الموافقة على الخدمة  .',
        );
      }
    } else {
      print(' لا يوجد مستخدم بالمعرف: $userId');
      return;
    }

    //  حفظ الإشعار في Firestore
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': 'تمت الموافقة على خدمتك',
      'body': 'لقد تمت الموافقة على الخدمة',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> rejectService(String serviceId) async {
    //  جلب بيانات الخدمة
    DocumentSnapshot serviceDoc =
        await _firestore.collection('service_providers').doc(serviceId).get();

    if (!serviceDoc.exists) {
      print("⚠️ الخدمة غير موجودة، لا يمكن المتابعة.");
      return;
    }

    String userId = serviceDoc['userId'];

    //  حذف الخدمة بعد قراءة البيانات
    await _firestore.collection('service_providers').doc(serviceId).delete();

    //  جلب توكن المستخدم
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    String? token = userDoc['fcmToken'];

    //  إرسال إشعار الرفض
    if (token != null) {
      await sendPushNotification(
        token: token,
        title: 'تم رفض خدمتك',
        body: 'نأسف، لقد تم رفض الخدمة التي تقدمها.',
      );
    }

    //  حفظ الإشعار في Firestore
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': 'تم رفض خدمتك',
      'body': 'نأسف، لقد تم رفض الخدمة التي تقدمها.',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }

  // دالة لجلب عدد المستخدمين
  Stream<int> getUsersCount() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // جلب عدد الحجوزات
  Stream<int> getBookingsCount() {
    return _firestore
        .collection('bookings')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // جلب الإيرادات
  // Stream<double> getRevenue() {
  //   return _firestore.collection('revenue').snapshots().map((querySnapshot) {
  //     final totalRevenue = querySnapshot.docs.fold<double>(
  //       0.0,
  //       (sum, doc) {
  //         final data = doc.data() as Map<String, dynamic>;
  //         final commission =
  //             double.tryParse(data['commission'].toString()) ?? 0.0;
  //         return sum + commission;
  //       },
  //     );
  //     return totalRevenue;
  //   });
  // }

  //جلب  الايرادات
  Stream<double> getRevenue() {
    return _firestore.collection('bookings').snapshots().map((querySnapshot) {
      return querySnapshot.docs.fold<double>(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status']?.toString() ?? '';
        final fullPrice = double.tryParse(data['finalPrice'].toString()) ?? 0.0;

        if (status.toLowerCase() == 'completed') {
          return sum + (fullPrice * 0.05); //
          // خصم 10%
        }
        return sum;
      });
    });
  }

  // جلب عدد الشكاوى
  Stream<int> getComplaintsCount() {
    return _firestore
        .collection('ContactUs')
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  // جلب عدد الشكاوى الجديدة الذي لا تحتوي على ردود
  Stream<int> getNewComplaintsCount() {
    return FirebaseFirestore.instance
        .collection('ContactUs')
        .snapshots()
        .asyncMap((snapshot) async {
      int count = 0;
      for (var doc in snapshot.docs) {
        final responsesSnapshot =
            await doc.reference.collection('responses').get();
        if (responsesSnapshot.docs.isEmpty) {
          count++;
        }
      }
      return count;
    });
  }
}

// مسار ملف JSON لمفتاح حساب الخدمة
final String serviceAccountPath = 'assets/service-account.json';
//دالة لارسال الاشعار عند قبول او رفض الخدمة
Future<void> sendPushNotification({
  required String token,
  required String title,
  required String body,
}) async {
  final String jsonString = await rootBundle.loadString(serviceAccountPath);
  final Map<String, dynamic> serviceAccountJson = json.decode(jsonString);

  final accountCredentials =
      ServiceAccountCredentials.fromJson(serviceAccountJson);

  // النطاق الخاص بـ FCM
  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // المصادقة باستخدام حساب الخدمة
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
      }
    }
  };

  final response = await authClient.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(message),
  );

  if (response.statusCode == 200) {
    print('Notification sent successfully.');
  } else {
    print('Failed to send notification: ${response.statusCode}');
    print(response.body);
  }

  authClient.close();
}

/*void logout() {
    _auth.signOut();
    _isAuthenticated = false;
    notifyListeners();
  }*/
