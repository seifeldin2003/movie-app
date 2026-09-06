import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/auth/presentation/bloc/forgot_password/forgot_password_bloc.dart';
import 'package:movie_app/features/auth/presentation/bloc/forgot_password/forgot_password_event.dart';
import 'package:movie_app/features/auth/presentation/bloc/forgot_password/forgot_password_state.dart';

import '../../helpers/fake_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ForgotPasswordBloc', () {
    test('sending the reset email emits loading then success', () async {
      final bloc = ForgotPasswordBloc(FakeAuthRepository());
      addTearDown(bloc.close);

      final states = <ForgotPasswordState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ForgotPasswordSubmitted(email: 'seif@test.com'));
      await Future<void>.delayed(Duration.zero);

      expect(states, hasLength(2));
      expect(states.first, isA<ForgotPasswordLoading>());
      expect(states.last, isA<ForgotPasswordSuccess>());
    });

    test('a rejected request surfaces the message', () async {
      final bloc = ForgotPasswordBloc(
        FakeAuthRepository(error: 'That email address is not valid.'),
      );
      addTearDown(bloc.close);

      final states = <ForgotPasswordState>[];
      bloc.stream.listen(states.add);

      bloc.add(const ForgotPasswordSubmitted(email: 'nope'));
      await Future<void>.delayed(Duration.zero);

      expect(states.last, isA<ForgotPasswordFailure>());
      expect(
        (states.last as ForgotPasswordFailure).message,
        'That email address is not valid.',
      );
    });
  });
}
