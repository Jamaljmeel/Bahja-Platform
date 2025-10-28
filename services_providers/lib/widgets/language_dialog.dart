import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../utils/app_colors.dart';

void showLanguageDialog(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
        title: Text(
          'اختر اللغة',
          style: GoogleFonts.elMessiri(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'العربية',
                style: GoogleFonts.elMessiri(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              onTap: () {
                // _changeLanguage(context, 'ar');
              },
            ),
            ListTile(
              title: Text(
                'English',
                style: GoogleFonts.elMessiri(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              onTap: () {
                // _changeLanguage(context, 'en');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.elMessiri(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            ),
          ),
        ],
      );
    },
  );
}