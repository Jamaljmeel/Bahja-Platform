import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = AppThemes.customColors(context);
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      selectedItemColor: theme.primaryColor,
      unselectedItemColor: AppColors.grey,
      onTap: onItemTapped,
      selectedLabelStyle: AppTextStyles.small(context, fontWeight: FontWeight.bold),
      unselectedLabelStyle: AppTextStyles.extraSmall(context),
      backgroundColor: theme.scaffoldBackgroundColor,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'الدردشات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'الحجوزات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: 'المزيد',
        ),
      ],
    );
  }
}