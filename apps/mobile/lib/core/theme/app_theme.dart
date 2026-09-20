import 'package:flutter/material.dart';

class AppTheme {
  // Colors matching Web Next.js OKLCH values
  static const Color primaryColor = Color(0xFF156B46);
  static const Color primaryForeground = Color(0xFFE8F5EE);
  static const Color secondaryColor = Color(0xFFE69D2A);
  static const Color secondaryForeground = Color(0xFF3D2D12);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color foregroundColor = Color(0xFF2E3338);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE5E5E5);
  static const Color errorColor = Color(0xFFD32F2F);

  // Border radius matching Web (shadcn rounded-lg/md)
  static const double borderRadiusSm = 4.0;
  static const double borderRadiusMd = 6.0;
  static const double borderRadiusLg = 8.0;
  static const double borderRadiusXl = 12.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: primaryForeground,
        secondary: secondaryColor,
        onSecondary: secondaryForeground,
        surface: cardColor,
        onSurface: foregroundColor,
        error: errorColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: foregroundColor),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLg),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: primaryForeground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: const BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: TextStyle(color: foregroundColor.withValues(alpha: 0.8), fontSize: 14),
        hintStyle: TextStyle(color: foregroundColor.withValues(alpha: 0.5), fontSize: 14),
      ),
    );
  }
}
