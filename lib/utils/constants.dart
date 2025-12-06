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
  static const kindleTargetPages = 140;
  static const kindleTimeSeconds = 20;

  // Game Settings - Popcorn
  static const popcornTarget = 18;
  static const popcornTimeSeconds = 20;

  // Game Settings - Makeup (no timer)
  static const makeupPumpTaps = 3;
  static const makeupApplicationTaps = 5;

  // Game Codes
  static const codeKindle = 'E-READER';
  static const codePopcorn = 'POPCORN';
  static const codeMakeup = 'MAKE-UP';
  static const codeGift = 'KADOOTJE';

  // Hints - in het gedicht moet de locatie van de make-up qr code staan daarna eerst makeup spel dan popcorn dan kindle dan laatste hint
  static const hintKindle = 'Zoek naar het kadootje dichtbij Seoul en Tokyo';
  static const hintPopcorn = 'Check the place where kernels pop!';
  static const hintMakeup =
      'In een groene draak zul je vinden wat je zoekt. Deze draak bevindt zich naast een alpaca';
  static const hintGift =
      'Je kado is te vinden achter een lichtgevend en geluidmakend beeldscherm';
  static const hintFinalCodeLocation =
      'Zoek het kadootje... op het zwarte muziekinstrument!';
}

class SinterklaasTheme {
  static ThemeData get theme => ThemeData(
        primaryColor: AppConstants.primaryRed,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.light(
          primary: AppConstants.primaryRed,
          secondary: AppConstants.accentGold,
          surface: Colors.white,
        ),
        useMaterial3: true,
      );
}
