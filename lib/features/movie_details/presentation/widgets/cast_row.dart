import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../movies/domain/entities/cast_member.dart';

/// One actor. Figma node 55:91 — a surface card with a square portrait and
/// the name and character stacked beside it.
class CastRow extends StatelessWidget {
  const CastRow({super.key, required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      padding: EdgeInsets.all(11.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.surfaceCardRadius.r),
      ),
      child: Row(
        children: [
          _Portrait(imageUrl: member.imageUrl),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.castName(member.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge,
                ),
                // YTS frequently omits the character, so the row has to read
                // sensibly with just a name.
                if (member.characterName != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    AppStrings.characterName(member.characterName!),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Portrait extends StatelessWidget {
  const _Portrait({this.imageUrl});

  final String? imageUrl;

  static const double _size = 70;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10.r);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: _size.w,
        height: _size.w,
        child: ColoredBox(
          color: AppColors.background,
          child: imageUrl == null || imageUrl!.isEmpty
              // No portrait is the common case on YTS, so the fallback is the
              // normal path rather than an error state.
              ? Icon(
                  Icons.person,
                  color: AppColors.whiteMuted,
                  size: 32.sp,
                )
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.person,
                    color: AppColors.whiteMuted,
                    size: 32.sp,
                  ),
                ),
        ),
      ),
    );
  }
}
