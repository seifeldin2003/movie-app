import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';

/// The avatar strip at the top of Register — a large centre avatar flanked by
/// two smaller ones. Figma node 285:100.
///
/// Decorative on sign-up: the design shows the avatars but offers no way to
/// choose one here, and picking happens on Update Profile. It draws three of
/// the real illustrations rather than the same one three times.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({super.key});

  static const double _centreSize = 158;
  static const double _sideSize = 94;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.avatarPath(AppAssets.avatarIds[3]),
              width: _sideSize.w,
            ),
            Image.asset(
              AppAssets.avatarPath(AppAssets.defaultAvatarId),
              width: _centreSize.w,
            ),
            Image.asset(
              AppAssets.avatarPath(AppAssets.avatarIds[6]),
              width: _sideSize.w,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(AppStrings.avatar, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}
