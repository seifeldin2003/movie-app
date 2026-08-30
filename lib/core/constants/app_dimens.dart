/// Spacing, sizing and radius values taken from the Figma frames.
///
/// Every value is a *design* number — always apply `.w` / `.h` / `.r` / `.sp`
/// from `flutter_screenutil` at the call site so it scales across devices.
class AppDimens {
  const AppDimens._();

  /// Figma frames are drawn at 430 x 932.
  static const double designWidth = 430;
  static const double designHeight = 932;

  /// Horizontal page padding used by the auth screens.
  static const double screenPadding = 16;

  /// Height of a primary button and a text field. Figma node 44:619 / 44:611.
  static const double controlHeight = 56;

  /// Corner radius shared by buttons and text fields.
  static const double radius = 15;

  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 16;
  static const double spaceL = 24;
  static const double spaceXL = 32;
}
