import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/request_status.dart';
import '../../../../../core/constants/app_genres.dart';
import '../../../../movies/domain/entities/movie.dart';

/// The selected genre lives on the state, not on the Bloc.
///
/// A field on the Bloc would be data the view could read behind `emit`'s back,
/// and then the chip row and the grid could disagree about which genre is
/// showing. Keeping it here means one object decides what the whole screen
/// looks like.
class BrowseState extends Equatable {
  const BrowseState({
    this.selectedGenre = AppGenres.defaultGenre,
    this.status = RequestStatus.initial,
    this.movies = const [],
    this.error,
  });

  final String selectedGenre;
  final RequestStatus status;
  final List<Movie> movies;
  final String? error;

  BrowseState copyWith({
    String? selectedGenre,
    RequestStatus? status,
    List<Movie>? movies,
    String? error,
    bool clearError = false,
  }) => BrowseState(
    selectedGenre: selectedGenre ?? this.selectedGenre,
    status: status ?? this.status,
    movies: movies ?? this.movies,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [selectedGenre, status, movies, error];
}
