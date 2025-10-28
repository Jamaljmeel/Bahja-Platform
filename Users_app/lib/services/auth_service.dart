import 'package:firebase_auth/firebase_auth.dart'; // استيراد Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // استيراد Firestore لتخزين البيانات
import 'package:flutter/material.dart'; // استيراد Flutter UI
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/HomePage.dart';
import '../utils/dialog_utils.dart';
import 'package:google_sign_in/google_sign_in.dart'; // استيراد Google Sign-In

import '../utils/shared_prefs_helper.dart';
import 'notification_service .dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // مثيل لـ Firebase Authentication
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // مثيل لـ Firestore
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // مثيل لـ Google Sign-In

   // ✅ التحقق من تعقيد كلمة المرور (تحتوي على أحرف وأرقام فقط)
  bool _isPasswordValid(String password) {
    return RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(password);
  }
  // دالة تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
Future<void> loginWithEmailAndPassword(
  String email,
  String password,
  BuildContext context,
) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    
    // التحقق من أن المستخدم قد تحقق من بريده الإلكتروني
    if (user != null && !user.emailVerified) {
      await _auth.signOut();
      showMessageDialog(context, 'خطأ ❌', '⚠️ يرجى التحقق من بريدك الإلكتروني أولاً');
      return;
    }

       // إرسال رابط التحقق
    await user?.sendEmailVerification();

    // جلب بيانات المستخدم من Firestore
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user?.uid).get();
    
    if (userDoc.exists) {
      String userType = userDoc.get('typeUser') ?? 'مقدم خدمة';
      bool isSuspended = userDoc.get('isSuspended');
      
      // التحقق من نوع المستخدم وحالته
      if (userType != 'مستخدم') {
        await _auth.signOut();
        showMessageDialog(context, 'خطأ ❌', '⚠️ هذا حساب مقدم خدمة');
      } else if (isSuspended = true) {
        await _auth.signOut();
        showMessageDialog(context, 'خطأ ❌', '⚠️ الحساب موقوف مؤقتاً');
      } else {
        // تحديث التوكن وحالة تسجيل الدخول
        await NotificationService().saveUserToken(user!.uid);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        showMessageDialogs(context, 'نجاح ✅', 'تم تسجيل الدخول بنجاح!');
      }
    } else {
      await _auth.signOut();
      showMessageDialog(context, 'خطأ ❌', '⚠️ لا توجد بيانات لهذا المستخدم');
    }
  } on FirebaseAuthException catch (e) {
    showMessageDialog(context, 'خطأ ❌', '⚠️ البريد الإلكتروني او كلمة المرور غلط');
  }
}
  
Future<void> createAccount(
  String email,
  String password,
  String confirmPassword,
  String username,
  BuildContext context,
) async {
  // التحقق من تطابق كلمتي المرور
  if (password != confirmPassword) {
    showMessageDialog(context, 'خطأ ❌', '⚠️ كلمتا المرور غير متطابقتين');
    return;
  }

  // التحقق من صحة البريد الإلكتروني
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(email)) {
    showMessageDialog(context, 'خطأ ❌', '⚠️ صيغة البريد الإلكتروني غير صالحة');
    return;
  }

  // التحقق من قوة كلمة المرور
  if (!_isPasswordValid(password)) {
    showMessageDialog(context, 'خطأ ❌', 
      '⚠️ يجب أن تحتوي كلمة المرور على:\n- أحرف وأرقام\n- 6 خانات على الأقل');
    return;
  }

  try {
    // إنشاء الحساب في Firebase Authentication
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    if (user == null) {
      showMessageDialog(context, 'خطأ ❌', '⚠️ فشل إنشاء الحساب');
      return;
    }

    // إرسال رابط التحقق
    await user.sendEmailVerification();

    // جلب FCM Token
    String? fcmToken = await NotificationService().getToken();

    // حفظ بيانات المستخدم مع تعطيل الحساب حتى التحقق
    await _firestore.collection('users').doc(user.uid).set({
      'username': username,
      'email': email,
      'password': password,
      'createdAt': FieldValue.serverTimestamp(),
      'typeUser': 'مستخدم',
      'isSuspended': false, // الحساب موقوف حتى التحقق
      'emailVerified': false, // لم يتم التحقق بعد
      'fcmToken': fcmToken,
    });

    showMessageDialogs(
      context, 
      'تم الإرسال ✅', 
      'تم إرسال رابط التحقق إلى بريدك الإلكتروني.\n'
      'يجب التحقق من البريد لتتمكن من تسجيل الدخول.'
    );
  } on FirebaseAuthException catch (e) {
    String errorMessage = 'حدث خطأ أثناء إنشاء الحساب';
    if (e.code == 'email-already-in-use') {
      errorMessage = '❌ البريد الإلكتروني مستخدم بالفعل';
    } else if (e.code == 'weak-password') {
      errorMessage = '❌ كلمة المرور ضعيفة جداً';
    }
    showMessageDialog(context, 'خطأ ❌', '⚠️ $errorMessage');
  }
}

