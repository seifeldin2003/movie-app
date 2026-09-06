import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

/// The nine characters. Figma node 55:889.
///
/// Reached from `AvatarSourceSheet`, so this sheet does one thing — browsing
/// the gallery and removing a photo live a step above it.
///
/// Height is the fiddly part. A modal sheet is capped at 9/16 of the screen
/// unless `isScrollControlled` is set, and three rows of tiles plus a heading
/// is taller than that — which is what overflowed. So this opts out of the
/// cap, takes a fixed share of the screen, and lets the grid do the scrolling.
/// Sizing off the screen rather than off the content means it cannot overflow
/// on a small phone either.
class AvatarPickerSheet extends StatelessWidget {
  const AvatarPickerSheet({
    super.key,
    required this.selectedAvatarId,
    required this.onAvatarSelected,
  });

  final String? selectedAvatarId;
  final ValueChanged<String> onAvatarSelected;

  /// Tall enough for all three rows on a normal phone, short enough that the
  /// screen behind stays visible.
  static const double _heightFraction = 0.62;

  static Future<void> show(
    BuildContext context, {
    required String? selectedAvatarId,
    required ValueChanged<String> onAvatarSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      // Without this the sheet is capped and the grid overflows.
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) => AvatarPickerSheet(
        selectedAvatarId: selectedAvatarId,
        onAvatarSelected: (id) {
          Navigator.pop(sheetContext);
          onAvatarSelected(id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * _heightFraction,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                color: AppColors.whiteMuted,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                AppStrings.chooseAvatar,
                style: AppTextStyles.titleMedium,
              ),
            ),
            // Takes whatever is left and scrolls inside it, so the number of
            // rows never decides the sheet's height.
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: AppAssets.avatarIds.length,
                itemBuilder: (context, index) {
                  final id = AppAssets.avatarIds[index];
                  return _AvatarTile(
                    avatarId: id,
                    isSelected: id == selectedAvatarId,
                    onTap: () => onAvatarSelected(id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One character. Figma node 55:913 — gold outline and fill when chosen, a
/// muted outline otherwise so the chosen one actually stands out.
class _AvatarTile extends StatelessWidget {
  const _AvatarTile({
    required this.avatarId,
    required this.isSelected,
    required this.onTap,
  });

  final String avatarId;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.avatarTileRadius.r);

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: AnimatedContainer(
        // Enough to register as a response to the tap without feeling laggy.
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.avatarSelected : Colors.transparent,
          borderRadius: radius,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.whiteMuted,
            width: isSelected ? 2.w : 1.w,
          ),
        ),
        child: Image.asset(AppAssets.avatarPath(avatarId), fit: BoxFit.contain),
      ),
    );
  }
}
