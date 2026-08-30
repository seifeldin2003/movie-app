import 'package:equatable/equatable.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => const [];
}

class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
  });

  final String name;
  final String email;
  final String password;
  final String? phoneNumber;

  @override
  List<Object?> get props => [name, email, password, phoneNumber];
}
