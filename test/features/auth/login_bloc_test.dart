import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:movie_app/features/auth/presentation/bloc/login/login_event.dart';
import 'package:movie_app/features/auth/presentation/bloc/login/login_state.dart';

/// Stands in for Firebase so these tests never touch the network.
///
/// Each field decides what the matching call does, so a test only sets up the
/// one behaviour it cares about.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.user, this.error, this.googleUser});

  final AppUser? user;
  final Object? error;
  final AppUser? googleUser;

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
  AppUser? get currentUser => null;

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  }) => Future.value(user);

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<AppUser> updateProfile({String? name, String? photoUrl}) =>
      Future.value(user);
}

void main() {
  // A plain `test` has no Flutter binding, so HTTP is not mocked and a stray
  // real call would hit the network. Cheap insurance.
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = AppUser(uid: 'abc123', name: 'Seif', email: 'seif@test.com');

  group('LoginBloc', () {
    test('email sign-in emits loading then success', () async {
      final bloc = LoginBloc(_FakeAuthRepository(user: user));
      addTearDown(bloc.close);

      final states = <LoginState>[];
      bloc.stream.listen(states.add);

      bloc.add(
        const LoginSubmitted(email: 'seif@test.com', password: 'password123'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(2));
      expect(states.first, isA<LoginLoading>());
      expect(states.last, isA<LoginSuccess>());
      expect((states.last as LoginSuccess).user.uid, 'abc123');
    });

    test('a rejected sign-in surfaces the message as-is', () async {
      // The repository throws an already-readable String; the Bloc must not
      // decorate it.
      final bloc = LoginBloc(
        _FakeAuthRepository(error: 'Incorrect email or password.'),
      );
      addTearDown(bloc.close);

      final states = <LoginState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoginSubmitted(email: 'a@b.com', password: 'wrongpass'));
      await Future<void>.delayed(Duration.zero);

      expect(states.last, isA<LoginFailure>());
      expect(
        (states.last as LoginFailure).message,
        'Incorrect email or password.',
      );
    });

    test('closing the Google picker returns to idle, not failure', () async {
      // The whole point of the nullable return: a cancel must never raise a
      // red snack bar.
      final bloc = LoginBloc(_FakeAuthRepository());
      addTearDown(bloc.close);

      final states = <LoginState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoginWithGooglePressed());
      await Future<void>.delayed(Duration.zero);

      expect(states.last, isA<LoginInitial>());
      expect(states.whereType<LoginFailure>(), isEmpty);
    });

    test('a completed Google sign-in emits success', () async {
      final bloc = LoginBloc(_FakeAuthRepository(googleUser: user));
      addTearDown(bloc.close);

      final states = <LoginState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoginWithGooglePressed());
      await Future<void>.delayed(Duration.zero);

      expect(states.last, isA<LoginSuccess>());
      expect((states.last as LoginSuccess).user.email, 'seif@test.com');
    });
  });
}
