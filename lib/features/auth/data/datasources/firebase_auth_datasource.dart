import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/app_user.dart';

/// The only file in the app that talks to `firebase_auth` directly.
///
/// ⚠️ SHARED FILE — Login / Register / Reset Password each fill in their own
/// method below. Add your method body, leave the others alone.
///
/// House rule: translate `FirebaseAuthException.code` into a sentence the user
/// can read, and `throw` that String. Never let a raw error code escape this
/// class.
class FirebaseAuthDataSource {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Maps a Firebase [User] onto the app's own entity.
  AppUser mapUser(User user) => AppUser(
    uid: user.uid,
    name: user.displayName,
    email: user.email,
    photoUrl: user.photoURL,
    phoneNumber: user.phoneNumber,
  );

  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : mapUser(user);
  }

  Future<void> logout() => _auth.signOut();

  /// Turns a Firebase error code into a sentence a user can read.
  ///
  /// Shared by every method below so the wording stays consistent. Falls back
  /// to Firebase's own message, then to a generic line — never to a raw code.
  String _readableMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return AppStrings.weakPassword;
      case 'email-already-in-use':
        return AppStrings.emailAlreadyInUse;
      case 'invalid-email':
        return AppStrings.invalidEmailAddress;
      case 'operation-not-allowed':
        return AppStrings.emailPasswordNotEnabled;
      case 'network-request-failed':
        return AppStrings.networkError;
      // Recent Firebase versions collapse user-not-found and wrong-password
      // into invalid-credential, so all three map to the same line — and that
      // is also better practice: never reveal whether an email is registered.
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return AppStrings.wrongEmailOrPassword;
      case 'user-disabled':
        return AppStrings.accountDisabled;
      case 'too-many-requests':
        return AppStrings.tooManyAttempts;
      case 'account-exists-with-different-credential':
        return AppStrings.accountExistsWithDifferentCredential;
      case 'requires-recent-login':
        return AppStrings.requiresRecentLogin;
      default:
        return e.message ?? AppStrings.somethingWentWrong;
    }
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return mapUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _readableMessage(e);
    }
  }

  /// google_sign_in v7 needs one `initialize` before the first
  /// [GoogleSignIn.authenticate]. Doing it lazily rather than in `main()`
  /// keeps a misconfigured project from blocking app start — only the Google
  /// button fails, and it fails with a sentence instead of a crash.
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    // iOS takes its client id from GoogleService-Info.plist, so it needs no
    // serverClientId. Android has no equivalent entry — without the Web client
    // id it cannot mint the ID token Firebase expects, so fail with a sentence
    // rather than an opaque platform error.
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    if (isAndroid && !AppConfig.isGoogleSignInConfigured) {
      throw AppStrings.googleSignInNotConfigured;
    }

    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.isGoogleSignInConfigured
          ? AppConfig.googleServerClientId
          : null,
    );
    _googleInitialized = true;
  }

  /// Returns `null` when the user closes the account picker.
  ///
  /// A cancel is not a failure — the caller must not show a red snack bar for
  /// it, which is why this is nullable rather than throwing.
  Future<AppUser?> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw AppStrings.googleSignInFailed;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await _auth.signInWithCredential(credential);
      return mapUser(result.user!);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AppStrings.googleSignInFailed;
    } on FirebaseAuthException catch (e) {
      throw _readableMessage(e);
    }
  }

  /// Creates the account and sets the display name.
  ///
  /// Firebase does not take a name in the sign-up call, so it has to be set
  /// straight afterwards or it is lost. `reload()` then re-reads
  /// `currentUser`, because the [User] returned by sign-up still has a null
  /// `displayName` in memory even after the update succeeds.
  Future<AppUser> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user!;
      await user.updateDisplayName(name.trim());
      await user.reload();

      return mapUser(_auth.currentUser ?? user);
    } on FirebaseAuthException catch (e) {
      throw _readableMessage(e);
    }
  }

  /// Firebase deliberately succeeds even when the address has no account, so
  /// the caller must not treat a success as proof the email exists — saying so
  /// would let anyone probe which addresses are registered.
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _readableMessage(e);
    }
  }

  Future<AppUser> updateProfile({String? name, String? photoUrl}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AppStrings.requiresRecentLogin;

      if (name != null) await user.updateDisplayName(name.trim());
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);

      // Same reload as sign-up: the in-memory User keeps the old values.
      await user.reload();
      return mapUser(_auth.currentUser ?? user);
    } on FirebaseAuthException catch (e) {
      throw _readableMessage(e);
    }
  }

  /// Firebase refuses this when the session is more than a few minutes old,
  /// which surfaces as `requires-recent-login`.
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AppStrings.requiresRecentLogin;
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _readableMessage(e);
    }
  }
}
