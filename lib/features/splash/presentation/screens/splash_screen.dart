import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/theme/app_text_styles.dart';

/// First screen the app shows. Figma node 29:431.
///
/// Holds for [_splashDuration], then replaces itself with Onboarding so Back
/// can never return here.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _splashDuration = Duration(seconds: 3);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_splashDuration, _goToOnboarding);
  }

  @override
  void dispose() {
    // Without this a fast back-press leaves the timer running and it fires
    // against a dead context.
    _timer?.cancel();
    super.dispose();
  }

  void _goToOnboarding() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouteNames.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Image.asset(AppAssets.logo, width: 121.w),
            const Spacer(),
            Image.asset(AppAssets.routeGold, width: 180.w),
            SizedBox(height: 8.h),
            Text(AppStrings.supervisedBy, style: AppTextStyles.bodyMedium),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
