import 'package:equatable/equatable.dart';

import '../../../../movies/domain/entities/movie.dart';

sealed class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();

  @override
  List<Object?> get props => const [];
}

/// Load everything for [movie].
///
/// Carries the whole record rather than just an id: the id is what the API
/// calls need, but the watch list and the history store the movie itself so
/// Profile can render them without a request per saved title.
class MovieDetailsRequested extends MovieDetailsEvent {
  const MovieDetailsRequested(this.movie);

  final Movie movie;

  @override
  List<Object?> get props => [movie.id];
}

/// Retry after a failure, from the button on `ErrorView`.
class MovieDetailsRetried extends MovieDetailsEvent {
  const MovieDetailsRetried(this.movie);

  final Movie movie;

  @override
  List<Object?> get props => [movie.id];
}

/// Save or unsave, from the bookmark control in the app bar.
class MovieDetailsWatchlistToggled extends MovieDetailsEvent {
  const MovieDetailsWatchlistToggled(this.movie);

  final Movie movie;

  @override
  List<Object?> get props => [movie.id];
}
