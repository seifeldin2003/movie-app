import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Drives the Login screen.
///
/// The repository throws a String that is already user-readable, so there is
/// no error-code handling here — the Bloc just surfaces it.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._authRepository) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithGooglePressed>(_onLoginWithGooglePressed);
  }

  final AuthRepository _authRepository;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> _onLoginWithGooglePressed(
    LoginWithGooglePressed event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());
    try {
      final user = await _authRepository.loginWithGoogle();

      // A null user means the account picker was closed. That is a normal
      // cancel, so drop back to idle rather than reporting a failure.
      if (user == null) {
        emit(const LoginInitial());
        return;
      }

      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
