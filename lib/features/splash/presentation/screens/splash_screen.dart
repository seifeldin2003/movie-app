import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

/// First screen the app shows. Figma node 29:431.
///
/// The credit line animates in, then holds for [_holdDuration] before the app
/// replaces this screen with Onboarding, so Back can never return here.
///
/// Stateful on purpose: the pending delay has to be cancellable. Navigating
/// from a callback that outlives the widget throws on a dead context.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _holdDuration = Duration(seconds: 2);

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleNextScreen() {
    _timer = Timer(_holdDuration, () {
      if (!mounted) return;

      // Firebase restores the session on cold start, so someone who is still
      // signed in should land in the app rather than be asked to sign in again.
      final isSignedIn = getIt<AuthRepository>().currentUser != null;

      Navigator.pushReplacementNamed(
        context,
        isSignedIn ? AppRouteNames.home : AppRouteNames.onboarding,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: ZoomIn(
                duration: const Duration(seconds: 1),
                child: Image.asset(AppAssets.logo, width: 121.w),
              ),
            ),
            const Spacer(),
            ZoomIn(child: Image.asset(AppAssets.routeGold, width: 180.w)),
            SizedBox(height: 8.h),
            FadeInUpBig(
              duration: const Duration(seconds: 2),
              // Runs once the animation completes, not on every rebuild.
              onFinish: (_) => _scheduleNextScreen(),
              child: Center(
                child: Text(
                  AppStrings.supervisedBy,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
