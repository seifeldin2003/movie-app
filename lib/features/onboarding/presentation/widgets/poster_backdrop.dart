import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Poster artwork with the dark scrim that every onboarding slide sits on.
/// Figma node 34:66.
///
/// The artwork is top-aligned because each Figma frame crops the poster from
/// the top and lets the scrim fade into the background colour further down.
class PosterBackdrop extends StatelessWidget {
  const PosterBackdrop({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover, alignment: Alignment.topCenter),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.posterScrim,
              stops: AppColors.posterScrimStops,
            ),
          ),
        ),
      ],
    );
  }
}
