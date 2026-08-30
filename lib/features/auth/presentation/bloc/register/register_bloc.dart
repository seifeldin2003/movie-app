import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'register_event.dart';
import 'register_state.dart';

/// TASK: Register.
///
/// Steps:
///  1. `emit(const RegisterLoading())` before the await.
///  2. Call `_authRepository.register(...)`, emit [RegisterSuccess].
///  3. `catch (e)` → `emit(RegisterFailure(e.toString()))`.
///  4. Register in `core/di/injector.dart`:
///     `getIt.registerFactory(() => RegisterBloc(getIt<AuthRepository>()));`
///
/// Note: confirm-password matching is *form validation* — handle it in the
/// screen's `Form` validator, not in the Bloc.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._authRepository) : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  // ignore: unused_field — delete this comment once the handler below uses it.
  final AuthRepository _authRepository;

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    // TODO(register): implement per the steps above.
  }
}
