import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';

/// Avatar, counts and the two account actions at the top of Profile.
/// Figma node 51:511.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.wishListCount,
    required this.historyCount,
    required this.onEditProfile,
    required this.onExit,
  });

  final String name;
  final int wishListCount;
  final int historyCount;
  final VoidCallback onEditProfile;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  AppAssets.avatar,
                  width: 118.w,
                  height: 118.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ProfileStat(
                      value: wishListCount,
                      label: AppStrings.wishList,
                    ),
                    _ProfileStat(
                      value: historyCount,
                      label: AppStrings.history,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(name, style: AppTextStyles.titleMedium),
          SizedBox(height: 16.h),
          Row(
            children: [
              // Edit takes the room; Exit stays a compact escape hatch, as in
              // the design.
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  text: AppStrings.editProfile,
                  onPressed: onEditProfile,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(child: _ExitButton(onPressed: onExit)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value', style: AppTextStyles.statValue),
        SizedBox(height: 4.h),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

/// Sign-out. Red rather than gold because it leaves the session, and it is
/// sitting next to the primary action. Figma node 51:580.
class _ExitButton extends StatelessWidget {
  const _ExitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.controlHeight.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                AppStrings.exit,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.buttonLabelDestructive,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.logout, color: AppColors.white, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
