import 'cast_member.dart';
import 'movie.dart';

/// Everything the Movie Details screen shows. Figma node 52:641.
///
/// Wraps [Movie] rather than extending it: the list endpoint and the details
/// endpoint are different YTS responses, and keeping them separate stops a
/// list payload from being mistaken for a fully-loaded detail. Field names
/// follow `movie_details` so the Phase 2 data layer maps straight onto this.
class MovieDetails {
  const MovieDetails({
    required this.movie,
    this.descriptionFull,
    this.runtimeMinutes,
    this.mpaRating,
    this.likeCount,
    this.ytTrailerCode,
    this.cast = const [],
    this.screenshots = const [],
    this.similar = const [],
  });

  /// The shared fields — title, year, rating, genres, artwork.
  final Movie movie;

  /// YTS `description_full`.
  final String? descriptionFull;

  /// YTS `runtime`, in minutes. Zero for records YTS has no runtime for,
  /// which is why the badge hides rather than showing "0".
  final int? runtimeMinutes;

  /// YTS `mpa_rating` — the age badge. Frequently an empty string.
  final String? mpaRating;

  /// YTS `like_count` — the heart figure in the design.
  ///
  /// Returned by `movie_details` only; `list_movies` has no such field, which
  /// is why it lives here and not on [Movie].
  final int? likeCount;

  /// YouTube video id for the trailer.
  final String? ytTrailerCode;

  /// Needs `with_cast=true`.
  final List<CastMember> cast;

  /// YTS `medium_screenshot_image1..3`, from `with_images=true`.
  final List<String> screenshots;

  /// A separate `movie_suggestions` call, not part of `movie_details`.
  final List<Movie> similar;
}
