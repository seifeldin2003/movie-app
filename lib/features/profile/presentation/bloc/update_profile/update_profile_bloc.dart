import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/domain/repositories/auth_repository.dart';
import 'update_profile_event.dart';
import 'update_profile_state.dart';

/// Drives the Update Profile screen.
///
/// The repository throws a String that is already user-readable, so there is
/// no error-code handling here — the Bloc just surfaces it.
class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  UpdateProfileBloc(this._authRepository) : super(const UpdateProfileState()) {
    on<UpdateProfileStarted>(_onStarted);
    on<UpdateProfileSubmitted>(_onSubmitted);
    on<UpdateProfilePasswordResetRequested>(_onPasswordResetRequested);
    on<UpdateProfileDeleteRequested>(_onDeleteRequested);
  }

  final AuthRepository _authRepository;

  void _onStarted(UpdateProfileStarted event, Emitter<UpdateProfileState> emit) {
    // Reading the cached user is synchronous — no loading state needed.
    emit(state.copyWith(user: _authRepository.currentUser));
  }

  Future<void> _onSubmitted(
    UpdateProfileSubmitted event,
    Emitter<UpdateProfileState> emit,
  ) async {
    emit(state.copyWith(status: UpdateProfileStatus.loading));
    try {
      final user = await _authRepository.updateProfile(name: event.name);
      emit(state.copyWith(status: UpdateProfileStatus.saved, user: user));
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateProfileStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onPasswordResetRequested(
    UpdateProfilePasswordResetRequested event,
    Emitter<UpdateProfileState> emit,
  ) async {
    final email = state.user?.email;
    if (email == null) return;

    emit(state.copyWith(status: UpdateProfileStatus.loading));
    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      emit(state.copyWith(status: UpdateProfileStatus.passwordResetSent));
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateProfileStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    UpdateProfileDeleteRequested event,
    Emitter<UpdateProfileState> emit,
  ) async {
    emit(state.copyWith(status: UpdateProfileStatus.loading));
    try {
      await _authRepository.deleteAccount();
      emit(state.copyWith(status: UpdateProfileStatus.deleted));
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateProfileStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}