Future<bool> checkEmailVerification() async {
  await _auth.currentUser?.reload();
  return _auth.currentUser?.emailVerified ?? false;
}


  // دالة تسجيل الدخول باستخدام Google
Future<void> signInWithGoogle(BuildContext context) async {
  try {
    // 1. بدء عملية تسجيل الدخول بواسطة جوجل
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception("تم إلغاء العملية من قبل المستخدم");
    }

    // 2. الحصول على بيانات المصادقة من جوجل
    final GoogleSignInAuthentication googleAuth = 
        await googleUser.authentication;

    // 3. إنشاء بيانات اعتماد Firebase باستخدام جوجل
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. تسجيل الدخول في Firebase باستخدام الاعتماد
    UserCredential userCredential = 
        await _auth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      // 5. الحصول على توكن الإشعارات (FCM)
      String? fcmToken = await NotificationService().getToken();

      // 6. التحقق مما إذا كان المستخدم موجودًا مسبقًا في Firestore
      DocumentSnapshot userDoc = 
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // 7. إذا كان مستخدمًا جديدًا، حفظ بياناته في Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'username': user.displayName ?? "مستخدم جوجل",
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'typeUser': 'مستخدم', // نوع الحساب
          'isSuspended': false, // غير موقوف
          'emailVerified': true, // البريد مؤكد تلقائيًا مع جوجل
          'fcmToken': fcmToken, // توكن الإشعارات
        });
      } else {
        // 8. إذا كان موجودًا مسبقًا، تحديث التوكن فقط
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': fcmToken,
        });
      }

      // 9. حفظ حالة تسجيل الدخول في SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // 10. إظهار رسالة نجاح وإعادة توجيه المستخدم
      showMessageDialogs(
        context, 
        'تم التسجيل بنجاح ✅', 
        'مرحبًا ${user.displayName}!'
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    }
  } catch (e) {
    // 11. معالجة الأخطاء وإظهار رسالة للمستخدم
    showMessageDialog(
      context, 
      'خطأ ❌', 
      'فشل التسجيل باستخدام جوجل: ${e.toString()}'
    );
    print(e.toString());
  }
}

  // دالة إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email, BuildContext context) async {
    // التحقق من أن البريد الإلكتروني غير فارغ
    if (email.isEmpty) {
      showMessageDialog(context, 'خطأ ❌', '❌ يرجى إدخال البريد الإلكتروني لإعادة تعيين كلمة المرور');
      return;
    }

    try {
      // إرسال بريد إلكتروني لإعادة تعيين كلمة المرور
      await _auth.sendPasswordResetEmail(email: email);

      // عرض نافذة منبثقة تؤكد إرسال الرابط
      showMessageDialog(context, 'نجاح ✅', 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني');
    } on FirebaseAuthException catch (e) {
      // عرض نافذة منبثقة تحتوي على رسالة الخطأ
      showMessageDialog(context, 'خطأ ❌', '⚠️ فشل إرسال الرابط');
    }
  }



  // تحديث اسم المستخدم في Firestore
  Future<void> updateUsername(String userId, String newUsername, BuildContext context) async {
    try {
      await _firestore.collection('users').doc(userId).update({'username': newUsername});
      showMessageDialogs(context, 'نجاح ✅', 'تم تحديث اسم المستخدم بنجاح!');
    } catch (e) {
      showMessageDialog(context, 'خطأ ❌', '⚠️ فشل في تحديث اسم المستخدم.');
    }
  }

  // تحديث كلمة المرور بعد إعادة المصادقة
  Future<void> updatePassword(String oldPassword, String newPassword, BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      showMessageDialog(context, 'خطأ ❌', '⚠️ المستخدم غير مسجل الدخول.');
      return;

    }

    try {
      // إعادة المصادقة
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      showMessageDialogs(context, 'نجاح ✅', 'تم تحديث كلمة المرور بنجاح!');
    } on FirebaseAuthException catch (e) { 
      showMessageDialog(context, 'خطأ ❌', '⚠️ كلمة المرور القديمه غير صحيحه');
    }
  }

Future<void> signOut() async {
  final user = _auth.currentUser;
  if (user != null) {
    // حذف التوكن من Firestore
    await _firestore.collection('users').doc(user.uid).update({
      'fcmToken': FieldValue.delete(),
    });
  }

  await _auth.signOut();

  // حذف حالة تسجيل الدخول من SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('isLoggedIn');

  await SharedPrefsHelper.clearUserData();
}


  // الحصول على المستخدم الحالي
  User? getCurrentUser() {
    return _auth.currentUser;
  }

}
