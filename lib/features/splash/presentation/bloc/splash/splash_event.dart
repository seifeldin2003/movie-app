import 'package:equatable/equatable.dart';

sealed class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => const [];
}

/// Dispatched once, when the splash screen is created.
class SplashStarted extends SplashEvent {
  const SplashStarted();
}
