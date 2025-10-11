import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/colors.dart';

class AppTheme {
  static ThemeData lightTheme(Color seedColor) => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor).copyWith(
      outline: AppColors.grayLightStroke,
      surface: AppColors.background,
      surfaceContainerHighest: AppColors.surface.withValues(alpha: 0.8),
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.robotoFlex().fontFamily,
    scaffoldBackgroundColor: seedColor,
  );

  static ThemeData darkTheme(Color seedColor) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ).copyWith(
      outline: AppColors.grayDarkStroke,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      surfaceContainerHighest: AppColors.surfaceDark.withValues(alpha: 0.8),
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.robotoFlex().fontFamily,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.surfaceDark,
  );

  // Legacy getters for backward compatibility
  static ThemeData get legacyLightTheme => lightTheme(AppColors.primary);
  static ThemeData get legacyDarkTheme => darkTheme(AppColors.primary);
}