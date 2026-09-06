/// Values that come from external consoles rather than the design.
class AppConfig {
  const AppConfig._();

  /// The **Web** OAuth client ID from Firebase — the `client_type: 3` entry in
  /// `android/app/google-services.json`. Android needs it to mint the ID token
  /// that Firebase exchanges for a session; `client_type: 1` is the Android
  /// client and using it here fails silently.
  ///
  /// Both platforms are configured. iOS reads its own client id from
  /// `GoogleService-Info.plist`, with the callback scheme in `Info.plist`.
  /// Android has an `oauth_client` entry tied to a registered signing
  /// fingerprint.
  ///
  /// ⚠️ Fingerprints are per keystore, not per project. The committed config
  /// carries only the fingerprint of the machine that registered it, so
  /// **every teammate has to add their own debug SHA-1** in Firebase Console
  /// and re-download this file — otherwise Google sign-in fails for them with
  /// `ApiException: 10` (DEVELOPER_ERROR) while working fine here, which reads
  /// like a code bug but is purely config. Get it with:
  ///
  ///     keytool -list -v -keystore ~/.android/debug.keystore \
  ///       -alias androiddebugkey -storepass android
  ///
  /// A release build is signed with a different key again and needs its own
  /// fingerprint before Google sign-in works in the APK.
  static const String googleServerClientId =
      '1084601339826-d4v7mlquni3p9hb6psm497eu0aoe67a3.apps.googleusercontent.com';

  static bool get isGoogleSignInConfigured => googleServerClientId.isNotEmpty;
}
