import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// TASK: Splash — Figma node `29:431`. UI only, no Bloc.
///
/// Steps:
///  1. Background is [AppColors.background] (already the scaffold default).
///  2. Centre the app logo — export it from Figma into `assets/images/`,
///     register the folder in `pubspec.yaml`, reference via `AppAssets.logo`.
///  3. Bottom: the gold "routegold" lockup + `AppStrings.supervisedBy`.
///  4. After ~3 seconds, `Navigator.pushReplacementNamed` to
///     `AppRouteNames.onboarding`. Start the timer in `initState`, and cancel
///     it in `dispose` or a fast back-press throws after unmount.
///  5. Size everything with `.w` / `.h` / `.sp` — no raw pixel numbers.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Splash — TODO')),
    );
  }
}
