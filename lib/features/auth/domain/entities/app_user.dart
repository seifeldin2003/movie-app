/// A signed-in user, independent of Firebase.
///
/// The presentation layer never imports `firebase_auth` — it works with this
/// class, so swapping the auth backend later touches only `data/`.
class AppUser {
  const AppUser({
    required this.uid,
    this.name,
    this.email,
    this.photoUrl,
    this.phoneNumber,
  });

  final String uid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String? phoneNumber;
}
