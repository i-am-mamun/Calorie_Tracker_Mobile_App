import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkBg,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 22),
        headlineSmall: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleLarge: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: GoogleFonts.inter(color: AppColors.darkTextPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: AppColors.darkTextSecondary, fontSize: 13),
        bodySmall: GoogleFonts.inter(color: AppColors.darkTextTertiary, fontSize: 11),
        labelLarge: GoogleFonts.inter(color: AppColors.darkBg, fontWeight: FontWeight.w600, fontSize: 15),
      ),
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkBorder,
      iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkNavBar,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w500);
          }
          return GoogleFonts.inter(color: AppColors.darkTextTertiary, fontSize: 11);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.darkTextTertiary);
        }),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.lightSurface,
        onPrimary: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 22),
        headlineSmall: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleLarge: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleMedium: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontSize: 15),
        bodyMedium: GoogleFonts.inter(color: AppColors.lightTextSecondary, fontSize: 13),
        bodySmall: GoogleFonts.inter(color: AppColors.lightTextTertiary, fontSize: 11),
        labelLarge: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600, fontSize: 15),
      ),
      cardColor: AppColors.lightCard,
      dividerColor: AppColors.lightBorder,
      iconTheme: const IconThemeData(color: AppColors.lightTextSecondary),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightNavBar,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.w500);
          }
          return GoogleFonts.inter(color: AppColors.lightTextTertiary, fontSize: 11);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryDark);
          }
          return const IconThemeData(color: AppColors.lightTextTertiary);
        }),
      ),
    );
  }
}
