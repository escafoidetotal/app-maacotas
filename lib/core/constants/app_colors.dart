import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color accent = Color(0xFFFFE66D);
  static const Color background = Color(0xFFFFF9F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFFFF6B35),
    Color(0xFFFF8E53),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF4ECDC4),
    Color(0xFF44A08D),
  ];

  // Dark theme variants
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkCard = Color(0xFF0F3460);

  // Breed colors
  static const Color labradorGold = Color(0xFFD4A017);
  static const Color huskyGrey = Color(0xFF9E9E9E);
  static const Color poodleWhite = Color(0xFFF5F5F5);
  static const Color bulldogTan = Color(0xFFD2B48C);
  static const Color shepherdBrown = Color(0xFF8B4513);

  // PawPoints
  static const Color pawPointsGold = Color(0xFFFFD700);
  static const Color pawPointsBronze = Color(0xFFCD7F32);
  static const Color pawPointsSilver = Color(0xFFC0C0C0);
}
