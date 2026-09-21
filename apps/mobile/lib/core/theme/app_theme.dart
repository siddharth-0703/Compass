import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Web OKLCH to Hex mappings (Verified from apps/web/src/app/globals.css)
  static const Color primaryLight = Color(0xFF09672E);
  static const Color primaryDark = Color(0xFF3AA85B);
  
  static const Color primaryForegroundLight = Color(0xFFF8F8F8);
  static const Color primaryForegroundDark = Color(0xFF000600);
  
  static const Color backgroundLight = Color(0xFFFEFCF4);
  static const Color backgroundDark = Color(0xFF0E1216);
  
  static const Color foregroundLight = Color(0xFF0E171E);
  static const Color foregroundDark = Color(0xFFF1EEE7);
  
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF121C23);
  
  static const Color borderLight = Color(0xFFE7E4DD);
  static const Color borderDark = Color(0x1FFFFFFF);
  
  static const Color secondaryLight = Color(0xFFF2943C);
  static const Color secondaryDark = Color(0xFF6D3800);
  
  static const Color destructiveLight = Color(0xFFB94642);
  static const Color destructiveDark = Color(0xFFDE3B3D);
  
  static const Color mutedLight = Color(0xFFF1EEE7);
  static const Color mutedDark = Color(0xFF19232A);

  // Border radius matching Web (shadcn rounded-lg = 0.75rem = 13.5px based on 18px base font, but let's use 12 for standard mobile scale)
  static const double borderRadiusLg = 12.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        onPrimary: primaryForegroundLight,
        secondary: secondaryLight,
        surface: backgroundLight,
        onSurface: foregroundLight,
        error: destructiveLight,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: foregroundLight,
        displayColor: foregroundLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: foregroundLight,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLg),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: primaryForegroundLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
