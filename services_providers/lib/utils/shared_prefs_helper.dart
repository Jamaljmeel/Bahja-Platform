import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _isDarkModeKey = 'isDarkMode';
  static const String _isLoggedInKey = 'isLoggedIn';

  /// حفظ وضع الثيم (مظلم أو فاتح)
  static Future<void> setDarkMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDarkMode);
  }

  /// استرجاع وضع الثيم (مظلم أو فاتح)
  static Future<bool> getDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkModeKey) ?? false;
  }

  /// حفظ حالة تسجيل الدخول
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// استرجاع حالة تسجيل الدخول
  static Future<bool> getLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
}
