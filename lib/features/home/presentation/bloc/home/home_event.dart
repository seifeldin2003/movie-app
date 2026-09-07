import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => const [];
}

/// Load the carousel and the genre rows.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Retry after a failure, from the button on `ErrorView`.
class HomeRetried extends HomeEvent {
  const HomeRetried();
}
