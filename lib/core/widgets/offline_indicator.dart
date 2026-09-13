import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A quiet badge that appears while the app cannot reach the API.
///
/// Watches [NetworkStatus], which is set by `ApiClient` from the outcome of
/// real requests — so this shows up exactly when something has actually failed,
/// and clears itself the moment anything succeeds.
///
/// Deliberately small and deliberately not a banner: the screen underneath is
/// still showing real (cached) content, and shoving it down to announce a
/// degraded state would be a bigger interruption than the state deserves.
class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key, required this.status});

  /// Passed in rather than resolved from the service locator: a shared widget
  /// takes data, never a service. It also means this can be driven from a test
  /// with a plain `ValueNotifier(true)`.
  final ValueListenable<bool> status;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: status,
      builder: (context, isOffline, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          // Fades rather than slides. The badge sits over artwork, and
          // something sliding in from the edge reads as a notification the
          // user is meant to act on.
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: isOffline ? child : const SizedBox.shrink(),
        );
      },
      // Built once and reused across both states: nothing inside it depends on
      // `isOffline`, only whether it is shown at all.
      child: Semantics(
        label: AppStrings.offline,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            // The same translucent dark pill the rating badge uses, so this
            // reads as part of the design rather than an error state bolted on.
            color: AppColors.ratingBadge,
            borderRadius: BorderRadius.circular(AppTheme.badgeRadius.r),
          ),
          child: Icon(
            Icons.cloud_off_rounded,
            size: 18.r,
            color: AppColors.whiteMuted,
          ),
        ),
      ),
    );
  }
}
