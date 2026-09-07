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

  /// The rating pill on a poster — [background] at 71%. Figma node 47:1537.
  static const Color ratingBadge = Color(0xB5121312);

  /// Fill behind the chosen avatar tile — [primary] at 56%.
  /// Figma node 55:919.
  static const Color avatarSelected = Color(0x8FF6BD00);

  // ===========================================================================
  //  THE TWO SCRIM DIALS — tune these, hot reload, look, repeat.
  //
  //  Each colour is 0xAARRGGBB. Only the FIRST TWO HEX DIGITS matter here:
  //  that is the alpha (how dark), and RRGGBB is always the page background.
  //
  //      0x00 =   0%  (fully transparent — artwork untouched)
  //      0x1A =  10%       0x33 =  20%       0x4D =  30%
  //      0x66 =  40%       0x80 =  50%       0x99 =  60%
  //      0xB3 =  70%       0xCC =  80%       0xE6 =  90%
  //      0xFF = 100%  (solid — artwork completely hidden)
  //
  //  The `Stops` list says WHERE each of those lands, top (0.0) to bottom
  //  (1.0). Both lists must stay the same length.
  //
  //  Lower alpha  = more artwork.
  //  Later stop   = the darkening starts further down.
  // ===========================================================================

  /// Behind the Home carousel.
  ///
  /// Transparent at the top and only 10% through the middle, so the poster
  /// actually reads. The bottom still goes to 90%, and that is deliberate:
  /// the "Watch Now" wordmark and the genre-row titles are white text sitting
  /// on whatever artwork is centred, and they vanish on a bright poster
  /// without it.
  static const List<Color> backdropScrim = [
    Color(0x73121312), //   0%  top
    Color(0x73121312), //  10%  through the middle
    Color(0xFF121312), //  90%  bottom, where the white wordmark sits
  ];

  static const List<double> backdropScrimStops = [0.0, 0.62, 1.0];

  /// Scrim over the Movie Details hero. Measured off Figma node 55:208.
  ///
  /// The poster is the reason anyone is on this screen, so the top of it is
  /// left completely alone — the ramp only starts around 45% and does not go
  /// dark until 78%, which is where the title sits.
  ///
  /// An earlier version opened at 25% black and hit 80% by mid-image, which
  /// washed the artwork out badly enough to read as a blur. The design
  /// tolerates a faint ghost of the poster's own lettering behind the title —
  /// it is visible in the Figma frame too — and that is the right trade:
  /// hiding the artwork to protect the title loses the more important thing.
  static const List<Color> heroScrim = [
    Color(0x1A121312), //   0%  top
    Color(0x1A121312), //   8%  most of the poster, essentially untouched
    Color(0x73121312), //  45%  starting to darken
    Color(0xFF121312), // 100%  behind the title and year
  ];

  static const List<double> heroScrimStops = [0.0, 0.55, 0.85, 0.98];

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
