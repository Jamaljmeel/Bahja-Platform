import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/ContactUsPage .dart';
import '../screens/login_screen.dart';
import '../screens/provider_wallet.dart';
import '../theme/theme_provider.dart';
import '../utils/app_colors.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onItemTapped;

  CustomDrawer({Key? key, required this.onItemTapped}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [AppColors.primaryDark.withOpacity(0.8), AppColors.primaryDark.withOpacity(0.6)]
                    : [AppColors.primaryLight, AppColors.primaryLight.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle,
                  size: 50,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  'خدماتي',
                  style: GoogleFonts.elMessiri(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            Icons.home,
            'الرئيسية',
            () {
              onItemTapped(0);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            Icons.forum,
            'الحجوزات',
            () {
              onItemTapped(1);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            Icons.chat,
            'الدردشة',
            () {
              onItemTapped(2);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            Icons.person,
            'حسابي',
            () {
              onItemTapped(3);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            Icons.language,
            'المحفظة والمعاملات',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProviderWalletPage()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            Icons.support_agent,
            'تواصل معنا',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.dark_mode,
              color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
            ),
            title: Text(
              themeProvider.isDarkMode ? "الوضع الفاتح" : "الوضع المظلم",
              style: GoogleFonts.elMessiri(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              activeColor: AppColors.primaryDark,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          Divider(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
          _buildDrawerItem(
            context,
            Icons.logout,
            'تسجيل الخروج',
            () async {
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
      ),
      title: Text(
        title,
        style: GoogleFonts.elMessiri(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      onTap: onTap,
    );
  }
}