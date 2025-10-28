import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // الألوان الأساسية
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.blueAccent;
  static const Color grey = Colors.grey;
  static const Color successColor = Colors.                                                                                                                 green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color surfaceColor =Color.fromARGB(255, 255, 255, 255);
    static const Color accentColor =Color.fromARGB(255, 255, 132, 98);
  // ألوان الوضع الفاتح
  static const _LightColors light = _LightColors();

  // ألوان الوضع الداكن
  static const _DarkColors dark = _DarkColors();

  // ألوان متغيرة حسب الثيم
  static Color backgroundColor(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? dark.background : light.background;

  static Color textColor(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? dark.text : light.text;

  static Color borderColor(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? dark.border : light.border;

  static Color inputFillColor(BuildContext context) => 
      Theme.of(context).brightness == Brightness.dark ? dark.inputFill : light.inputFill;
}

class _LightColors {
  const _LightColors();
  final Color background = Colors.white;
  final Color text = Colors.black;
  final Color border = const Color(0xFFBDBDBD);
  final Color inputFill = const Color(0xFFFFFFFF);
}

class _DarkColors {
  const _DarkColors();
  final Color background = Colors.black;
  final Color text = Colors.white;
  final Color border = const Color(0xFF757575);
  final Color inputFill = const Color(0xFF1E1E1E);
}

class AppFonts {
  
  // أحجام الخطوط
  static const double sizeExtraSmall = 10.0;
  static const double sizeSmall = 12.0;
  static const double sizeMedium = 14.0;
  static const double sizeLarge = 16.0;
  static const double sizeExtraLarge = 18.0;
  static const double sizeHeading = 20.0;
  static const double sizeTitle = 24.0;
  static const double sizeDisplay = 28.0;
}

class AppTextStyles {
  // أنماط النص الأساسية
  static TextStyle extraSmall(BuildContext? context, {FontWeight? fontWeight}) => GoogleFonts.elMessiri(
    fontSize: AppFonts.sizeExtraSmall,
    fontWeight: fontWeight ?? FontWeight.normal,
   color: context != null ? AppColors.textColor(context) : AppColors.light.text,
    fontFeatures: const [FontFeature.proportionalFigures()],
  );

  static TextStyle small(BuildContext? context, {FontWeight? fontWeight}) => GoogleFonts.elMessiri(
    fontSize: AppFonts.sizeSmall,
    fontWeight: fontWeight ?? FontWeight.normal,
   color: context != null ? AppColors.textColor(context) : AppColors.light.text,
    fontFeatures: const [FontFeature.proportionalFigures()],
  );

  static TextStyle medium(BuildContext? context, {FontWeight? fontWeight}) => GoogleFonts.elMessiri(
    fontSize: AppFonts.sizeMedium,
    fontWeight: fontWeight ?? FontWeight.normal,
    color: context != null ? AppColors.textColor(context) : AppColors.light.text,
    fontFeatures: const [FontFeature.proportionalFigures()],
  );

  static TextStyle large(BuildContext? context, {FontWeight? fontWeight}) => GoogleFonts.elMessiri(
    fontSize: AppFonts.sizeLarge,
    fontWeight: fontWeight ?? FontWeight.normal,
    color: context != null ? AppColors.textColor(context) : AppColors.light.text,
    fontFeatures: const [FontFeature.proportionalFigures()],
  );

  static TextStyle extraLarge(BuildContext? context, {FontWeight? fontWeight}) => GoogleFonts.elMessiri(
    fontSize: AppFonts.sizeExtraLarge,
    fontWeight: fontWeight ?? FontWeight.normal,
    color: context != null ? AppColors.textColor(context) : AppColors.light.text,
    fontFeatures: const [FontFeature.proportionalFigures()],
  );

  // أنماط النص الخاصة
  static TextStyle heading(BuildContext? context) => GoogleFonts.elMessiri(
    fontSize: AppFonts.sizeHeading,
    fontWeight: FontWeight.bold,
    color: context != null ? AppColors.textColor(context) : AppColors.light.text,
    fontFeatures: const [FontFeature.proportionalFigures()],
  );

  static TextStyle title(BuildContext? context) => GoogleFonts.elMessiri(
    fontSize: AppFonts.sizeTitle,
    fontWeight: FontWeight.bold,
    color: context != null ? AppColors.textColor(context) : AppColors.light.text,
    fontFeatures: const [FontFeature.proportionalFigures()],
  );

  static TextStyle display(BuildContext? context) => GoogleFonts.elMessiri(
    fontSize: AppFonts.sizeDisplay,
    fontWeight: FontWeight.bold,
    color: context != null ? AppColors.textColor(context) : AppColors.light.text,
    fontFeatures: const [FontFeature.proportionalFigures()],
  );

  static TextStyle appBarTitle(BuildContext? context) => GoogleFonts.elMessiri(
    fontSize: AppFonts.sizeHeading,
    fontWeight: FontWeight.bold,
     color: context != null ? AppColors.textColor(context) : AppColors.light.text,
    fontFeatures: const [FontFeature.proportionalFigures()],
  );

  static TextStyle button(BuildContext? context) => GoogleFonts.elMessiri(
    fontSize: AppFonts.sizeMedium,
    fontWeight: FontWeight.bold,
    color: context != null ? AppColors.textColor(context) : AppColors.light.text,
    fontFeatures: const [FontFeature.proportionalFigures()],
  );
}

class AppThemeExtensions extends ThemeExtension<AppThemeExtensions> {
  final Color borderColor;
  final Color inputFillColor;

  AppThemeExtensions({
    required this.borderColor,
    required this.inputFillColor,
  });

  @override
  ThemeExtension<AppThemeExtensions> copyWith({
    Color? borderColor,
    Color? inputFillColor,
  }) {
    return AppThemeExtensions(
      borderColor: borderColor ?? this.borderColor,
      inputFillColor: inputFillColor ?? this.inputFillColor,
    );
  }

  @override
  ThemeExtension<AppThemeExtensions> lerp(
    ThemeExtension<AppThemeExtensions>? other, 
    double t,
  ) {
    if (other is! AppThemeExtensions) return this;
    return AppThemeExtensions(
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      inputFillColor: Color.lerp(inputFillColor, other.inputFillColor, t)!,
    );
  }
}