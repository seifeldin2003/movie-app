import 'package:equatable/equatable.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => const [];
}

/// The query to run.
///
/// Already debounced by the time it gets here — the screen holds the timer,
/// because how fast someone types is a property of the input, not of the
/// search.
class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Back to the empty prompt.
class SearchCleared extends SearchEvent {
  const SearchCleared();
}
