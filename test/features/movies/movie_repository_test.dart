import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/network/api_client.dart';
import 'package:movie_app/core/network/api_exception.dart';
import 'package:movie_app/features/movies/data/datasources/movie_local_datasource.dart';
import 'package:movie_app/features/movies/data/datasources/movie_remote_datasource.dart';
import 'package:movie_app/features/movies/data/models/movie_details_model.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/data/repositories/movie_repository_impl.dart';

/// A remote source that never reaches the network.
///
/// Subclassed rather than mocked: the methods are the whole surface, and
/// overriding them is less machinery than a mocking package for a class this
/// small. `super(ApiClient())` builds a Dio that is never used — no request
/// leaves here.
class _OfflineRemote extends MovieRemoteDataSource {
  _OfflineRemote({required this.error}) : super(ApiClient());

  final ApiException error;
  int calls = 0;

  @override
  Future<List<MovieModel>> listMovies({
    String? query,
    String? genre,
    int page = 1,
    int limit = 20,
    String? sortBy,
    int? minimumRating,
  }) async {
    calls++;
    throw error;
  }

  @override
  Future<MovieDetailsModel?> movieDetails(int movieId) async {
    calls++;
    throw error;
  }

  @override
  Future<List<MovieModel>> movieSuggestions(int movieId) async {
    calls++;
    throw error;
  }
}

/// A remote source that answers from the bundled snapshot, standing in for a
/// working network.
class _OnlineRemote extends MovieRemoteDataSource {
  _OnlineRemote() : super(ApiClient());

  static const MovieLocalDataSource _source = MovieLocalDataSource();
  int calls = 0;

  @override
  Future<List<MovieModel>> listMovies({
    String? query,
    String? genre,
    int page = 1,
    int limit = 20,
    String? sortBy,
    int? minimumRating,
  }) async {
    calls++;
    return _source.listMovies();
  }
}

void main() {
  // Required before rootBundle will serve the bundled JSON, and it is what
  // stops a plain `test` from making real HTTP calls.
  TestWidgetsFlutterBinding.ensureInitialized();

  const local = MovieLocalDataSource();

  const noInternet = ApiException(
    'No internet connection.',
    isConnectionIssue: true,
  );

  /// A real answer from the server, not a transport failure.
  const notFound = ApiException('Movie not found.');

  group('the failure path', () {
    test('falls back to the bundled catalogue when the network is gone', () {
      final repository = MovieRepositoryImpl(
        _OfflineRemote(error: noInternet),
        local,
      );

      // The point of the whole design: no connection, still a catalogue.
      expect(repository.getMovies(), completion(hasLength(20)));
    });

    test('the fallback movies are real records, not placeholders', () async {
      final repository = MovieRepositoryImpl(
        _OfflineRemote(error: noInternet),
        local,
      );

      final movies = await repository.getMovies();

      expect(movies.first.title, isNotEmpty);
      expect(movies.first.posterUrl, startsWith('http'));
      expect(movies.first.imdbCode, startsWith('tt'));
    });

    test('offline details and suggestions fall back too', () async {
      final repository = MovieRepositoryImpl(
        _OfflineRemote(error: noInternet),
        local,
      );

      final details = await repository.getMovieDetails(10);
      expect(details.cast, isNotEmpty);
      expect(await repository.getSimilarMovies(10), hasLength(4));
    });

    test('a search is never answered from the bundled catalogue', () {
      // The fallback is right for Home and Browse — any catalogue beats a
      // blank screen. For a search it is actively wrong: asking for "batman"
      // offline would return Avengers, Superbad and eighteen other unrelated
      // films, presented as matches.
      final repository = MovieRepositoryImpl(
        _OfflineRemote(error: noInternet),
        local,
      );

      expect(
        repository.getMovies(query: 'batman'),
        throwsA(isA<ApiException>()),
      );
    });

    test('a real server answer is reported, not papered over', () {
      // A 404 means the movie is not there. Quietly showing a bundled
      // catalogue instead would be lying to the user, so only a transport
      // failure triggers the fallback.
      final repository = MovieRepositoryImpl(
        _OfflineRemote(error: notFound),
        local,
      );

      expect(repository.getMovies(), throwsA(isA<ApiException>()));
    });
  });

  group('the memory cache', () {
    test('a repeated request does not hit the source again', () async {
      // Why the repository is a singleton in the injector: returning to a tab
      // paints from here instead of showing the spinner a second time.
      final remote = _OnlineRemote();
      final repository = MovieRepositoryImpl(remote, local);

      await repository.getMovies(genre: 'Action');
      await repository.getMovies(genre: 'Action');

      expect(remote.calls, 1);
    });

    test('different arguments are cached separately', () async {
      // A shared key would show Action results under the Drama chip.
      final remote = _OnlineRemote();
      final repository = MovieRepositoryImpl(remote, local);

      await repository.getMovies(genre: 'Action');
      await repository.getMovies(genre: 'Drama');
      await repository.getMovies(genre: 'Action', page: 2);

      expect(remote.calls, 3);
    });

    test('a failed request is not cached', () async {
      // Caching the fallback would mean the first bad moment on a train
      // pinned the app to the snapshot for the rest of the session.
      final remote = _OfflineRemote(error: noInternet);
      final repository = MovieRepositoryImpl(remote, local);

      await repository.getMovies();
      await repository.getMovies();

      expect(remote.calls, 2);
    });
  });
}
