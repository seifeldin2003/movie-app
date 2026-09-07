import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/bloc/request_status.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../movies/domain/repositories/movie_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

/// Drives the Search tab.
///
/// Searching goes to the API rather than filtering a list already in memory.
/// The catalogue is over 77,000 movies and only 20 are loaded at a time, so a
/// local filter could only ever search the current page — it would answer
/// "no results" for almost everything that exists.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc(this._repository) : super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>((_, emit) => emit(const SearchState()));
  }

  final MovieRepository _repository;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    // An emptied box is not a search that found nothing — it is no search at
    // all, and the screen shows a different thing for each.
    if (query.isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(
      state.copyWith(
        status: RequestStatus.loading,
        query: query,
        clearError: true,
      ),
    );

    try {
      // Sorted, not just filtered. YTS's default ordering buries the film
      // you actually searched for: "avengers" led with The Toxic Avenger and
      // "batman" with Batman: Knightfall Part 1, so the obvious answer was
      // nowhere on screen and the search read as broken. Ranking by download
      // count puts Infinity War and The Batman first.
      final results = await _repository.getMovies(
        query: query,
        sortBy: ApiEndpoints.sortByDownloads,
      );
      if (isClosed) return;

      // A late response from an earlier query would otherwise overwrite the
      // results of the one the user is actually looking at. Debouncing makes
      // this rare, not impossible — a slow request still outlives its query.
      if (query != state.query) return;

      emit(state.copyWith(status: RequestStatus.success, results: results));
    } catch (e) {
      if (isClosed) return;
      if (query != state.query) return;

      emit(
        state.copyWith(
          status: RequestStatus.error,
          error: e.toString(),
          results: const [],
        ),
      );
    }
  }
}
