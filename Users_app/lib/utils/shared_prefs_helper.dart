import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {

   static const String _isLoggedInKey = 'isLoggedIn';
   static const String _userIdKey = 'userId';

  // ✅ حفظ حالة تسجيل الدخول
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  // ✅ استرجاع حالة تسجيل الدخول
  static Future<bool> getLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // ✅ حفظ userId
  static Future<void> setUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // ✅ استرجاع userId
  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // ✅ مسح بيانات المستخدم (تسجيل الخروج)
  static Future<void> clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userIdKey);
  }
}
