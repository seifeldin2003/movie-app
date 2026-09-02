/// One onboarding page, as data.
///
/// The six Figma frames differ only in their artwork and copy, so they are
/// described here and rendered by a single widget instead of six near-
/// identical screens.
class OnboardingSlideData {
  const OnboardingSlideData({
    required this.image,
    required this.title,
    required this.actionLabel,
    this.body,
    this.showBack = true,
  });

  /// Poster artwork behind the copy.
  final String image;

  final String title;

  /// The last slide is title-only. Figma node 39:294.
  final String? body;

  /// Label on the primary button — "Next" on most slides, "Finish" on the
  /// last one, "Explore Now" on the intro.
  final String actionLabel;

  /// The intro slide has no Back button; every later slide does.
  final bool showBack;
}
