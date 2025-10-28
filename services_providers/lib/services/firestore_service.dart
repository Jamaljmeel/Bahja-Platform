// // lib/services/firestore_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/user_model.dart';

// class FirestoreService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // تحديث اسم المستخدم
//   Future<void> updateUsername(String userId, String newUsername) async {
//     await _firestore.collection('users').doc(userId).update({
//       'username': newUsername,
//     });
//   }

//   // الحصول على بيانات المستخدم
//   Future<User> getUserData(String userId) async {
//     final doc = await _firestore.collection('users').doc(userId).get();
//     if (doc.exists) {
//       return User.fromMap(doc.data()! as Map<String, dynamic>);
//     } else {
//       throw Exception('لم يتم العثور على بيانات المستخدم.');
//     }
//   }
// }

