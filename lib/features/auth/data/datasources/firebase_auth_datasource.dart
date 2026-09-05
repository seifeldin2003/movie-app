import 'package:firebase_auth/firebase_auth.dart';

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
      default:
        return e.message ?? AppStrings.somethingWentWrong;
    }
  }

  // ---------------------------------------------------------------------
  // TASK: Login — owner fills these two in.
  // Use signInWithEmailAndPassword; translate 'user-not-found' and
  // 'wrong-password'. For Google, return null on
  // GoogleSignInExceptionCode.canceled instead of throwing.
  // ---------------------------------------------------------------------
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError('Login task: implement signInWithEmail');
  }

  Future<AppUser?> signInWithGoogle() {
    throw UnimplementedError('Login task: implement signInWithGoogle');
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

  // ---------------------------------------------------------------------
  // TASK: Reset Password — owner fills this in.
  // sendPasswordResetEmail; surface e.message as the user-facing string.
  // ---------------------------------------------------------------------
  Future<void> sendPasswordResetEmail({required String email}) {
    throw UnimplementedError('Reset task: implement sendPasswordResetEmail');
  }

  // ---------------------------------------------------------------------
  // Sprint 2 — Update Profile.
  // ---------------------------------------------------------------------
  Future<AppUser> updateProfile({String? name, String? photoUrl}) {
    throw UnimplementedError('Sprint 2: implement updateProfile');
  }
}
