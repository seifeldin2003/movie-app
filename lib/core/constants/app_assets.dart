/// Asset paths. Never type an asset string inline.
///
/// Export the images from Figma into `assets/images/` (and icons into
/// `assets/icons/`), then register the folders in `pubspec.yaml` under
/// `flutter: assets:` before referencing them here.
class AppAssets {
  const AppAssets._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  // Splash — Figma node 29:431
  static const String logo = '$_images/logo.png';
  static const String routeGold = '$_images/route_gold.png';

  // Onboarding — Figma nodes 30:447, 38:75, 38:149, 38:172, 38:188, 39:294
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.png';
  static const String onboarding4 = '$_images/onboarding_4.png';
  static const String onboarding5 = '$_images/onboarding_5.png';
  static const String onboarding6 = '$_images/onboarding_6.png';

  // Auth — Figma nodes 44:444, 44:670, 47:936
  static const String googleIcon = '$_icons/google.png';
  static const String forgotPasswordArt = '$_images/forgot_password.png';
}
