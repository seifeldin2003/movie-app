import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Text styles used across the app. Screens read these instead of building
/// their own `TextStyle`, so the type scale stays consistent.
///
/// The Figma file uses Poppins for display copy. The font file is not bundled
/// yet — once `assets/fonts/` exists and is registered in `pubspec.yaml`,
/// set `fontFamily: 'Poppins'` in [AppTheme] and every style below inherits it.
class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get titleLarge => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static TextStyle get titleMedium => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle get bodyMedium =>
      TextStyle(fontSize: 16.sp, color: AppColors.white);

  static TextStyle get bodySmall =>
      TextStyle(fontSize: 14.sp, color: AppColors.white);

  /// Label drawn on top of a gold [AppColors.primary] button.
  static TextStyle get buttonLabel => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.surface,
  );

  /// Tappable inline text, e.g. "Forget Password ?".
  static TextStyle get link => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );
}
