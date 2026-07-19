import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color baseSurfaceColor = Color(0xFF0A0A0C);

  static ThemeData light() {
    // We only support dark mode per specifications. Let's return dark mode here too.
    return dark();
  }

  static ThemeData dark() {
    final textTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: baseSurfaceColor,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFF5F5F7),
        surface: baseSurfaceColor,
        error: Color(0xFFEF4444),
      ),
      textTheme: textTheme.copyWith(
        displaySmall: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF5F5F7),
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFF5F5F7),
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF5F5F7),
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFF5F5F7),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: const Color(0xFFF5F5F7),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFFB8B8C0),
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF8A8A93),
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF8A8A93),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: baseSurfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFB8B8C0)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: baseSurfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
