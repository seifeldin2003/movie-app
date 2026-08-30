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
  static const Color error = Color(0xFFE82C2C);
  static const Color success = Color(0xFF12CD8A);
}
