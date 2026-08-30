import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

/// TASK: Login — the reference Bloc shape for the whole project.
///
/// Steps:
///  1. `emit(const LoginLoading())` before the await.
///  2. Call `_authRepository.login(...)`, emit [LoginSuccess] on return.
///  3. `catch (e)` → `emit(LoginFailure(e.toString()))`. The repository already
///     throws a user-readable String, so no error-code handling here.
///  4. For Google: a `null` result means the user closed the picker — emit
///     [LoginInitial], never a failure.
///  5. Register in `core/di/injector.dart`:
///     `getIt.registerFactory(() => LoginBloc(getIt<AuthRepository>()));`
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._authRepository) : super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithGooglePressed>(_onLoginWithGooglePressed);
  }

  // ignore: unused_field — delete this comment once the handlers below use it.
  final AuthRepository _authRepository;

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // TODO(login): implement per the steps above.
  }

  Future<void> _onLoginWithGooglePressed(
    LoginWithGooglePressed event,
    Emitter<LoginState> emit,
  ) async {
    // TODO(login): implement per the steps above.
  }
}
