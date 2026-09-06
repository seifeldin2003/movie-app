import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Which half of Profile is on screen.
enum ProfileSection { watchList, history }

/// The Watch List / History switch, underlined in gold on the active side.
/// Figma nodes 52:596 / 52:599.
class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ProfileSection selected;
  final ValueChanged<ProfileSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfileTab(
            icon: Icons.format_list_bulleted,
            label: AppStrings.watchList,
            isSelected: selected == ProfileSection.watchList,
            onTap: () => onChanged(ProfileSection.watchList),
          ),
        ),
        Expanded(
          child: _ProfileTab(
            icon: Icons.folder,
            label: AppStrings.history,
            isSelected: selected == ProfileSection.history,
            onTap: () => onChanged(ProfileSection.history),
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Icon(icon, color: AppColors.primary, size: 24.sp),
          SizedBox(height: 6.h),
          Text(label, style: AppTextStyles.bodyMedium),
          SizedBox(height: 10.h),
          // The rule spans the full half-width, so the two tabs read as one
          // continuous bar rather than two buttons.
          Container(
            height: 2.h,
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}
