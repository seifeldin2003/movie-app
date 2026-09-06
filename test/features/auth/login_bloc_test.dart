import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';
import 'package:movie_app/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:movie_app/features/auth/presentation/bloc/login/login_event.dart';
import 'package:movie_app/features/auth/presentation/bloc/login/login_state.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  // A plain `test` has no Flutter binding, so HTTP is not mocked and a stray
  // real call would hit the network. Cheap insurance.
  TestWidgetsFlutterBinding.ensureInitialized();

  const user = AppUser(uid: 'abc123', name: 'Seif', email: 'seif@test.com');

  /// Collects everything a Bloc emits for one event.
  Future<List<LoginState>> statesFor(
    LoginBloc bloc,
    LoginEvent event,
  ) async {
    final states = <LoginState>[];
    bloc.stream.listen(states.add);
    bloc.add(event);
    await Future<void>.delayed(Duration.zero);
    return states;
  }

  group('LoginBloc', () {
    test('email sign-in emits loading then success', () async {
      final bloc = LoginBloc(FakeAuthRepository(user: user));
      addTearDown(bloc.close);

      final states = await statesFor(
        bloc,
        const LoginSubmitted(email: 'seif@test.com', password: 'password123'),
      );

      expect(states, hasLength(2));
      expect(states.first, isA<LoginLoading>());
      expect(states.last, isA<LoginSuccess>());
      expect((states.last as LoginSuccess).user.uid, 'abc123');
    });

    test('a rejected sign-in surfaces the message as-is', () async {
      // The repository throws an already-readable String; the Bloc must not
      // decorate it.
      final bloc = LoginBloc(
        FakeAuthRepository(error: 'Incorrect email or password.'),
      );
      addTearDown(bloc.close);

      final states = await statesFor(
        bloc,
        const LoginSubmitted(email: 'a@b.com', password: 'wrongpass'),
      );

      expect(states.last, isA<LoginFailure>());
      expect(
        (states.last as LoginFailure).message,
        'Incorrect email or password.',
      );
    });

    test('closing the Google picker returns to idle, not failure', () async {
      // The whole point of the nullable return: a cancel must never raise a
      // red snack bar.
      final bloc = LoginBloc(FakeAuthRepository());
      addTearDown(bloc.close);

      final states = await statesFor(bloc, const LoginWithGooglePressed());

      expect(states.last, isA<LoginInitial>());
      expect(states.whereType<LoginFailure>(), isEmpty);
    });

    test('a completed Google sign-in emits success', () async {
      final bloc = LoginBloc(FakeAuthRepository(googleUser: user));
      addTearDown(bloc.close);

      final states = await statesFor(bloc, const LoginWithGooglePressed());

      expect(states.last, isA<LoginSuccess>());
      expect((states.last as LoginSuccess).user.email, 'seif@test.com');
    });
  });
}
