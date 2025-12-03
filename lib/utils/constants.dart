import 'package:flutter/material.dart';

class AppConstants {
  // Colors - Simple and consistent
  static const primaryRed = Color(0xFFE53935);
  static const accentGold = Color(0xFFFFB300);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const danger = Color(0xFFE53935);

  // Background colors
  static const backgroundColor = Colors.white;
  static const cardColor = Color(0xFFF5F5F5);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);

  // Game Settings - Kindle
  static const kindleTargetPages = 14;
  static const kindleTimeSeconds = 20;

  // Game Settings - Popcorn
  static const popcornTarget = 10;
  static const popcornTimeSeconds = 20;

  // Game Settings - Makeup (no timer)
  static const makeupPumpTaps = 3;
  static const makeupApplicationTaps = 5;
}

class SinterklaasTheme {
  static ThemeData get theme => ThemeData(
        primaryColor: AppConstants.primaryRed,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.light(
          primary: AppConstants.primaryRed,
          secondary: AppConstants.accentGold,
          background: AppConstants.backgroundColor,
          surface: Colors.white,
        ),
        useMaterial3: true,
      );
}
