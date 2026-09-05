/// Values that come from external consoles rather than the design.
class AppConfig {
  const AppConfig._();

  /// The **Web** OAuth client ID from Firebase — `client_type: 3` in
  /// `android/app/google-services.json`. Android needs it to mint the ID token
  /// that Firebase exchanges for a session; the Android client (`client_type: 1`)
  /// is the wrong one and silently fails.
  ///
  /// Taken from the `client_type: 3` entry in
  /// `android/app/google-services.json`.
  ///
  /// ⚠️ ONE STEP STILL MISSING ON ANDROID. `google-services.json` has the Web
  /// client but **no `client_type: 1`** entry — that one only appears once a
  /// signing fingerprint is registered. Until then Android sign-in fails with
  /// `ApiException: 10` (DEVELOPER_ERROR), which reads like a code bug but is
  /// purely config.
  ///
  /// To finish it: Firebase Console → Project settings → Your apps → Android →
  /// add the **SHA-1 and SHA-256** from `cd android && ./gradlew signingReport`,
  /// then re-download `google-services.json`. Every teammate's debug keystore
  /// is different, so each person's fingerprint has to be added or Google
  /// sign-in works only on the machine that registered it.
  ///
  /// iOS is already complete — `GoogleService-Info.plist` carries
  /// `CLIENT_ID` / `REVERSED_CLIENT_ID` and the callback scheme is in
  /// `ios/Runner/Info.plist`.
  static const String googleServerClientId =
      '1084601339826-d4v7mlquni3p9hb6psm497eu0aoe67a3.apps.googleusercontent.com';

  static bool get isGoogleSignInConfigured => googleServerClientId.isNotEmpty;
}
