import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// A rule either side of the word "OR", between the login form and the
/// Google button. Figma node 44:631.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.primary)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(AppStrings.or, style: AppTextStyles.bodyMedium),
        ),
        const Expanded(child: Divider(color: AppColors.primary)),
      ],
    );
  }
}
