import 'package:flutter/material.dart';

/// Palette pulled from the Figma file (`yIeirbhqtxNGkAgThx8HnX`).
/// The file defines no Figma variables, so the values are hardcoded here —
/// this class is the ONLY place a raw colour literal may appear.
class AppColors {
  const AppColors._();

  /// Scaffold background on every screen. Figma node 29:431.
  static const Color background = Color(0xFF121312);

  /// Cards, text fields, and the text drawn on top of [primary].
  static const Color surface = Color(0xFF282A28);

  /// Brand gold — primary buttons, selected states, the Route logo.
  static const Color primary = Color(0xFFF6BD00);

  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF707070);

  /// Destructive actions — "Delete Account". Figma node 55:887.
  static const Color error = Color(0xFFE82626);
  static const Color success = Color(0xFF12CD8A);

  /// Onboarding body copy sits at 60% white over the poster artwork.
  static const Color whiteMuted = Color(0x99FFFFFF);

  /// Scrim laid over the onboarding poster art so the copy stays readable.
  /// Figma node 34:66.
  static const List<Color> posterScrim = [
    Color(0x001E1E1E),
    Color(0x80121312),
    Color(0xE8121312),
    Color(0xFF121312),
  ];

  static const List<double> posterScrimStops = [0.0, 0.39, 0.675, 1.0];
}
