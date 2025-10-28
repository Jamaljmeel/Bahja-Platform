import 'package:gam/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ProfilePage.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    return Scaffold(
      appBar: CustomAppBar(title: 'الاعدادات'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        ListTile(
            leading: Icon(Icons.person, color: Colors.green),
            title: Text(
              'اعدادات الحساب الشخصي',
              style: GoogleFonts.elMessiri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => ProfileManagementPage ()),
                  );
                  
            },
          ),
            ListTile(
              leading: Icon(isDarkMode ? Icons.nightlight_round : Icons.wb_sunny, color: isDarkMode ? Colors.yellow : Colors.blueAccent),
              title: Text(isDarkMode ? 'الوضع الفاتح' : 'الوضع الداكن', style: GoogleFonts.elMessiri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              )),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),

                ListTile(
            leading: Icon(Icons.logout, color: Colors.grey),
            title: Text(
              'تسجيل الخروج',
              style: GoogleFonts.elMessiri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut(); // تسجيل الخروج من Firebase
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false); // حذف حالة تسجيل الدخول
              Navigator.pushReplacement( // الانتقال إلى صفحة تسجيل الدخول
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          ],
        ),
      ),
    );
  }
}
