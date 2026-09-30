import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const nearBlack = Color(0xFF0A0A0A);
  static const offWhite = Color(0xFFF5F5F2);
  static const concrete = Color(0xFFC9C9C4);
  static const darkGray = Color(0xFF242424);
  static const midGray = Color(0xFF777772);
  static const acidLime = Color(0xFFC8FF1E);
  static const white = Colors.white;
}

abstract final class AppTheme {
  static const Color colorPrimary = AppColors.acidLime;
  static const Color colorSecondary = AppColors.nearBlack;

  static TextStyle display({
    double fontSize = 48,
    Color color = AppColors.nearBlack,
  }) {
    return GoogleFonts.syne(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 0.9,
      letterSpacing: -1.2,
      color: color,
    );
  }

  static TextStyle displayFor(
    BuildContext context, {
    double fontSize = 48,
    Color color = AppColors.nearBlack,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isArabic) {
      return GoogleFonts.ibmPlexSansArabic(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.05,
        color: color,
      );
    }

    return display(fontSize: fontSize, color: color);
  }

  static ThemeData lightThemeFor(Locale locale) {
    final isArabic = locale.languageCode == 'ar';
    final textTheme = (isArabic
            ? GoogleFonts.ibmPlexSansArabicTextTheme()
            : GoogleFonts.archivoTextTheme())
        .apply(
      bodyColor: AppColors.nearBlack,
      displayColor: AppColors.nearBlack,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.offWhite,
      colorScheme: const ColorScheme.light(
        primary: AppColors.acidLime,
        onPrimary: AppColors.nearBlack,
        secondary: AppColors.nearBlack,
        onSecondary: AppColors.white,
        surface: AppColors.offWhite,
        onSurface: AppColors.nearBlack,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.offWhite,
        foregroundColor: AppColors.nearBlack,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.nearBlack,
        ),
      ),
      dividerColor: AppColors.nearBlack.withValues(alpha: 0.12),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData get lightTheme => lightThemeFor(const Locale('en'));
}
