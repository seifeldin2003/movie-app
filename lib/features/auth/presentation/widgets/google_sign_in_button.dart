import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

/// "Login With Google" — the same gold button as [PrimaryButton], with the
/// Google mark beside a smaller label. Figma node 44:622.
///
/// The mark is the design's monochrome glyph, which is dark on purpose: it
/// reads against the gold, not against the page background.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.controlHeight.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.googleIcon, width: 27.w, height: 27.w),
            SizedBox(width: 12.w),
            Text(
              AppStrings.loginWithGoogle,
              style: AppTextStyles.buttonLabelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
