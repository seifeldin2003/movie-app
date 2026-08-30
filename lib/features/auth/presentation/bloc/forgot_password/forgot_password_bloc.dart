import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

/// TASK: Reset Password.
///
/// Steps:
///  1. `emit(const ForgotPasswordLoading())` before the await.
///  2. Call `_authRepository.sendPasswordResetEmail(...)`, then emit
///     [ForgotPasswordSuccess].
///  3. `catch (e)` → `emit(ForgotPasswordFailure(e.toString()))`.
///  4. Register in `core/di/injector.dart`:
///     `getIt.registerFactory(() => ForgotPasswordBloc(getIt<AuthRepository>()));`
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc(this._authRepository)
    : super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  // ignore: unused_field — delete this comment once the handler below uses it.
  final AuthRepository _authRepository;

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    // TODO(reset-password): implement per the steps above.
  }
}
