import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The single source of truth for how the app looks.
///
/// The app ships dark-only — every Figma frame is drawn on
/// [AppColors.background]. Anything visual that repeats across screens belongs
/// here, not copy-pasted into each widget.
///
/// Sizing is handled by `flutter_screenutil` at the call site (`.w` `.h` `.r`
/// `.sp`) — the few numbers below are the *design system* values (they define
/// the look), not per-screen spacing.
class AppTheme {
  const AppTheme._();

  /// The Figma frames are drawn at 430 x 932 — `ScreenUtilInit` scales
  /// everything relative to this.
  static const Size designSize = Size(430, 932);

  /// Corner radius shared by buttons and text fields.
  static const double radius = 15;

  /// Height of a primary button and a text field. Figma 44:619 / 44:611.
  static const double controlHeight = 56;

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.surface,
      surface: AppColors.surface,
      onSurface: AppColors.white,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: _border(AppColors.surface),
      enabledBorder: _border(AppColors.surface),
      focusedBorder: _border(AppColors.primary),
      errorBorder: _border(AppColors.error),
      focusedErrorBorder: _border(AppColors.error),
    ),
  );

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(color: color),
  );
}
