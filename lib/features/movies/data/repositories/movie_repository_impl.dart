import '../../../../core/network/api_exception.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_details.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_datasource.dart';
import '../datasources/movie_remote_datasource.dart';

/// Where the happy path and the failure path meet.
///
/// Two jobs, and only these two:
///
/// 1. **Remember what this session already loaded**, so coming back to a tab
///    paints immediately instead of showing the spinner a second time. The
///    API is free — this is about how the app *feels*, not about quota.
/// 2. **Fall back to bundled data when the network is unreachable**, so the
///    app degrades to something watchable instead of an error screen.
///
/// Notice there is no `if (isOnline)` anywhere. Checking connectivity up front
/// is a race — the answer can be stale by the time the request goes out, and
/// "connected to wifi" does not mean "can reach this mirror". Trying and
/// catching is both simpler and more accurate.
class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl(this._remote, this._local);

  final MovieRemoteDataSource _remote;
  final MovieLocalDataSource _local;

  /// Lives exactly as long as the app process, which is exactly as long as
  /// "don't make me wait for this again" needs. Nothing here survives a
  /// restart, and nothing needs to — a plain `Map` beats a storage package.
  final Map<String, List<Movie>> _movieCache = {};
  final Map<int, MovieDetails> _detailsCache = {};

  @override
  Future<List<Movie>> getMovies({
    String? query,
    String? genre,
    int page = 1,
    String? sortBy,
    int? minimumRating,
  }) async {
    final key = 'movies:$query:$genre:$page:$sortBy:$minimumRating';

    final cached = _movieCache[key];
    if (cached != null) return cached;

    try {
      final models = await _remote.listMovies(
        query: query,
        genre: genre,
        page: page,
        sortBy: sortBy,
        minimumRating: minimumRating,
      );

      final movies = models.map((model) => model.toEntity()).toList();
      _movieCache[key] = movies;
      return movies;
    } on ApiException catch (error) {
      // Only when the request never landed. A 404 or a rejected parameter is
      // a real answer, and quietly showing yesterday's catalogue instead of
      // reporting it would be a lie.
      if (!error.isConnectionIssue) rethrow;

      // ⚠️ A search is never answered from the snapshot. Falling back makes
      // sense for Home and Browse, where any catalogue beats a blank screen.
      // For a search it is actively wrong: asking for "batman" offline would
      // return Avengers, Superbad and eighteen other unrelated films,
      // presented as matches. Better to say the search failed.
      if (query != null && query.isNotEmpty) rethrow;

      // Not cached: the snapshot is the same three files every time, so
      // caching it would only mask a later successful refresh.
      final fallback = await _local.listMovies();
      if (fallback.isEmpty) rethrow;
      return fallback.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<MovieDetails> getMovieDetails(int movieId) async {
    final cached = _detailsCache[movieId];
    if (cached != null) return cached;

    try {
      final model = await _remote.movieDetails(movieId);
      if (model == null) {
        throw const ApiException('That movie could not be found.');
      }

      final details = model.toEntity();
      _detailsCache[movieId] = details;
      return details;
    } on ApiException catch (error) {
      if (!error.isConnectionIssue) rethrow;

      final fallback = await _local.movieDetails();
      if (fallback == null) rethrow;
      return fallback.toEntity();
    }
  }

  @override
  Future<MovieDetails> getMovieDetailsByImdb(String imdbCode) async {
    final model = await _remote.movieDetailsByImdb(imdbCode);
    if (model == null) {
      throw const ApiException('That movie could not be found.');
    }

    final details = model.toEntity();
    // Keyed by the numeric id so a later lookup by either route hits it.
    _detailsCache[details.movie.id] = details;
    return details;
  }

  @override
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    final key = 'similar:$movieId';

    final cached = _movieCache[key];
    if (cached != null) return cached;

    try {
      final models = await _remote.movieSuggestions(movieId);
      final movies = models.map((model) => model.toEntity()).toList();
      _movieCache[key] = movies;
      return movies;
    } on ApiException catch (error) {
      if (!error.isConnectionIssue) rethrow;

      final fallback = await _local.movieSuggestions();
      if (fallback.isEmpty) rethrow;
      return fallback.map((model) => model.toEntity()).toList();
    }
  }
}
