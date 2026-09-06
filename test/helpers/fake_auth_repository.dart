import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';

/// Stands in for Firebase so tests never touch the network.
///
/// Each field decides what the matching call does, so a test only sets up the
/// one behaviour it cares about.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user, this.error, this.googleUser, this.signedIn});

  final AppUser? user;
  final Object? error;
  final AppUser? googleUser;

  /// What [currentUser] returns — i.e. whether a session was restored.
  final AppUser? signedIn;

  @override
  AppUser? get currentUser => signedIn;

  @override
  Future<AppUser> login({required String email, required String password}) {
    if (error != null) return Future.error(error!);
    return Future.value(user);
  }

  /// `null` models the user closing the Google account picker.
  @override
  Future<AppUser?> loginWithGoogle() {
    if (error != null) return Future.error(error!);
    return Future.value(googleUser);
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) {
    if (error != null) return Future.error(error!);
    return Future.value(user);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    if (error != null) return Future.error(error!);
    return Future.value();
  }

  @override
  Future<AppUser> updateProfile({String? name, String? photoUrl}) {
    if (error != null) return Future.error(error!);
    return Future.value(user);
  }

  @override
  Future<void> deleteAccount() {
    if (error != null) return Future.error(error!);
    return Future.value();
  }

  @override
  Future<void> logout() async {}
}
