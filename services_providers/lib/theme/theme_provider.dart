import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // تحقق إذا كان المستخدم قد حدد الوضع مسبقًا
    if (prefs.containsKey('isDarkMode')) {
      _isDarkMode = prefs.getBool('isDarkMode')!;
    } else {
      // إذا كانت أول مرة تشغيل التطبيق، اجعل الوضع حسب إعدادات النظام
      _isDarkMode = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }

    notifyListeners();
  }
}
