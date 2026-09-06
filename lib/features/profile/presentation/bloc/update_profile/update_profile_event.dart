import 'package:equatable/equatable.dart';

sealed class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();

  @override
  List<Object?> get props => const [];
}

/// Loads the signed-in user so the form can start pre-filled.
class UpdateProfileStarted extends UpdateProfileEvent {
  const UpdateProfileStarted();
}

class UpdateProfileSubmitted extends UpdateProfileEvent {
  const UpdateProfileSubmitted({required this.name});

  final String name;

  @override
  List<Object?> get props => [name];
}

/// Sends the reset email to the signed-in user's own address.
class UpdateProfilePasswordResetRequested extends UpdateProfileEvent {
  const UpdateProfilePasswordResetRequested();
}

class UpdateProfileDeleteRequested extends UpdateProfileEvent {
  const UpdateProfileDeleteRequested();
}
