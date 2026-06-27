import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface:
            AppColors.background, // Fixed deprecation (background -> surface)
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.primary),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
