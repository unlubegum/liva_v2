import 'package:flutter/material.dart';

/// App color palette - Modern Ocean Teal Theme
/// Clean, professional, and calming aesthetic
class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────────────────────────
  // PRIMARY - Ocean Teal
  // ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF006D77);
  static const Color primaryLight = Color(0xFF83C5BE);
  static const Color primaryDark = Color(0xFF004D54);

  // ─────────────────────────────────────────────────────────────────
  // SECONDARY - Soft Teal
  // ─────────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF83C5BE);
  static const Color secondaryLight = Color(0xFFEDF6F9);
  static const Color secondaryDark = Color(0xFF5FA8A0);

  // ─────────────────────────────────────────────────────────────────
  // MODULE ACCENT COLORS
  // ─────────────────────────────────────────────────────────────────
  static const Color familyAccent = Color(0xFFFFB084);
  static const Color homeAccent = Color(0xFF7DD3C0);
  static const Color carAccent = Color(0xFF5BA4E6);
  static const Color petsAccent = Color(0xFFFFD166);
  static const Color travelAccent = Color(0xFF9B8BF4);
  static const Color podcastAccent = Color(0xFFE879F9);
  static const Color budgetAccent = Color(0xFF4ADE80);
  static const Color fitnessAccent = Color(0xFFF97316);
  static const Color cycleAccent = Color(0xFFEC4899);

  // ─────────────────────────────────────────────────────────────────
  // BACKGROUNDS & SURFACES
  // ─────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF4F6F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEDF6F9);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x0D000000);

  // ─────────────────────────────────────────────────────────────────
  // TEXT COLORS
  // ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────────────────────
  // STATUS COLORS
  // ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF74B9FF);

  // ─────────────────────────────────────────────────────────────────
  // NAVIGATION
  // ─────────────────────────────────────────────────────────────────
  static const Color navBackground = Color(0xFAFFFFFF);
  static const Color navSelected = primary;
  static const Color navUnselected = Color(0xFFB2BEC3);

  // ─────────────────────────────────────────────────────────────────
  // GRADIENTS
  // ─────────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF006D77), Color(0xFF83C5BE)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF006D77), Color(0xFF83C5BE), Color(0xFFF4F6F8)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF006D77), Color(0xFF83C5BE), Color(0xFFEDF6F9)],
  );
}
