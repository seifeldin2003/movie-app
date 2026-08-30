import 'package:flutter/material.dart';

/// TASK: Onboarding — the dots showing progress through the six pages.
///
/// The active dot uses `AppColors.primary`; the rest use a muted colour.
class OnboardingPageIndicator extends StatelessWidget {
  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // TODO(onboarding): build the indicator
  }
}
