import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../theme/app_theme.dart';

// دالة عرض رسالة تأكيد
Future<bool> showConfirmationDialog(BuildContext context, String title, String content) async {
  final theme = Theme.of(context);
  final customColors = AppThemes.customColors(context);

  return await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: customColors.borderColor),
      ),
      title: Text(
        title,
        style: AppTextStyles.medium(context).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        content,
        style: AppTextStyles.small(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'إلغاء',
            style: AppTextStyles.small(context).copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
          ),
          child: Text(
            'تأكيد',
            style: AppTextStyles.small(context).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  ) ?? false;
}

// دالة عرض رسالة نجاح أو خطأ
void showMessageDialog(BuildContext context, String title, String message) {
  final theme = Theme.of(context);
  final customColors = AppThemes.customColors(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: customColors.borderColor),
      ),
      title: Text(
        title,
        style: AppTextStyles.medium(context).copyWith(
          // color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: AppTextStyles.small(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'حسناً',
            style: AppTextStyles.small(context).copyWith(
              color: AppColors.secondary,
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
  final customColors = AppThemes.customColors(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: customColors.borderColor),
      ),
      title: Text(
        title,
        style: AppTextStyles.medium(context).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: AppTextStyles.small(context).copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: Text(
            'حسناً',
            style: AppTextStyles.small(context).copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}