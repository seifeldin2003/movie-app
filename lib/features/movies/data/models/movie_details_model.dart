import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_details.dart';
import 'cast_member_model.dart';
import 'json_read.dart';

/// The `movie` object inside `movie_details.json`.
///
/// ⚠️ SEPARATE FROM `MovieModel` ON PURPOSE. The two endpoints do not return
/// the same fields, and parsing one with the other fails *silently* — you get
/// a record with an empty summary rather than an exception, which is far
/// harder to find:
///
/// | field                       | list_movies | movie_details |
/// |-----------------------------|-------------|---------------|
/// | `summary` / `synopsis`      | yes         | **absent**    |
/// | `description_intro`         | absent      | yes           |
/// | `like_count`                | absent      | yes           |
/// | `cast`                      | absent      | `with_cast`   |
/// | `medium_screenshot_image1-3`| absent      | `with_images` |
class MovieDetailsModel {
  const MovieDetailsModel({
    this.id,
    this.imdbCode,
    this.title,
    this.year,
    this.rating,
    this.runtime,
    this.genres,
    this.descriptionIntro,
    this.descriptionFull,
    this.ytTrailerCode,
    this.mpaRating,
    this.likeCount,
    this.mediumCoverImage,
    this.largeCoverImage,
    this.backgroundImage,
    this.screenshots = const [],
    this.cast = const [],
  });

  final int? id;
  final String? imdbCode;
  final String? title;
  final int? year;
  final double? rating;
  final int? runtime;
  final List<String>? genres;

  /// The short blurb. This endpoint has no `summary` key at all.
  final String? descriptionIntro;
  final String? descriptionFull;

  final String? ytTrailerCode;
  final String? mpaRating;
  final int? likeCount;
  final String? mediumCoverImage;
  final String? largeCoverImage;
  final String? backgroundImage;
  final List<String> screenshots;
  final List<CastMemberModel> cast;

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailsModel(
      id: JsonRead.asInt(json['id']),
      imdbCode: json['imdb_code'] as String?,
      title: json['title'] as String?,
      year: JsonRead.asInt(json['year']),
      rating: JsonRead.asDouble(json['rating']),
      runtime: JsonRead.asInt(json['runtime']),
      genres: JsonRead.asStringList(json['genres']),
      descriptionIntro: json['description_intro'] as String?,
      descriptionFull: json['description_full'] as String?,
      ytTrailerCode: json['yt_trailer_code'] as String?,
      mpaRating: json['mpa_rating'] as String?,
      likeCount: JsonRead.asInt(json['like_count']),
      mediumCoverImage: json['medium_cover_image'] as String?,
      largeCoverImage: json['large_cover_image'] as String?,
      backgroundImage: json['background_image'] as String?,
      screenshots: _screenshots(json),
      cast: CastMemberModel.listFrom(json['cast']),
    );
  }

  /// Reads `movie` out of the `data` wrapper.
  static MovieDetailsModel? from(Map<String, dynamic> data) {
    final movie = data['movie'];
    if (movie is! Map<String, dynamic>) return null;
    return MovieDetailsModel.fromJson(movie);
  }

  /// The stills arrive as three separate numbered keys rather than an array,
  /// and a movie can have one, two or none. Collecting them here means the
  /// widget just receives a list and never counts.
  ///
  /// Medium rather than large: they render at 166 high, so the large files
  /// would be a few hundred KB each for no visible gain.
  static List<String> _screenshots(Map<String, dynamic> json) {
    final urls = <String>[];
    for (var i = 1; i <= 3; i++) {
      final url = json['medium_screenshot_image$i'];
      if (url is String && url.isNotEmpty) urls.add(url);
    }
    return urls;
  }

  /// The shared half of the record, so the details screen reuses the same
  /// poster and rating widgets the lists use.
  Movie toMovie() => Movie(
    id: id ?? 0,
    title: title ?? 'Untitled',
    imdbCode: imdbCode,
    year: year,
    rating: rating,
    genres: genres ?? const [],
    posterUrl: mediumCoverImage,
    largePosterUrl: largeCoverImage,
    backgroundUrl: backgroundImage,
    summary: descriptionIntro ?? descriptionFull,
  );

  /// [similar] comes from a separate `movie_suggestions` call, so the
  /// repository supplies it rather than the parse.
  MovieDetails toEntity({List<Movie> similar = const []}) => MovieDetails(
    movie: toMovie(),
    descriptionFull: descriptionFull ?? descriptionIntro,
    runtimeMinutes: runtime,
    mpaRating: mpaRating,
    likeCount: likeCount,
    ytTrailerCode: ytTrailerCode,
    cast: cast.map((member) => member.toEntity()).toList(),
    screenshots: screenshots,
    similar: similar,
  );
}
