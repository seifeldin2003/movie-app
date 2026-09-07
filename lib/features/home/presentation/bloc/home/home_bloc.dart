import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/bloc/request_status.dart';
import '../../../../../core/constants/app_genres.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../movies/domain/entities/movie_section.dart';
import '../../../../movies/domain/repositories/movie_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

/// Drives the Home tab.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const HomeState()) {
    on<HomeStarted>((_, emit) => _load(emit));
    on<HomeRetried>((_, emit) => _load(emit));
  }

  final MovieRepository _repository;

  Future<void> _load(Emitter<HomeState> emit) async {
    emit(
      state.copyWith(
        featuredStatus: RequestStatus.loading,
        sectionsStatus: RequestStatus.loading,
        clearErrors: true,
      ),
    );

    // Started together so the screen waits for the slowest request rather than
    // the sum of all three. Each helper catches internally, so no future ever
    // completes with an error that nothing is listening to yet.
    await Future.wait([_loadFeatured(emit), _loadSections(emit)]);
  }

  Future<void> _loadFeatured(Emitter<HomeState> emit) async {
    try {
      // Sorting by rating alone surfaces obscure records with a handful of
      // votes; download count plus a rating floor is what returns films people
      // recognise, with the backdrops the carousel needs.
      final movies = await _repository.getMovies(
        sortBy: ApiEndpoints.sortByDownloads,
        minimumRating: ApiEndpoints.homeMinimumRating,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          featuredStatus: RequestStatus.success,
          featured: movies,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          featuredStatus: RequestStatus.error,
          featuredError: e.toString(),
        ),
      );
    }
  }

  Future<void> _loadSections(Emitter<HomeState> emit) async {
    try {
      // One request per row, in parallel. `Future.wait` keeps the order of the
      // results matching the order of the genres, so the rows do not shuffle
      // depending on which response landed first.
      final results = await Future.wait(
        AppGenres.homeRows.map((genre) => _repository.getMovies(genre: genre)),
      );

      if (isClosed) return;
      emit(
        state.copyWith(
          sectionsStatus: RequestStatus.success,
          sections: [
            for (var i = 0; i < AppGenres.homeRows.length; i++)
              if (results[i].isNotEmpty)
                MovieSection(title: AppGenres.homeRows[i], movies: results[i]),
          ],
        ),
      );
    } catch (e) {
      // Not fatal: a failed row is no reason to replace a working carousel
      // with an error screen. The rows simply do not appear.
      if (isClosed) return;
      emit(
        state.copyWith(
          sectionsStatus: RequestStatus.error,
          sectionsError: e.toString(),
        ),
      );
    }
  }
}
