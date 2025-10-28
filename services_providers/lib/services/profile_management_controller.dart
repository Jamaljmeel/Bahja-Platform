import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../utils/dialog_utils.dart';

class ProfileManagementController {
  final AuthService _authService = AuthService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isUpdating = false;

  // تحميل بيانات المستخدم
  Future<void> loadUserData(BuildContext context, Function setState) async {
    // يمكنك استرجاع بيانات المستخدم من Firestore هنا إذا لزم الأمر
  }

  // تحديث اسم المستخدم
  Future<void> updateUsername(BuildContext context, Function setState) async {
    if (usernameController.text.isEmpty) {
      showMessageDialog(context, 'خطأ ❌', '❌ يجب إدخال اسم المستخدم الجديد.');
      return;
    }

    setState(() => isUpdating = true);
    String userId =  _authService.getCurrentUser()!.uid; // استبدله بمعرف المستخدم الحقيقي
    await _authService.updateUsername(userId, usernameController.text, context);
    setState(() => isUpdating = false);
  }

  // تحديث كلمة المرور
  Future<void> updatePassword(BuildContext context, Function setState) async {
    if (newPasswordController.text.isEmpty || oldPasswordController.text.isEmpty) {
      showMessageDialog(context, 'خطأ ❌', '❌ يجب إدخال جميع الحقول.');
      return;
    }
      // ✅ التحقق من تعقيد كلمة المرور
  final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
  if (!passwordRegex.hasMatch(newPasswordController.text)) {
    showMessageDialog(context, 'خطأ ❌', '⚠️ كلمة المرور يجب أن تحتوي على حروف وأرقام وأن تكون 6 أحرف على الأقل.');
    return;
  }
    if (newPasswordController.text != confirmPasswordController.text) {
      showMessageDialog(context, 'خطأ ❌', '❌ كلمة المرور غير متطابقة.');
      return;
    }

    setState(() => isUpdating = true);
    await _authService.updatePassword(
      oldPasswordController.text,
      newPasswordController.text,
      context,
    );
    setState(() => isUpdating = false);
  }
}
