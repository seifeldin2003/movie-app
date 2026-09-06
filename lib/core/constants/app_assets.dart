/// Asset paths. Never type an asset string inline.
///
/// The images were exported from the Figma file with the Dev Mode MCP server
/// and live in `assets/images` / `assets/icons`, registered in `pubspec.yaml`.
class AppAssets {
  const AppAssets._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  // Splash — Figma node 29:431
  static const String logo = '$_images/logo.png';
  static const String routeGold = '$_images/route_gold.png';

  // Onboarding backgrounds, in slide order.
  // Figma nodes 34:65, 38:114, 38:186, 38:159, 38:202, 39:264.
  static const String onboardingIntro = '$_images/onboarding_1.png';
  static const String onboardingDiscover = '$_images/onboarding_2.png';
  static const String onboardingGenres = '$_images/onboarding_3.png';
  static const String onboardingWatchlist = '$_images/onboarding_4.png';
  static const String onboardingReview = '$_images/onboarding_5.png';
  static const String onboardingStart = '$_images/onboarding_6.png';

  // Auth — Figma nodes 44:625, 47:973
  static const String googleIcon = '$_icons/google.png';
  static const String forgotPasswordArt = '$_images/forgot_password.png';

  // Profile — Figma node 55:865
  static const String avatar = '$_images/avatar.png';

  /// The nine avatars from the Pick Avatar grid. Figma node 55:889.
  ///
  /// [avatarIds] are what gets stored against the user, so they are a stable
  /// contract — renaming one orphans every profile already saved with it.
  /// Resolve an id to its artwork with [avatarPath].
  static const List<String> avatarIds = [
    'avatar_1',
    'avatar_2',
    'avatar_3',
    'avatar_4',
    'avatar_5',
    'avatar_6',
    'avatar_7',
    'avatar_8',
    'avatar_9',
  ];

  static const String defaultAvatarId = 'avatar_1';

  /// Falls back to [defaultAvatarId] for an unknown id, so a profile written
  /// by a newer build cannot render a broken tile on an older one.
  static String avatarPath(String? id) {
    final safeId = avatarIds.contains(id) ? id! : defaultAvatarId;
    return '$_images/avatars/$safeId.png';
  }

  /// Script lettering drawn by the designer — no font ships with it, so these
  /// are artwork rather than text. Figma nodes 47:1535 and 47:1533.
  static const String availableNow = '$_images/available_now.png';
  static const String watchNow = '$_images/watch_now.png';

  /// Popcorn illustration for an empty Watch List / search. Figma 52:601.
  static const String emptyState = '$_images/empty_state.png';
}
