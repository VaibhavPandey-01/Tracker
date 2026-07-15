import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  // Display — for the big Spendable number
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 52,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: _textPrimary(context),
      );

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: _textPrimary(context),
      );

  static TextStyle displaySmall(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: _textPrimary(context),
      );

  // Headings
  static TextStyle headlineLarge(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _textPrimary(context),
      );

  static TextStyle headlineMedium(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textPrimary(context),
      );

  static TextStyle headlineSmall(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: _textPrimary(context),
      );

  // Body
  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textPrimary(context),
      );

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _textSecondary(context),
      );

  static TextStyle bodySmall(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _textSecondary(context),
      );

  // Labels
  static TextStyle labelLarge(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: _textPrimary(context),
      );

  static TextStyle labelMedium(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: _textSecondary(context),
      );

  static TextStyle labelSmall(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _textSecondary(context),
      );

  // Amount display with monospace feel
  static TextStyle amountLarge(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: AppColors.accent,
      );

  static TextStyle amountMedium(BuildContext context) =>
      GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: _textPrimary(context),
      );

  // Helpers
  static Color _textPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  }

  static Color _textSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  }
}
