import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Wires the [AuthRepository] contract to the Firebase data source.
///
/// ⚠️ SHARED FILE — three Sprint 1 branches touch this. Each task fills in
/// only its own method body; the methods are non-overlapping, so a conflict
/// here should be a trivial one. Rebase on `development` often.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final FirebaseAuthDataSource _dataSource;

  @override
  AppUser? get currentUser => _dataSource.currentUser;

  @override
  Future<void> logout() => _dataSource.logout();

  // TASK: Login
  @override
  Future<AppUser> login({required String email, required String password}) =>
      _dataSource.signInWithEmail(email: email, password: password);

  // TASK: Login
  @override
  Future<AppUser?> loginWithGoogle() => _dataSource.signInWithGoogle();

  // TASK: Register
  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) => _dataSource.createAccount(
    name: name,
    email: email,
    password: password,
  );

  // TASK: Reset Password
  @override
  Future<void> sendPasswordResetEmail({required String email}) =>
      _dataSource.sendPasswordResetEmail(email: email);

  // Sprint 2
  @override
  Future<AppUser> updateProfile({String? name, String? photoUrl}) =>
      _dataSource.updateProfile(name: name, photoUrl: photoUrl);
}
