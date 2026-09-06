import 'package:equatable/equatable.dart';

sealed class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();

  @override
  List<Object?> get props => const [];
}

/// Loads the signed-in user and their Firestore document so the form can
/// start pre-filled.
class UpdateProfileStarted extends UpdateProfileEvent {
  const UpdateProfileStarted();
}

class UpdateProfileSubmitted extends UpdateProfileEvent {
  const UpdateProfileSubmitted({required this.name, this.phoneNumber});

  final String name;
  final String? phoneNumber;

  @override
  List<Object?> get props => [name, phoneNumber];
}

/// Picking an avatar only stages it. The design has an explicit "Update Data"
/// button, so nothing is written until that is pressed — and a browsing user
/// does not cause a write per tap.
class UpdateProfileAvatarSelected extends UpdateProfileEvent {
  const UpdateProfileAvatarSelected(this.avatarId);

  final String avatarId;

  @override
  List<Object?> get props => [avatarId];
}

class UpdateProfilePhotoUploadRequested extends UpdateProfileEvent {
  const UpdateProfilePhotoUploadRequested();
}

/// Drops the uploaded photo, falling back to the chosen illustration.
class UpdateProfilePhotoRemoved extends UpdateProfileEvent {
  const UpdateProfilePhotoRemoved();
}

/// Sends the reset email to the signed-in user's own address.
class UpdateProfilePasswordResetRequested extends UpdateProfileEvent {
  const UpdateProfilePasswordResetRequested();
}

class UpdateProfileDeleteRequested extends UpdateProfileEvent {
  const UpdateProfileDeleteRequested();
}
