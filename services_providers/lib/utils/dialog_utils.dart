import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// دالة عرض رسالة تأكيد
Future<bool> showConfirmationDialog(BuildContext context, String title, String content) async {
  final theme = Theme.of(context);

  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.dialogBackgroundColor, // الخلفية حسب الثيم
      title: Text(
        title,
        style: GoogleFonts.elMessiri(
          fontSize: 18,
          color: theme.colorScheme.primary, // لون العنوان يعتمد على الثيم
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: GoogleFonts.elMessiri(
          fontSize: 14,
          color: theme.textTheme.bodyLarge!.color, // لون النص حسب الثيم
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false); // إلغاء
          },
          child: Text(
            'إلغاء',
            style: GoogleFonts.elMessiri(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary, // لون النص حسب الثيم
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true); // تأكيد
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
            backgroundColor: theme.colorScheme.error, // لون الزر يعتمد على الثيم
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'تأكيد',
            style: GoogleFonts.elMessiri(
              color: theme.colorScheme.onError, // لون النص متوافق مع لون الزر
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ) ?? false; // إذا تم إغلاق النافذة بدون اختيار، يتم إرجاع false
}

// دالة عرض رسالة نجاح أو خطأ
void showMessageDialog(BuildContext context, String title, String message) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.dialogBackgroundColor, // الخلفية حسب الثيم
      title: Text(
        title,
        style: GoogleFonts.elMessiri(
          fontSize: 18,
          color: theme.colorScheme.primary, // لون العنوان يعتمد على الثيم
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: GoogleFonts.elMessiri(
          fontSize: 14,
          color: theme.textTheme.bodyLarge!.color, // لون النص حسب الثيم
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // إغلاق النافذة
          },
          child: Text(
            'حسناً',
            style: GoogleFonts.elMessiri(
              fontSize: 14,
              color: theme.colorScheme.secondary, // لون النص حسب الثيم
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

void showMessageDialogs(BuildContext context, String title, String message) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.dialogBackgroundColor, // الخلفية حسب الثيم
      title: Text(
        title,
        style: GoogleFonts.elMessiri(
          fontSize: 18,
          color: theme.colorScheme.primary, // لون العنوان يعتمد على الثيم
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: GoogleFonts.elMessiri(
          fontSize: 14,
          color: theme.textTheme.bodyLarge!.color, // لون النص حسب الثيم
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // إغلاق النافذة
             Navigator.pushReplacementNamed(context, '/home');
          },
          child: Text(
            'حسناً',
            style: GoogleFonts.elMessiri(
              fontSize: 14,
              color: theme.colorScheme.secondary, // لون النص حسب الثيم
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
