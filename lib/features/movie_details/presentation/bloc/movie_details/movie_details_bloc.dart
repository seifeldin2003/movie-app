import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/bloc/request_status.dart';
import '../../../../history/domain/repositories/history_repository.dart';
import '../../../../movies/domain/entities/movie.dart';
import '../../../../movies/domain/repositories/movie_repository.dart';
import '../../../../watchlist/domain/repositories/watchlist_repository.dart';
import 'movie_details_event.dart';
import 'movie_details_state.dart';

/// Drives the Movie Details screen.
///
/// Three repositories, because this screen sits where they meet: the record
/// and its suggestions come from YTS, the bookmark from Firestore, and
/// opening the screen is what writes an entry to the watch history.
///
/// Each repository throws a message that is already a readable sentence, so
/// there is no error-code handling here — the Bloc surfaces `e.toString()`.
///
/// Holds no data fields of its own. Everything the screen draws comes out of
/// [MovieDetailsState]; a field on the Bloc would be data the view could read
/// behind `emit`'s back, and then `emit` is just `notifyListeners()` with
/// extra ceremony.
class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  MovieDetailsBloc(this._repository, this._watchlist, this._history)
    : super(const MovieDetailsState()) {
    on<MovieDetailsRequested>((event, emit) => _load(event.movie, emit));
    on<MovieDetailsRetried>((event, emit) => _load(event.movie, emit));
    on<MovieDetailsWatchlistToggled>(_onWatchlistToggled);
  }

  final MovieRepository _repository;
  final WatchlistRepository _watchlist;
  final HistoryRepository _history;

  Future<void> _load(Movie movie, Emitter<MovieDetailsState> emit) async {
    emit(
      state.copyWith(
        detailsStatus: RequestStatus.loading,
        similarStatus: RequestStatus.loading,
        // A retry must not leave the previous failure's message on screen
        // next to the content that just loaded successfully.
        clearErrors: true,
      ),
    );

    // Started together rather than awaited one after the other: the calls are
    // independent, so running them in sequence would make the screen wait for
    // the sum of the round trips instead of the longest one.
    //
    // Each helper catches internally, so no future ever completes with an
    // error that nothing is listening to yet. `Future.wait` then holds the
    // handler open until all four have finished, which is what keeps `emit`
    // legal.
    await Future.wait([
      _loadDetails(movie.id, emit),
      _loadSimilar(movie.id, emit),
      _loadWatchListState(movie.id, emit),
      _recordView(movie),
    ]);
  }

  Future<void> _loadDetails(
    int movieId,
    Emitter<MovieDetailsState> emit,
  ) async {
    try {
      final details = await _repository.getMovieDetails(movieId);
      if (isClosed) return;
      emit(
        state.copyWith(
          detailsStatus: RequestStatus.success,
          details: details,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          detailsStatus: RequestStatus.error,
          detailsError: e.toString(),
        ),
      );
    }
  }

  Future<void> _loadSimilar(
    int movieId,
    Emitter<MovieDetailsState> emit,
  ) async {
    try {
      final similar = await _repository.getSimilarMovies(movieId);
      if (isClosed) return;
      emit(
        state.copyWith(
          similarStatus: RequestStatus.success,
          similar: similar,
        ),
      );
    } catch (e) {
      // Deliberately not fatal. Suggestions failing is no reason to replace a
      // fully loaded movie with an error screen — the Similar section drops
      // out and the rest of the page stands.
      if (isClosed) return;
      emit(
        state.copyWith(
          similarStatus: RequestStatus.error,
          similarError: e.toString(),
        ),
      );
    }
  }

  /// Opening the screen is what counts as watching, so history is written
  /// here rather than behind the Watch button — which does not play anything
  /// yet.
  ///
  /// ⚠️ Its own try/catch, and alongside the loads rather than in front of
  /// them. It used to be `await _history.record(movie)` on the line above
  /// `Future.wait`, which was safe only while history was in memory and could
  /// not fail. Against Firestore it can — offline, or permission-denied — and
  /// there it would abort the handler, so the entire Movie Details screen
  /// would fail to load because a history entry could not be written.
  ///
  /// Nothing is shown when it fails. Recording a view is bookkeeping the user
  /// did not ask for; a snack bar about it over a movie that loaded fine is
  /// noise.
  Future<void> _recordView(Movie movie) async {
    try {
      await _history.record(movie);
    } catch (_) {
      // Intentionally ignored — see above.
    }
  }

  Future<void> _loadWatchListState(
    int movieId,
    Emitter<MovieDetailsState> emit,
  ) async {
    try {
      final saved = await _watchlist.contains(movieId);
      if (isClosed) return;
      emit(state.copyWith(isInWatchList: saved));
    } catch (_) {
      // Swallowed on purpose: an unreadable bookmark is not worth an error
      // screen over a movie that loaded fine. It shows as unsaved, and
      // tapping it will surface any real problem.
    }
  }

  Future<void> _onWatchlistToggled(
    MovieDetailsWatchlistToggled event,
    Emitter<MovieDetailsState> emit,
  ) async {
    final wasSaved = state.isInWatchList;

    // Flipped before the write, so the control responds to the tap instead of
    // waiting on Firestore. Rolled back below if the write fails.
    emit(state.copyWith(isInWatchList: !wasSaved, clearErrors: true));

    try {
      if (wasSaved) {
        await _watchlist.remove(event.movie.id);
      } else {
        await _watchlist.add(event.movie);
      }
    } catch (e) {
      if (isClosed) return;

      // Rolled back, because leaving it filled would claim the movie was
      // saved when it was not — the user would only find out when Profile
      // came back empty.
      //
      // The message goes out with it. Rolling back *silently* is what made a
      // Firestore permission-denied look like the bookmark just refusing to
      // stay pressed, with nothing to go on.
      emit(
        state.copyWith(isInWatchList: wasSaved, watchListError: e.toString()),
      );
    }
  }
}
