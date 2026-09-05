import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// One entry point for every toast in the app, so success and failure always
/// look the same wherever they are raised.
///
/// Call it from a Bloc `listener`, never from a `builder` — a builder can run
/// many times for one state and would stack duplicate snack bars.
class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      // Drop whatever is on screen so a fast second tap doesn't queue two.
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isError ? AppColors.white : AppColors.background,
            ),
          ),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius.r),
          ),
        ),
      );
  }
}
