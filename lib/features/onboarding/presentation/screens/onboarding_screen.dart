import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// TASK: Onboarding — Figma nodes `30:447`, `38:75`, `38:149`, `38:172`,
/// `38:188`, `39:294`. UI only, no Bloc.
///
/// Steps:
///  1. Drive the six frames with a `PageView` — one `OnboardingSlide` per page,
///     fed by a `List` of plain data objects (image + title + body). Do NOT
///     write six near-identical widgets.
///  2. `OnboardingPageIndicator` shows which page is active.
///  3. Next / Back controls; the last page's CTA goes to
///     `AppRouteNames.login` via `pushReplacementNamed`.
///  4. Dispose the `PageController`.
///  5. All copy through `AppStrings`, all sizes through `.w` / `.h` / `.sp`.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Onboarding — TODO')),
    );
  }
}
