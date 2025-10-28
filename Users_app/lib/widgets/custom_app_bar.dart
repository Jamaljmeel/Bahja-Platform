import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const CustomAppBar({
    required this.title,
    this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = AppThemes.customColors(context);
    
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: AppBar(
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          onPressed: onBack ?? () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_circle_right,
            color: AppColors.textColor(context),
            size: 30,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.heading(context).copyWith(
            color: AppColors.textColor(context),
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CustomAppBars extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const CustomAppBars({
    required this.title,
    this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = AppThemes.customColors(context);
    
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          title,
          style: AppTextStyles.heading(context).copyWith(
            color: AppColors.textColor(context),
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}