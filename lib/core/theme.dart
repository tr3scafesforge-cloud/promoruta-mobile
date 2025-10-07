import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/colors.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary).copyWith(
      outline: AppColors.grayLightStroke,
      surface: AppColors.background,
      surfaceContainerHighest: AppColors.surface.withValues(alpha: 0.8),
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.robotoFlex().fontFamily,
    scaffoldBackgroundColor: AppColors.primary,
  );

  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      outline: AppColors.grayDarkStroke,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceDark.withValues(alpha: 0.8),
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.robotoFlex().fontFamily,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    cardColor: AppColors.surfaceDark,
  );
}