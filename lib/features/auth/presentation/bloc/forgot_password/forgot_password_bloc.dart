import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

/// Drives the Forgot Password screen.
///
/// The repository throws a String that is already user-readable, so there is
/// no error-code handling here — the Bloc just surfaces it.
class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc(this._authRepository)
    : super(const ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  final AuthRepository _authRepository;

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email: event.email);
      emit(const ForgotPasswordSuccess());
    } catch (e) {
      emit(ForgotPasswordFailure(e.toString()));
    }
  }
}
