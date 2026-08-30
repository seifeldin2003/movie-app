import 'package:equatable/equatable.dart';

import '../../../domain/entities/app_user.dart';

/// Every async screen covers all four branches: initial → loading →
/// success / failure. Do not collapse them into a single boolean.
sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => const [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

/// A cancelled Google picker is NOT a failure — that emits [LoginInitial].
/// This state always means something actually went wrong.
class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
