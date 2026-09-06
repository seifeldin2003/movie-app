import 'package:equatable/equatable.dart';

import '../../../../auth/domain/entities/app_user.dart';
import '../../../domain/entities/user_profile.dart';

/// One state class carrying a status, rather than a class per phase.
///
/// The screen needs the loaded user and profile to stay on screen while a save
/// is in flight — with a class per phase they would vanish on every emit and
/// the form would blank out mid-save.
enum UpdateProfileStatus {
  initial,
  loading,
  saved,
  passwordResetSent,
  deleted,
  failure,
}

class UpdateProfileState extends Equatable {
  const UpdateProfileState({
    this.status = UpdateProfileStatus.initial,
    this.user,
    this.profile,
    this.message,
  });

  final UpdateProfileStatus status;

  /// Name and email, from Firebase Auth.
  final AppUser? user;

  /// Avatar and phone, from the Firestore document. Null until loaded, or
  /// when the user has no document yet.
  final UserProfile? profile;

  /// Only set when [status] is [UpdateProfileStatus.failure].
  final String? message;

  bool get isLoading => status == UpdateProfileStatus.loading;

  UpdateProfileState copyWith({
    UpdateProfileStatus? status,
    AppUser? user,
    UserProfile? profile,
    String? message,
  }) => UpdateProfileState(
    status: status ?? this.status,
    user: user ?? this.user,
    profile: profile ?? this.profile,
    // Not carried over: a stale error must not survive the next action.
    message: message,
  );

  @override
  List<Object?> get props => [status, user, profile, message];
}
