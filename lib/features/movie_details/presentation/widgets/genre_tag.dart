import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

/// A read-only genre label on Movie Details. Figma node 55:69.
///
/// Deliberately not `GenreChip` from `core/widgets`: that one is a tappable
/// filter on Browse, gold and 48 high. This is a flat surface tag that does
/// nothing when touched, and giving them the same look would suggest it
/// filters something.
class GenreTag extends StatelessWidget {
  const GenreTag(this.label, {super.key});

  final String label;

  /// Fixed rather than sized to its text, so the tags line up in even columns
  /// instead of every row being a different rhythm. Three of these plus the
  /// gaps fit one row at the design width.
  static const double width = 120;
  static const double height = 35;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.tagRadius.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall,
      ),
    );
  }
}
