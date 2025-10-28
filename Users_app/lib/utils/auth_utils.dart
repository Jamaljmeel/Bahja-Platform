import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gam/services/auth_service.dart';
import '../utils/dialog_utils.dart';

class AuthUtils {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> checkUserStatus(BuildContext context) async {
    final user = _authService.getCurrentUser();
    
    if (user == null) {
      return {
        'isValid': false,
        'message': 'يجب تسجيل الدخول أولاً'
      };
    }

    await user.reload();
    final isEmailVerified = user.emailVerified;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return {
          'isValid': false,
          'message': 'لا يوجد بيانات لهذا المستخدم'
        };
      }

      final isVerified = userDoc.get('emailVerified') ?? false;
      final isSuspended = userDoc.get('isSuspended') ?? true;
      // final userType = userDoc.get('typeUser') ?? 'user';

      if (!isVerified) {
        return {
          'isValid': false,
          'message': 'يجب التحقق من الحساب أولاً\n(يمكنك التحقق من صفحة التحقق)'
        };
      }

      if (isSuspended) {
        return {
          'isValid': false,
          'message': 'الحساب موقوف مؤقتاً'
        };
      }

      // if (userType != 'user') {
      //   return {
      //     'isValid': false,
      //     'message': 'هذا الحساب ليس حساب مستخدم عادي'
      //   };
      // }

      return {'isValid': true};

    } catch (e) {
      print('Error checking user status: $e');
      return {
        'isValid': false,
        'message': 'حدث خطأ أثناء التحقق من حالة الحساب'
      };
    }
  }

  Future<bool> verifyUserStatus(BuildContext context) async {
    final status = await checkUserStatus(context);
    
    if (!status['isValid']) {
      showMessageDialog(
        context, 
        'تحذير', 
        status['message']
      );
      return false;
    }
    
    return true;
  }
}