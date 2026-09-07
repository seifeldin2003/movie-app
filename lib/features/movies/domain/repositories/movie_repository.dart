import '../entities/movie.dart';
import '../entities/movie_details.dart';

/// The movie contract every screen codes against.
///
/// ⚠️ AGREED INTERFACE — same rule as `AuthRepository`: adding a method is
/// fine, changing an existing signature breaks whoever is wiring another
/// screen on their branch. Tell the team first.
///
/// Implementations throw a `String`-readable [ApiException] whose `message` is
/// already a sentence, so a Bloc surfaces `e.toString()` and never inspects a
/// status code.
///
/// Note the details screen's two calls are kept **separate** rather than
/// bundled into one. The screen shows the movie as soon as it arrives and
/// fills the Similar row in after, instead of holding a spinner until both
/// have finished.
abstract class MovieRepository {
  /// Backs Home, Browse and Search — all three are `list_movies` with
  /// different parameters.
  ///
  /// [query] searches by title, and also accepts an imdb code.
  /// [genre] is the Browse chip. [page] is 1-based.
  Future<List<Movie>> getMovies({
    String? query,
    String? genre,
    int page,
    String? sortBy,
    int? minimumRating,
  });

  /// The Movie Details record. [similar] on the result is empty — call
  /// [getSimilarMovies] for that.
  Future<MovieDetails> getMovieDetails(int movieId);

  /// The same record addressed by imdb code, for ids arriving from elsewhere.
  Future<MovieDetails> getMovieDetailsByImdb(String imdbCode);

  /// The suggestions under "Similar" — up to four, sometimes fewer.
  Future<List<Movie>> getSimilarMovies(int movieId);
}
