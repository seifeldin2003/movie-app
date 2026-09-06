import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';

/// Asks where the new picture should come from before showing anything heavy.
///
/// Splitting the choice out keeps the grid from being the first thing the user
/// meets — browsing the gallery has nothing to do with the nine characters, so
/// making it a footnote under a wall of them read as an afterthought.
class AvatarSourceSheet extends StatelessWidget {
  const AvatarSourceSheet({
    super.key,
    required this.hasUploadedPhoto,
    required this.onChooseAvatar,
    required this.onBrowseImage,
    required this.onRemovePhoto,
  });

  /// Removing is only offered when there is a photo to remove.
  final bool hasUploadedPhoto;

  final VoidCallback onChooseAvatar;
  final VoidCallback onBrowseImage;
  final VoidCallback onRemovePhoto;

  /// Closes itself before running the chosen action, so the caller never has
  /// to pop it and two sheets can never be open at once.
  static Future<void> show(
    BuildContext context, {
    required bool hasUploadedPhoto,
    required VoidCallback onChooseAvatar,
    required VoidCallback onBrowseImage,
    required VoidCallback onRemovePhoto,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) => AvatarSourceSheet(
        hasUploadedPhoto: hasUploadedPhoto,
        onChooseAvatar: () {
          Navigator.pop(sheetContext);
          onChooseAvatar();
        },
        onBrowseImage: () {
          Navigator.pop(sheetContext);
          onBrowseImage();
        },
        onRemovePhoto: () {
          Navigator.pop(sheetContext);
          onRemovePhoto();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SheetHandle(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              AppStrings.changePhoto,
              style: AppTextStyles.titleMedium,
            ),
          ),
          _SourceOption(
            icon: Icons.face_retouching_natural_outlined,
            title: AppStrings.chooseAvatar,
            subtitle: AppStrings.chooseAvatarSubtitle,
            onTap: onChooseAvatar,
          ),
          _SourceOption(
            icon: Icons.photo_library_outlined,
            title: AppStrings.browseImage,
            subtitle: AppStrings.browseImageSubtitle,
            onTap: onBrowseImage,
          ),
          if (hasUploadedPhoto)
            _SourceOption(
              icon: Icons.delete_outline,
              title: AppStrings.removePhoto,
              subtitle: AppStrings.removePhotoSubtitle,
              isDestructive: true,
              onTap: onRemovePhoto,
            ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

/// The grab bar every bottom sheet in the app shares.
class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 4.h,
      margin: EdgeInsets.only(top: 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteMuted,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final tint = isDestructive ? AppColors.error : AppColors.primary;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      leading: Container(
        width: 44.w,
        height: 44.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppTheme.radius.r),
        ),
        child: Icon(icon, color: tint, size: 22.sp),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDestructive ? AppColors.error : AppColors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.whiteMuted),
      ),
      trailing: isDestructive
          ? null
          : Icon(Icons.chevron_right, color: AppColors.whiteMuted, size: 20.sp),
    );
  }
}
