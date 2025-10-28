import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isDarkMode) async {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    await _saveTheme(isDarkMode);
  }

  Future<void> _saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppThemes {
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.light.background,
   
    extensions: <ThemeExtension<dynamic>>[
      AppThemeExtensions(
        borderColor: AppColors.light.border,
        inputFillColor: AppColors.light.inputFill,
      ),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.light.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.light.text),
      titleTextStyle: AppTextStyles.appBarTitle(null),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.light.background,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.display(null),
      displayMedium: AppTextStyles.title(null),
      displaySmall: AppTextStyles.heading(null),
      headlineMedium: AppTextStyles.extraLarge(null),
      headlineSmall: AppTextStyles.large(null),
      titleLarge: AppTextStyles.medium(null),
      bodyLarge: AppTextStyles.small(null),
      bodyMedium: AppTextStyles.extraSmall(null),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.secondary,
    scaffoldBackgroundColor: AppColors.dark.background,

    extensions: <ThemeExtension<dynamic>>[
      AppThemeExtensions(
        borderColor: AppColors.dark.border,
        inputFillColor: AppColors.dark.inputFill,
      ),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.dark.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.dark.text),
      titleTextStyle: AppTextStyles.appBarTitle(null),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.dark.background,
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: AppColors.grey,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.display(null),
      displayMedium: AppTextStyles.title(null),
      displaySmall: AppTextStyles.heading(null),
      headlineMedium: AppTextStyles.extraLarge(null),
      headlineSmall: AppTextStyles.large(null),
      titleLarge: AppTextStyles.medium(null),
      bodyLarge: AppTextStyles.small(null),
      bodyMedium: AppTextStyles.extraSmall(null),
    ),
  );

  static AppThemeExtensions customColors(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtensions>()!;
}