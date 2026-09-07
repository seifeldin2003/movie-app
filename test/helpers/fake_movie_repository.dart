import 'package:movie_app/core/network/api_exception.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

/// Drives the movie screens through exact states without a network.
///
/// The point of the repository contract: a Bloc test never touches Dio, so it
/// is fast, offline and deterministic. Each call can be told to fail
/// independently, because "suggestions failed but the movie loaded" is a real
/// state the screen has to survive.
class FakeMovieRepository implements MovieRepository {
  FakeMovieRepository({
    this.movies = const [],
    this.details,
    this.similar = const [],
    this.detailsError,
    this.similarError,
    this.moviesError,
    this.delay = Duration.zero,
  });

  final List<Movie> movies;
  final MovieDetails? details;
  final List<Movie> similar;

  /// When set, that call throws instead of returning.
  final String? detailsError;
  final String? similarError;
  final String? moviesError;

  /// Holds the call open so a test can assert the loading state.
  final Duration delay;

  /// Every argument each method was called with, for asserting the Bloc asked
  /// for the right thing.
  final List<String?> queries = [];
  final List<String?> genres = [];
  final List<String?> sortBys = [];
  final List<int?> minimumRatings = [];
  final List<int> detailsRequests = [];
  final List<int> similarRequests = [];

  Future<T> _answer<T>(T value, String? error) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (error != null) throw ApiException(error);
    return value;
  }

  @override
  Future<List<Movie>> getMovies({
    String? query,
    String? genre,
    int page = 1,
    String? sortBy,
    int? minimumRating,
  }) {
    if (query != null) queries.add(query);
    if (genre != null) genres.add(genre);
    if (sortBy != null) sortBys.add(sortBy);
    if (minimumRating != null) minimumRatings.add(minimumRating);
    return _answer(movies, moviesError);
  }

  @override
  Future<MovieDetails> getMovieDetails(int movieId) async {
    detailsRequests.add(movieId);
    return _details();
  }

  @override
  Future<MovieDetails> getMovieDetailsByImdb(String imdbCode) => _details();

  /// The error is checked *before* the record is unwrapped. Passing
  /// `details!` as an argument would evaluate it first, so an error-only fake
  /// would throw a null-check error rather than the ApiException under test.
  Future<MovieDetails> _details() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);

    final error = detailsError;
    if (error != null) throw ApiException(error);

    final record = details;
    if (record == null) {
      throw StateError('FakeMovieRepository needs `details` or `detailsError`');
    }
    return record;
  }

  @override
  Future<List<Movie>> getSimilarMovies(int movieId) {
    similarRequests.add(movieId);
    return _answer(similar, similarError);
  }
}
