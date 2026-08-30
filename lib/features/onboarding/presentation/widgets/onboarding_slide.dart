import 'package:flutter/material.dart';

/// TASK: Onboarding — one page of the `PageView`.
///
/// Takes plain data (image path, title, body) and callbacks only — never a
/// Bloc and never a service. Keep it dumb so all six pages reuse it.
class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    super.key,
    required this.imagePath,
    required this.title,
    required this.body,
  });

  final String imagePath;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // TODO(onboarding): build the slide
  }
}
