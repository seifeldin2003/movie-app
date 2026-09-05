import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

/// Drives the Register screen.
///
/// The repository throws a String that is already user-readable, so there is
/// no error-code handling here — the Bloc just surfaces it.
///
/// Note: confirm-password matching is *form validation* and lives in the
/// screen's `Form` validator, not here.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._authRepository) : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final AuthRepository _authRepository;

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());
    try {
      final user = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        phoneNumber: event.phoneNumber,
      );
      emit(RegisterSuccess(user));
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}
