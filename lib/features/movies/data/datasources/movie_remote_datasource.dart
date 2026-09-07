import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/movie_details_model.dart';
import '../models/movie_model.dart';

/// The happy path: every call the app makes to YTS.
///
/// Knows about Dio and query strings and nothing else — no caching, no
/// fallback, no state. That decision belongs to the repository, which is what
/// makes this class trivial to reason about and the repository testable.
///
/// One endpoint, one method. Never merge two behind an optional flag.
class MovieRemoteDataSource {
  const MovieRemoteDataSource(this._client);

  final ApiClient _client;

  /// `list_movies.json` — the one endpoint behind Home, Browse and Search.
  ///
  /// Every parameter is optional and omitted when null, because sending
  /// `genre=null` filters on the literal string "null" and returns nothing.
  Future<List<MovieModel>> listMovies({
    String? query,
    String? genre,
    int page = 1,
    int limit = ApiEndpoints.pageSize,
    String? sortBy,
    int? minimumRating,
  }) async {
    final data = await _client.get(
      ApiEndpoints.listMovies,
      queryParameters: {
        ApiEndpoints.page: page,
        ApiEndpoints.limit: limit,
        if (query != null && query.isNotEmpty) ApiEndpoints.queryTerm: query,
        if (genre != null && genre.isNotEmpty) ApiEndpoints.genre: genre,
        ApiEndpoints.sortBy: ?sortBy,
        ApiEndpoints.minimumRating: ?minimumRating,
      },
    );

    return MovieModel.listFrom(data);
  }

  /// `movie_details.json` with both extras switched on.
  ///
  /// Always asks for cast and images: they are what the screen is made of,
  /// and leaving them off returns a record with those keys missing entirely
  /// rather than empty.
  ///
  /// Takes the numeric YTS id. The endpoint also accepts `imdb_id`, which
  /// [movieDetailsByImdb] uses.
  Future<MovieDetailsModel?> movieDetails(int movieId) async {
    final data = await _client.get(
      ApiEndpoints.movieDetails,
      queryParameters: {
        ApiEndpoints.movieId: movieId,
        ApiEndpoints.withCast: true,
        ApiEndpoints.withImages: true,
      },
    );

    return MovieDetailsModel.from(data);
  }

  /// The same record, addressed by imdb code (`tt0798817`).
  ///
  /// Kept for the cross-database work: an id from another service is an imdb
  /// code, not a YTS id, so this is the door in.
  Future<MovieDetailsModel?> movieDetailsByImdb(String imdbCode) async {
    final data = await _client.get(
      ApiEndpoints.movieDetails,
      queryParameters: {
        ApiEndpoints.imdbId: imdbCode,
        ApiEndpoints.withCast: true,
        ApiEndpoints.withImages: true,
      },
    );

    return MovieDetailsModel.from(data);
  }

  /// `movie_suggestions.json` — related movies.
  ///
  /// The docs say four. Verified against the live API it is **up to** four
  /// — an obscure record can come back with two, or none. The Similar grid
  /// is a 2x2 in the design, so it has to cope with a short list rather
  /// than assuming a full one.
  ///
  /// ⚠️ Numeric id only. This is the one endpoint that will not take an imdb
  /// code as its parameter, though the movies it returns each carry one.
  Future<List<MovieModel>> movieSuggestions(int movieId) async {
    final data = await _client.get(
      ApiEndpoints.movieSuggestions,
      queryParameters: {ApiEndpoints.movieId: movieId},
    );

    return MovieModel.listFrom(data);
  }
}
