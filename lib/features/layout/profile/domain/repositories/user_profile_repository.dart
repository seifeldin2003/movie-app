import '../entities/user_profile.dart';

/// Reads and writes the `users/{uid}` document.
///
/// Implementations throw a `String` that is already user-readable, matching
/// the auth layer — Blocs surface it directly and never see a Firebase code.
abstract class UserProfileRepository {
  /// Returns `null` when the user has no document yet, which is the normal
  /// state right after sign-up.
  Future<UserProfile?> load(String uid);

  /// Merges into the existing document rather than replacing it, so writing
  /// an avatar cannot wipe the phone number — or, later, the watch list.
  Future<void> save(UserProfile profile);
}
