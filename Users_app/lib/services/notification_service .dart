import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ دالة لجلب التوكن
  Future<String?> getToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token'); // عرض في الكونسول
    return token;
  }

  // ✅ دالة لحفظ التوكن في Firestore داخل users فقط
  Future<void> saveUserToken(String userId) async {
    String? token = await getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  // ✅ الاستماع لتحديث التوكن وتحديثه في users فقط
  void listenToTokenRefresh(String userId) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('🔄 Token تم تحديثه: $newToken');
      _firestore.collection('users').doc(userId).update({'fcmToken': newToken});
    });
  }
}
