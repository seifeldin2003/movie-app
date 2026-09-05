/// Values that come from external consoles rather than the design.
class AppConfig {
  const AppConfig._();

  /// The **Web** OAuth client ID from Firebase — `client_type: 3` in
  /// `android/app/google-services.json`. Android needs it to mint the ID token
  /// that Firebase exchanges for a session; the Android client (`client_type: 1`)
  /// is the wrong one and silently fails.
  ///
  /// ⚠️ STILL EMPTY — Google sign-in works on **iOS only** right now.
  ///
  /// iOS is done: the provider is enabled, `GoogleService-Info.plist` carries
  /// `CLIENT_ID` / `REVERSED_CLIENT_ID`, and the callback URL scheme is in
  /// `ios/Runner/Info.plist`.
  ///
  /// Android still needs:
  ///  1. Project settings → Your apps → Android → add the **SHA-1 and SHA-256**
  ///     fingerprints (`cd android && ./gradlew signingReport`). Every
  ///     teammate's debug keystore differs, so each one has to be added or
  ///     Google sign-in works only on the machine that registered it.
  ///  2. Re-download `android/app/google-services.json` — adding the
  ///     fingerprints rewrites it with an `oauth_client` array. The copy
  ///     currently committed has none.
  ///  3. Paste the `client_type: 3` (Web) id below — NOT `client_type: 1`,
  ///     which is the Android client and fails silently.
  static const String googleServerClientId = '';

  static bool get isGoogleSignInConfigured => googleServerClientId.isNotEmpty;
}
