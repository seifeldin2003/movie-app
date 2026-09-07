/// A movie as the UI needs it.
///
/// Field names follow the YTS `list_movies` response so the Phase 2 data layer
/// maps onto this without renaming anything. Everything the API can omit is
/// nullable — the widgets default at the point of use rather than trusting the
/// payload.
class Movie {
  const Movie({
    required this.id,
    required this.title,
    this.imdbCode,
    this.year,
    this.rating,
    this.genres = const [],
    this.posterUrl,
    this.largePosterUrl,
    this.backgroundUrl,
    this.summary,
  });

  /// YTS `id`. Also seeds the placeholder poster colour, so it must be stable.
  final int id;

  final String title;

  /// YTS `imdb_code`, e.g. `tt0798817`.
  ///
  /// The cross-database join key: `movie_details` accepts it as `imdb_id`,
  /// search accepts it as a `query_term`, and any second API keys off it too.
  /// Present on every endpoint's response — including `movie_suggestions`,
  /// whose *request* is numeric-only.
  final String? imdbCode;

  final int? year;

  /// YTS `rating`, out of 10.
  final double? rating;

  final List<String> genres;

  /// YTS `medium_cover_image`. Null until the API layer lands, which is why
  /// the poster widget has to render without one.
  final String? posterUrl;

  /// YTS `large_cover_image` — 500x750, same portrait shape as
  /// [posterUrl] but sharp enough to fill a full-screen backdrop.
  final String? largePosterUrl;

  /// YTS `background_image`.
  ///
  /// ⚠️ NOT the right source for a full-height backdrop, despite the name. It
  /// is a 896x375 letterbox banner (ratio 2.39), and the Home backdrop box is
  /// 430x645 (ratio 0.67) — `BoxFit.cover` has to scale it about four times
  /// to fill that and shows a narrow strip of the middle, which reads as an
  /// unrecognisable smear rather than artwork. Use [largePosterUrl] there;
  /// this is only useful somewhere genuinely wide and short.
  final String? backgroundUrl;

  final String? summary;
}
