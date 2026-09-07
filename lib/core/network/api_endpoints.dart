/// Every URL and query-parameter name the app sends to YTS.
///
/// Nothing outside this file spells an endpoint or a parameter key. A typo in
/// a raw string like `'query_term'` does not fail to compile — it silently
/// returns the unfiltered catalogue, which looks like a logic bug for hours.
class ApiEndpoints {
  const ApiEndpoints._();

  /// ⚠️ ONE CONSTANT ON PURPOSE. YTS runs behind rotating mirrors
  /// (`.mx` / `.lt` / `.gg` / this one) and torrent-adjacent domains are
  /// commonly blocked by ISPs in Egypt. When a mirror dies, switching must be
  /// a one-line edit here — never a find-replace across the app.
  static const String baseUrl = 'https://movies-api.accel.li/api/v2';

  // Paths ------------------------------------------------------------------

  static const String listMovies = '/list_movies.json';
  static const String movieDetails = '/movie_details.json';
  static const String movieSuggestions = '/movie_suggestions.json';

  // `/movie_parental_guides.json` is deliberately absent. It answers 200 for
  // every id in the catalogue with the same placeholder sentence, so there is
  // nothing to show. `mpa_rating` on movie_details gives the age badge.

  // Query keys -------------------------------------------------------------

  /// Free-text search. Also accepts an imdb code (`tt1375666`) directly, so
  /// Search needs no separate endpoint.
  static const String queryTerm = 'query_term';

  static const String genre = 'genre';
  static const String page = 'page';
  static const String limit = 'limit';
  static const String sortBy = 'sort_by';
  static const String minimumRating = 'minimum_rating';

  /// `movie_details` and `movie_suggestions` both take the numeric YTS id.
  static const String movieId = 'movie_id';

  /// `movie_details` alternatively accepts `tt0798817`. `movie_suggestions`
  /// does NOT — it is numeric-only.
  static const String imdbId = 'imdb_id';

  /// Without these two, `movie_details` returns no `cast` key and no
  /// `medium_screenshot_image*` keys at all — not empty ones, absent ones.
  static const String withCast = 'with_cast';
  static const String withImages = 'with_images';

  // Values -----------------------------------------------------------------

  /// Sorting by `rating` alone surfaces obscure records with a handful of
  /// votes. Download count is what actually ranks recognisable films.
  static const String sortByDownloads = 'download_count';

  /// Page size. The API caps at 50; 20 is one comfortable scroll.
  static const int pageSize = 20;

  /// Floor for the Home feed, so the carousel is not filled with 3/10 titles.
  static const int homeMinimumRating = 7;
}
