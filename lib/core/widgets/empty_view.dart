import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';

/// The `empty` branch of every Bloc-driven screen — a successful load that
/// returned nothing. Handle it separately from `error`; they read differently
/// to the user.
///
/// Pass [imagePath] to show the popcorn illustration the design uses on an
/// empty Watch List or search. Figma node 52:601.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message, this.imagePath});

  final String message;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null) ...[
              Image.asset(imagePath!, width: 124.w),
              SizedBox(height: 16.h),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
