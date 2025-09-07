import 'package:flutter/material.dart';

/// App color palette following Material Design 3 principles
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF25607A); // buttonbackground
  static const Color primaryVariant = Color(0xFF164356); // background
  static const Color secondary = Color(
    0xFF0BFFFF,
  ); // buttonboarder/startButtonGreen
  static const Color accent = Color(0xFFFFCE00); // maincolor

  // Background colors
  static const Color background = Color(0xFF164356);
  static const Color surface = Color(0xFF25607A);
  static const Color surfaceVariant = Color(0xFF121212); // bgcolor
  static const Color onBackground = Colors.white;
  static const Color onSurface = Colors.white;

  // Text colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Color(0xFF25607A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9595); // textcolor
  static const Color textHint = Color(0xFF959595);

  // Input field colors
  static const Color inputFill = Color.fromARGB(171, 178, 177, 181);
  static const Color inputBorder = Color.fromARGB(130, 178, 177, 181);
  static const Color inputText = Color.fromARGB(149, 78, 78, 79);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color transparent = Colors.transparent;

  // Legacy color mappings for backward compatibility
  static const Color bgcolor = surfaceVariant;
  static const Color textcolor = textSecondary;
  static const Color maincolor = accent;
  static const Color startButtonGreen = secondary;
  static const Color signInRegisterbackgroundWhite = white;
  static const Color emailPasswordFill = inputFill;
  static const Color emailPasswordFillBorder = inputBorder;
  static const Color emailPasswordFillText = inputText;
  static const Color drawerbackgroundcolor = grey;
  static const Color buttonbackground = primary;
  static const Color buttonboarder = secondary;
}
