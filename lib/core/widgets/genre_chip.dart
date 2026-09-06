import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// A genre filter on Browse. Figma node 51:402.
///
/// Selected fills gold with dark text; unselected is an outline in the same
/// gold, so the row reads as one control rather than two styles.
class GenreChip extends StatelessWidget {
  const GenreChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.chipRadius.r);

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Container(
        height: AppTheme.chipHeight.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: radius,
          border: Border.all(color: AppColors.primary, width: 2.w),
        ),
        child: Text(
          label,
          style: isSelected
              ? AppTextStyles.chipLabelSelected
              : AppTextStyles.chipLabel,
        ),
      ),
    );
  }
}
