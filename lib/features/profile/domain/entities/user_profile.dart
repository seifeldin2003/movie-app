/// The parts of a user that Firebase Auth cannot hold.
///
/// Auth stores the display name and email; it has no room for a chosen avatar,
/// and its `phoneNumber` is only writable through a verified SMS sign-in — so
/// the phone the sign-up form collects has to live here instead.
class UserProfile {
  const UserProfile({
    required this.uid,
    this.avatarId,
    this.photoBase64,
    this.phoneNumber,
  });

  final String uid;

  /// One of `AppAssets.avatarIds`. Null until the user picks one.
  final String? avatarId;

  /// A personal photo, stored inline as base64 rather than in Cloud Storage —
  /// Storage would force the project onto the Blaze plan, and an avatar this
  /// small fits comfortably inside a Firestore document.
  ///
  /// Wins over [avatarId] when both are set, since it is the more deliberate
  /// choice.
  final String? photoBase64;

  final String? phoneNumber;

  bool get hasUploadedPhoto =>
      photoBase64 != null && photoBase64!.isNotEmpty;

  UserProfile copyWith({
    String? avatarId,
    String? photoBase64,
    String? phoneNumber,
    bool clearPhoto = false,
  }) => UserProfile(
    uid: uid,
    // `?? this.x` cannot put a field back to null, so removing an uploaded
    // photo needs its own flag rather than passing null.
    photoBase64: clearPhoto ? null : (photoBase64 ?? this.photoBase64),
    avatarId: avatarId ?? this.avatarId,
    phoneNumber: phoneNumber ?? this.phoneNumber,
  );
}
