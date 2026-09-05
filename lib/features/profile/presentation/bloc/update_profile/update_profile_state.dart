import 'package:equatable/equatable.dart';

import '../../../../auth/domain/entities/app_user.dart';

/// One state class carrying a status, rather than a class per phase.
///
/// The screen needs the loaded user to stay on screen while a save is in
/// flight — with a class per phase the user would vanish on every emit and the
/// form would blank out mid-save.
enum UpdateProfileStatus { initial, loading, saved, passwordResetSent, deleted, failure }

class UpdateProfileState extends Equatable {
  const UpdateProfileState({
    this.status = UpdateProfileStatus.initial,
    this.user,
    this.message,
  });

  final UpdateProfileStatus status;
  final AppUser? user;

  /// Only set when [status] is [UpdateProfileStatus.failure].
  final String? message;

  bool get isLoading => status == UpdateProfileStatus.loading;

  UpdateProfileState copyWith({
    UpdateProfileStatus? status,
    AppUser? user,
    String? message,
  }) => UpdateProfileState(
    status: status ?? this.status,
    user: user ?? this.user,
    // Not carried over: a stale error must not survive the next action.
    message: message,
  );

  @override
  List<Object?> get props => [status, user, message];
}
