import 'package:flutter/material.dart';
import 'colors.dart';

/// App text styles following Material Design 3 typography
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Font families
  static const String primaryFont = 'Oswald';
  static const String secondaryFont = 'BebasNeue';

  // Display styles
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    fontFamily: primaryFont,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    fontFamily: primaryFont,
  );

  // Button styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onPrimary,
    fontFamily: primaryFont,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onPrimary,
    fontFamily: primaryFont,
  );

  // Special styles
  static const TextStyle startButtonText = TextStyle(
    fontSize: 25,
    color: AppColors.primary,
    fontWeight: FontWeight.w400,
    fontFamily: secondaryFont,
  );

  static const TextStyle descriptionStyle = TextStyle(
    fontSize: 15,
    color: AppColors.white,
    fontWeight: FontWeight.w200,
    fontFamily: primaryFont,
  );

  // Legacy style mappings for backward compatibility
  static const TextStyle startText = displayLarge;
  static const TextStyle signInRegisterText = bodyLarge;
  static const TextStyle signInRegisterText2 = bodyLarge;
  static const TextStyle signInRegisterText3 = headlineLarge;
}

/// App input decoration styles
class AppInputDecorations {
  // Private constructor to prevent instantiation
  AppInputDecorations._();

  static InputDecoration get defaultDecoration => InputDecoration(
    hintStyle: const TextStyle(
      color: AppColors.inputText,
      fontSize: 15,
      fontFamily: AppTextStyles.primaryFont,
    ),
    fillColor: AppColors.inputFill,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.inputBorder, width: 1),
      borderRadius: BorderRadius.circular(100),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.secondary, width: 2),
      borderRadius: BorderRadius.circular(100),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.error, width: 1),
      borderRadius: BorderRadius.circular(100),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.error, width: 2),
      borderRadius: BorderRadius.circular(100),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static InputDecoration get roundedDecoration => defaultDecoration.copyWith(
    borderRadius: BorderRadius.circular(12),
    enabledBorder: defaultDecoration.enabledBorder?.copyWith(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: defaultDecoration.focusedBorder?.copyWith(
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: defaultDecoration.errorBorder?.copyWith(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: defaultDecoration.focusedErrorBorder?.copyWith(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  // Legacy decoration for backward compatibility
  static const textInputdecorataion = defaultDecoration;
}
