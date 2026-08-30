import '../entities/app_user.dart';

/// The auth contract every Sprint 1 auth task codes against.
///
/// ⚠️ AGREED INTERFACE — do not change a signature without telling the team;
/// three branches implement against it at the same time. Adding a *new* method
/// is fine, editing an existing one breaks someone else's branch.
///
/// Implementations throw a `String` message that is already user-readable —
/// Blocs surface `e.toString()` directly and never see a Firebase error code.
abstract class AuthRepository {
  /// Email + password sign-in. Owner: Login task.
  Future<AppUser> login({required String email, required String password});

  /// Google account sign-in. Returns `null` when the user closes the picker —
  /// a cancel is not an error and must not show a red snackbar. Owner: Login.
  Future<AppUser?> loginWithGoogle();

  /// Creates the account and sets the display name. Owner: Register task.
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  });

  /// Sends the reset email. Owner: Reset Password task.
  Future<void> sendPasswordResetEmail({required String email});

  /// Sprint 2 — Update Profile. Signature reserved so nobody renames it later.
  Future<AppUser> updateProfile({String? name, String? photoUrl});

  Future<void> logout();

  /// The user restored from disk on cold start, or `null` when signed out.
  AppUser? get currentUser;
}
