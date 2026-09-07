import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

/// Text styles used across the app. Screens read these instead of building
/// their own `TextStyle`, so the type scale stays consistent.
///
/// The Figma file uses **Inter**. The font is not bundled yet — set
/// `fontFamily` once in [AppTheme] when it is, and every style here inherits
/// it. Sizes use `.sp` so they scale with the device.
class AppTextStyles {
  const AppTextStyles._();

  /// Onboarding intro headline. Figma node 35:68.
  static TextStyle get displayLarge => TextStyle(
    fontSize: 36.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  /// Onboarding slide headline. Figma node 38:117.
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

  /// Onboarding body copy. Figma node 38:124.
  static TextStyle get bodyLarge =>
      TextStyle(fontSize: 20.sp, color: AppColors.white);

  /// Intro body copy — dimmed against the poster art. Figma node 35:70.
  static TextStyle get bodyLargeMuted => TextStyle(
    fontSize: 20.sp,
    height: 32 / 20,
    color: AppColors.whiteMuted,
  );

  static TextStyle get bodyMedium =>
      TextStyle(fontSize: 16.sp, color: AppColors.white);

  static TextStyle get bodySmall =>
      TextStyle(fontSize: 14.sp, color: AppColors.white);

  /// Label on a gold [AppColors.primary] button. Figma node 35:74.
  static TextStyle get buttonLabel => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.background,
  );

  /// Smaller label on a gold button — the Google row. Figma node 44:630.
  static TextStyle get buttonLabelSmall => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.surface,
  );

  /// Label on an outlined button. Figma node 38:182.
  static TextStyle get buttonLabelOutlined => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  /// Label on a destructive button. Figma node 55:888.
  static TextStyle get buttonLabelDestructive =>
      TextStyle(fontSize: 20.sp, color: AppColors.white);

  /// Section heading on Movie Details — "Summary", "Cast", "Genres".
  /// Also the movie title over the hero. Figma nodes 55:107 / 53:120.
  static TextStyle get sectionHeading => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    height: 1.39,
    color: AppColors.white,
  );

  /// Long-form copy — the summary paragraph. Figma node 55:108.
  static TextStyle get bodyReadable =>
      TextStyle(fontSize: 16.sp, height: 1.39, color: AppColors.white);

  /// The number inside a Movie Details badge pill. Figma node 53:76.
  static TextStyle get badgeValue => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  /// Genre chip label. Figma node 51:399.
  static TextStyle get chipLabelSelected => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.background,
  );

  static TextStyle get chipLabel => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  /// The big count above "Wish List" / "History" on Profile.
  static TextStyle get statValue => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  /// Tappable inline text, e.g. "Forget Password ?".
  static TextStyle get link => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primary,
  );
}
