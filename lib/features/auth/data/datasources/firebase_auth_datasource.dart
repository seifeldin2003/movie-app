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
  }) {
    throw UnimplementedError('Register task: implement createAccount');
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
