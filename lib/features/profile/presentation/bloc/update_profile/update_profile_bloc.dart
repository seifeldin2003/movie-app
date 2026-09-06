import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/domain/repositories/auth_repository.dart';
import '../../../data/datasources/avatar_photo_picker.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/user_profile_repository.dart';
import 'update_profile_event.dart';
import 'update_profile_state.dart';

/// Drives the Update Profile screen.
///
/// The user's details are split across two places, which this Bloc hides from
/// the screen: the display name lives on the Firebase Auth user, while the
/// avatar and phone live in a Firestore document — Auth has nowhere to put
/// them, and its own `phoneNumber` is only writable via verified SMS.
///
/// Both repositories throw a String that is already user-readable, so there is
/// no error-code handling here.
class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  UpdateProfileBloc(
    this._authRepository,
    this._profileRepository,
    this._photoPicker,
  ) : super(const UpdateProfileState()) {
    on<UpdateProfileStarted>(_onStarted);
    on<UpdateProfileSubmitted>(_onSubmitted);
    on<UpdateProfileAvatarSelected>(_onAvatarSelected);
    on<UpdateProfilePhotoUploadRequested>(_onPhotoUploadRequested);
    on<UpdateProfilePhotoRemoved>(_onPhotoRemoved);
    on<UpdateProfilePasswordResetRequested>(_onPasswordResetRequested);
    on<UpdateProfileDeleteRequested>(_onDeleteRequested);
  }

  final AuthRepository _authRepository;
  final UserProfileRepository _profileRepository;
  final AvatarPhotoPicker _photoPicker;

  /// The profile being edited, falling back to an empty one so the avatar
  /// events have something to copy from before the document loads.
  UserProfile _workingProfile(String uid) =>
      state.profile ?? UserProfile(uid: uid);

  Future<void> _onStarted(
    UpdateProfileStarted event,
    Emitter<UpdateProfileState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    emit(state.copyWith(user: user, status: UpdateProfileStatus.loading));

    try {
      final profile = await _profileRepository.load(user.uid);
      emit(
        state.copyWith(
          status: UpdateProfileStatus.initial,
          // A user who has never saved has no document yet; start them on an
          // empty profile rather than treating it as an error.
          profile: profile ?? UserProfile(uid: user.uid),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateProfileStatus.failure,
          message: e.toString(),
          profile: UserProfile(uid: user.uid),
        ),
      );
    }
  }

  void _onAvatarSelected(
    UpdateProfileAvatarSelected event,
    Emitter<UpdateProfileState> emit,
  ) {
    final user = state.user;
    if (user == null) return;

    // Choosing an illustration clears any uploaded photo, otherwise the photo
    // would keep winning and the tap would look like it did nothing.
    emit(
      state.copyWith(
        status: UpdateProfileStatus.initial,
        profile: _workingProfile(
          user.uid,
        ).copyWith(avatarId: event.avatarId, clearPhoto: true),
      ),
    );
  }

  Future<void> _onPhotoUploadRequested(
    UpdateProfilePhotoUploadRequested event,
    Emitter<UpdateProfileState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;

    try {
      final encoded = await _photoPicker.pickAsBase64();

      // Null means the gallery was dismissed — a cancel, not a failure.
      if (encoded == null) return;

      emit(
        state.copyWith(
          status: UpdateProfileStatus.initial,
          profile: _workingProfile(user.uid).copyWith(photoBase64: encoded),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UpdateProfileStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  void _onPhotoRemoved(
    UpdateProfilePhotoRemoved event,
    Emitter<UpdateProfileState> emit,
  ) {
    final user = state.user;
    if (user == null) return;

    emit(
      state.copyWith(
        status: UpdateProfileStatus.initial,
        profile: _workingProfile(user.uid).copyWith(clearPhoto: true),
      ),
    );
  }

  Future<void> _onSubmitted(
    UpdateProfileSubmitted event,
    Emitter<UpdateProfileState> emit,
  ) async {
    final user = state.user;
    if (user == null) return;

    emit(state.copyWith(status: UpdateProfileStatus.loading));
    try {
      // Name to Auth, everything else to Firestore.
      final updated = await _authRepository.updateProfile(name: event.name);

      final profile = _workingProfile(
        user.uid,
      ).copyWith(phoneNumber: event.phoneNumber);
      await _profileRepository.save(profile);

      emit(
        state.copyWith(
          status: UpdateProfileStatus.saved,
          user: updated,
          profile: profile,
        ),
      );
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
