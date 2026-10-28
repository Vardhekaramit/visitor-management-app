import 'package:flutter/material.dart';

/// Centralized application color palette.
/// All colors used throughout the app are defined here, avoiding hardcoded static colors.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Royal Blue & Indigo)
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFF4F46E5);

  // Status & Semantic Colors
  static const Color registered = Color(0xFF2563EB); // Royal Blue
  static const Color checkedIn = Color(0xFF10B981); // Emerald Green
  static const Color checkedOut = Color(0xFF64748B); // Slate Gray
  static const Color slate = Color(0xFF64748B);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);

  // Visitor Type Badge Colors
  static const Color customerBadge = Color(0xFF4F46E5);
  static const Color vendorBadge = Color(0xFFD97706);
  static const Color otherBadge = Color(0xFF0D9488);

  // Neutral Background & Surface Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF151C2C);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF151C2C);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  // Border & Divider Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF28344E);
  static const Color dividerLight = Color(0xFFF1F5F9);
  static const Color dividerDark = Color(0xFF1E293B);

  // Adaptive Helpers based on Brightness Context
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? backgroundDark
          : backgroundLight;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceDark
          : surfaceLight;

  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? cardDark
          : cardLight;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textPrimaryDark
          : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textSecondaryDark
          : textSecondaryLight;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? borderDark
          : borderLight;
}
