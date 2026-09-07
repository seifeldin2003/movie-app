import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/bloc/request_status.dart';
import '../../../../movies/domain/repositories/movie_repository.dart';
import 'browse_event.dart';
import 'browse_state.dart';

/// Drives the Browse tab.
class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  BrowseBloc(this._repository) : super(const BrowseState()) {
    on<BrowseStarted>((_, emit) => _load(state.selectedGenre, emit));
    on<BrowseGenreSelected>((event, emit) => _load(event.genre, emit));
  }

  final MovieRepository _repository;

  Future<void> _load(String genre, Emitter<BrowseState> emit) async {
    // The chip highlights immediately, before the request finishes. Waiting
    // for the response to move the selection makes every tap feel broken.
    //
    // The previous genre's posters are deliberately cleared at the same time:
    // leaving them under a newly highlighted chip says the wrong thing.
    emit(
      state.copyWith(
        selectedGenre: genre,
        status: RequestStatus.loading,
        movies: const [],
        clearError: true,
      ),
    );

    try {
      final movies = await _repository.getMovies(genre: genre);
      if (isClosed) return;

      // A slow response for a genre the user has already tapped away from
      // would otherwise land under the wrong chip.
      if (genre != state.selectedGenre) return;

      emit(state.copyWith(status: RequestStatus.success, movies: movies));
    } catch (e) {
      if (isClosed) return;
      if (genre != state.selectedGenre) return;

      emit(state.copyWith(status: RequestStatus.error, error: e.toString()));
    }
  }
}
