import 'package:firebase_auth/firebase_auth.dart';

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

  // ---------------------------------------------------------------------
  // TASK: Register — owner fills this in.
  // createUserWithEmailAndPassword, then updateProfile(displayName: name)
  // or the name is lost. Translate 'weak-password' and 'email-already-in-use'.
  // ---------------------------------------------------------------------
  Future<AppUser> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw 'Failed to create user account.';
      }
      await user.updateDisplayName(name);
      return AppUser(
        uid: user.uid,
        name: name,
        email: user.email,
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw 'The password provided is too weak.';
        case 'email-already-in-use':
          throw 'An account already exists for that email.';
        case 'invalid-email':
          throw 'The email address is not valid.';
        default:
          throw e.message ?? 'An unexpected error occurred during registration.';
      }
    } catch (e) {
      if (e is String) rethrow;
      throw e.toString();
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
