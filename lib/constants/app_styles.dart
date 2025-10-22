import 'package:flutter/material.dart';

// Colors
class AppColors {
  static const primary = Color(0xFF54AB26);
  static const secondary = Color(0xFFA11072);
  static const success = Color(0xFF00946B);
  static const error = Color(0xFFC41F0D);
  static const warning = Color(0xFFAD1B0B);

  static const backgroundMain = Color(0xFFFFFFFF);
  static const backgroundSubtle = Color(0xFFF6F6F6);
  static const backgroundDark = Color(0xFF1F2D26);

  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF727272);
  static const textDisabled = Color(0xFFB8B8B8);

  static const borderLight = Color(0xFFE0E0DF);
  static const borderStrong = Color(0xFF184637);

  static const card = Color(0xFFFFFFFF);   
}

// Fonts
class AppTextStyles {
  static const heading = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const subheading = TextStyle(
    fontFamily: 'Roboto Condensed',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const button = TextStyle(
    fontFamily: 'Roboto Condensed',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
