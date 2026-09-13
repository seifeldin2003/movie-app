import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import 'download_quality.dart';

/// The quality picker behind the Download button.
///
/// ⚠️ UI ONLY — the options are passed in as static text and choosing one does
/// not download anything. It is the shell for a real source, kept so the
/// screen is complete to look at.
///
/// `isScrollControlled` on purpose: an unbounded sheet is capped at 9/16 of
/// the screen, which is what clipped the avatar grid before.
class DownloadOptionsSheet extends StatelessWidget {
  const DownloadOptionsSheet({
    super.key,
    required this.qualities,
    required this.onSelected,
  });

  final List<DownloadQuality> qualities;
  final ValueChanged<DownloadQuality> onSelected;

  /// Closes itself before running the callback, so the caller never has to pop
  /// it and two sheets can never be open at once.
  static Future<void> show(
    BuildContext context, {
    required List<DownloadQuality> qualities,
    required ValueChanged<DownloadQuality> onSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) => DownloadOptionsSheet(
        qualities: qualities,
        onSelected: (quality) {
          Navigator.pop(sheetContext);
          onSelected(quality);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  AppStrings.downloadOptions,
                  style: AppTextStyles.titleMedium,
                ),
                SizedBox(width: 8.w),
                // Said here rather than only on tap: the user should know
                // before they pick, not after.
                Text(
                  AppStrings.downloadComingSoon,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            for (final quality in qualities)
              _OptionRow(quality: quality, onTap: () => onSelected(quality)),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.quality, required this.onTap});

  final DownloadQuality quality;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radius.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        child: Row(
          children: [
            Icon(Icons.download_rounded, color: AppColors.primary, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(quality.label, style: AppTextStyles.bodyMedium),
            ),
            // The size is the choice being made, so it carries the emphasis.
            Text(quality.size, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
