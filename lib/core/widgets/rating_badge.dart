import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// The score pill that sits on the top-left of every poster.
/// Figma node 47:1542.
///
/// The Figma star exports at 15x15, too small to scale cleanly, so a Material
/// icon tinted gold stands in for it.
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});

  /// Out of 10. Hidden entirely when null — a blank pill reads as a bug.
  final double? rating;

  @override
  Widget build(BuildContext context) {
    if (rating == null) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.ratingBadge,
        borderRadius: BorderRadius.circular(AppTheme.badgeRadius.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rating!.toStringAsFixed(1),
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(width: 4.w),
            Icon(Icons.star, color: AppColors.primary, size: 15.sp),
          ],
        ),
      ),
    );
  }
}
