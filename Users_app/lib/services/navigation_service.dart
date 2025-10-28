import 'package:flutter/material.dart';
import '../booking/screens/booking_page.dart';
import '../screens/HomePage.dart';
import '../screens/LearnMore.dart';
import '../chat/screens/ChatPage.dart';
import '../utils/auth_utils.dart';

class NavigationService {
  static Future<void> onItemTapped(BuildContext context, int index, Function(int) updateIndex) async {
    updateIndex(index); // تحديث المؤشر في الصفحة الحالية

    final authUtils = AuthUtils(); // إنشاء مثيل من AuthUtils

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } 
    else if (index == 1) {
      // التحقق من حالة المستخدم قبل فتح المحادثات
      bool isValid = await authUtils.verifyUserStatus(context);
      if (!isValid) {
        updateIndex(0); // العودة إلى المؤشر الأول إذا فشل التحقق
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatsPage()),
      );
    } 
    else if (index == 2) {
      // التحقق من حالة المستخدم قبل فتح صفحة الحجز
      bool isValid = await authUtils.verifyUserStatus(context);
      if (!isValid) {
        updateIndex(0); // العودة إلى المؤشر الأول إذا فشل التحقق
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BookingPage()),
      );
    }
    else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LearnMore()),
      );
    }
  }
}