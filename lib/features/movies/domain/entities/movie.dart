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
    this.year,
    this.rating,
    this.genres = const [],
    this.posterUrl,
    this.backgroundUrl,
    this.summary,
  });

  /// YTS `id`. Also seeds the placeholder poster colour, so it must be stable.
  final int id;

  final String title;
  final int? year;

  /// YTS `rating`, out of 10.
  final double? rating;

  final List<String> genres;

  /// YTS `medium_cover_image`. Null until the API layer lands, which is why
  /// the poster widget has to render without one.
  final String? posterUrl;

  /// YTS `background_image`, used behind the Home carousel.
  final String? backgroundUrl;

  final String? summary;
}
