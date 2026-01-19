import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Theme - Modern Ocean Teal
/// Clean, professional, and calming design with Poppins font
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.poppinsTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // ─────────────────────────────────────────────────────────────────
      // COLOR SCHEME
      // ─────────────────────────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
      ),

      // ─────────────────────────────────────────────────────────────────
      // TYPOGRAPHY
      // ─────────────────────────────────────────────────────────────────
      textTheme: textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      
      // ─────────────────────────────────────────────────────────────────
      // SCAFFOLD
      // ─────────────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.background,

      // ─────────────────────────────────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────
      // CARD
      // ─────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppColors.surface,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ─────────────────────────────────────────────────────────────────
      // NAVIGATION BAR
      // ─────────────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppColors.navBackground,
        indicatorColor: AppColors.primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final style = GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500);
          if (states.contains(WidgetState.selected)) {
            return style.copyWith(color: AppColors.navSelected);
          }
          return style.copyWith(color: AppColors.navUnselected);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.navSelected, size: 24);
          }
          return const IconThemeData(color: AppColors.navUnselected, size: 24);
        }),
      ),

      // ─────────────────────────────────────────────────────────────────
      // INPUT DECORATION
      // ─────────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.8)),
        prefixIconColor: AppColors.primary,
      ),

      // ─────────────────────────────────────────────────────────────────
      // ELEVATED BUTTON
      // ─────────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────
      // TEXT BUTTON
      // ─────────────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────
      // OUTLINED BUTTON
      // ─────────────────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────
      // ICON THEME
      // ─────────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),

      // ─────────────────────────────────────────────────────────────────
      // DIVIDER
      // ─────────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: AppColors.textTertiary.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),

      // ─────────────────────────────────────────────────────────────────
      // FLOATING ACTION BUTTON
      // ─────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ─────────────────────────────────────────────────────────────────
      // LIST TILE
      // ─────────────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
