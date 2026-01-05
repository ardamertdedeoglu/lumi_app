import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (same for both themes)
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color primaryPurple = Color(0xFFA855F7);
  static const Color primaryBlue = Color(0xFF0EA5E9);

  // Accent Colors (same for both themes)
  static const Color red = Color(0xFFF43F5E);
  static const Color green = Color(0xFF22C55E);

  // Gradient (same for both themes)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPink, primaryPurple],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, Color(0xFF0284C7)],
  );

  // ============ LIGHT THEME COLORS ============
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightCardWhite = Colors.white;
  static const Color lightSurfaceLight = Color(0xFFF0F2F5);

  // Light Text Colors
  static const Color lightTextDark = Color(0xFF1E293B);
  static const Color lightTextMedium = Color(0xFF334155);
  static const Color lightTextLight = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Light Border Colors
  static const Color lightBorder = Color(0xFFF1F5F9);
  static const Color lightBorderMedium = Color(0xFFCBD5E1);
  static const Color lightBorderLight = Color(0xFFE2E8F0);

  // Light Card Icon Backgrounds
  static const Color lightPinkLight = Color(0xFFFDF2F8);
  static const Color lightPurpleLight = Color(0xFFF3E8FF);
  static const Color lightBlueLight = Color(0xFFE0F2FE);
  static const Color lightRedLight = Color(0xFFFFE4E6);
  static const Color lightGreenLight = Color(0xFFDCFCE7);

  // Light FAB Color
  static const Color lightDarkNavy = Color(0xFF0F172A);

  // ============ DARK THEME COLORS ============
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCardWhite = Color(0xFF1E293B);
  static const Color darkSurfaceLight = Color(0xFF334155);

  // Dark Text Colors
  static const Color darkTextDark = Color(0xFFF1F5F9);
  static const Color darkTextMedium = Color(0xFFE2E8F0);
  static const Color darkTextLight = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Dark Border Colors
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkBorderMedium = Color(0xFF475569);
  static const Color darkBorderLight = Color(0xFF334155);

  // Dark Card Icon Backgrounds (darker versions)
  static const Color darkPinkLight = Color(0xFF4C1D3D);
  static const Color darkPurpleLight = Color(0xFF3B1D5C);
  static const Color darkBlueLight = Color(0xFF0C3D5C);
  static const Color darkRedLight = Color(0xFF4C1D24);
  static const Color darkGreenLight = Color(0xFF1D4C2D);

  // Dark FAB Color
  static const Color darkDarkNavy = Color(0xFFF8FAFC);
}

/// Extension to get theme-aware colors
class LumiColors {
  final BuildContext context;
  
  LumiColors(this.context);
  
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  // Background Colors
  Color get background => isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get card => isDark ? AppColors.darkCardWhite : AppColors.lightCardWhite;
  Color get surface => isDark ? AppColors.darkSurfaceLight : AppColors.lightSurfaceLight;

  // Text Colors
  Color get textPrimary => isDark ? AppColors.darkTextDark : AppColors.lightTextDark;
  Color get textSecondary => isDark ? AppColors.darkTextMedium : AppColors.lightTextMedium;
  Color get textTertiary => isDark ? AppColors.darkTextLight : AppColors.lightTextLight;
  Color get textMuted => isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

  // Border Colors
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get borderMedium => isDark ? AppColors.darkBorderMedium : AppColors.lightBorderMedium;
  Color get borderLight => isDark ? AppColors.darkBorderLight : AppColors.lightBorderLight;

  // Card Icon Backgrounds
  Color get pinkLight => isDark ? AppColors.darkPinkLight : AppColors.lightPinkLight;
  Color get purpleLight => isDark ? AppColors.darkPurpleLight : AppColors.lightPurpleLight;
  Color get blueLight => isDark ? AppColors.darkBlueLight : AppColors.lightBlueLight;
  Color get redLight => isDark ? AppColors.darkRedLight : AppColors.lightRedLight;
  Color get greenLight => isDark ? AppColors.darkGreenLight : AppColors.lightGreenLight;

  // FAB Color
  Color get fabBackground => isDark ? AppColors.darkDarkNavy : AppColors.lightDarkNavy;
  Color get fabForeground => isDark ? AppColors.darkBackground : Colors.white;
}

/// Helper extension on BuildContext
extension LumiColorsExtension on BuildContext {
  LumiColors get colors => LumiColors(this);
}
