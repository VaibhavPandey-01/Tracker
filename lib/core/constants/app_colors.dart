import 'package:flutter/material.dart';

/// App color palette — dark-first design with a vibrant teal/indigo accent.
/// All colors use HSL-tuned values for visual harmony.
abstract class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF6C63FF); // Soft indigo-violet
  static const Color primaryLight = Color(0xFF9C8FFF);
  static const Color primaryDark = Color(0xFF4A44CC);

  // Accent
  static const Color accent = Color(0xFF00D4AA); // Vibrant teal
  static const Color accentLight = Color(0xFF4DFFD4);
  static const Color accentDark = Color(0xFF00A882);

  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkSurfaceVariant = Color(0xFF252542);
  static const Color darkCard = Color(0xFF1E1E35);
  static const Color darkBorder = Color(0xFF2E2E50);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF8F7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0EEFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Text
  static const Color darkTextPrimary = Color(0xFFF0EEFF);
  static const Color darkTextSecondary = Color(0xFF9090BB);
  static const Color darkTextMuted = Color(0xFF5A5A88);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF5A5A88);

  // Category colors
  static const Color catFood = Color(0xFFFF7043);
  static const Color catTransport = Color(0xFF42A5F5);
  static const Color catEssentials = Color(0xFF66BB6A);
  static const Color catShopping = Color(0xFFAB47BC);
  static const Color catEntertainment = Color(0xFFFFCA28);
  static const Color catHealth = Color(0xFFEF5350);
  static const Color catOther = Color(0xFF78909C);

  // Gradient stops
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF4A44CC),
  ];
  static const List<Color> accentGradient = [
    Color(0xFF00D4AA),
    Color(0xFF6C63FF),
  ];
  static const List<Color> dangerGradient = [
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];
}
