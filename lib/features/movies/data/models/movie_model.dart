import '../../domain/entities/movie.dart';
import 'json_read.dart';

/// One row of `list_movies.json` or `movie_suggestions.json`.
///
/// Those two endpoints return the same movie shape, so one model covers both.
/// `movie_details.json` does NOT — see [MovieDetailsModel] and the note there.
///
/// Every field is nullable and every read is defaulted, because YTS omits keys
/// rather than sending nulls. The model's job is to survive the payload; the
/// entity's job is to be what the widgets read.
class MovieModel {
  const MovieModel({
    this.id,
    this.imdbCode,
    this.title,
    this.year,
    this.rating,
    this.runtime,
    this.genres,
    this.summary,
    this.mediumCoverImage,
    this.largeCoverImage,
    this.backgroundImage,
  });

  final int? id;
  final String? imdbCode;
  final String? title;
  final int? year;
  final double? rating;
  final int? runtime;
  final List<String>? genres;
  final String? summary;
  final String? mediumCoverImage;
  final String? largeCoverImage;
  final String? backgroundImage;

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: JsonRead.asInt(json['id']),
      imdbCode: json['imdb_code'] as String?,
      title: json['title'] as String?,
      year: JsonRead.asInt(json['year']),
      rating: JsonRead.asDouble(json['rating']),
      runtime: JsonRead.asInt(json['runtime']),
      genres: JsonRead.asStringList(json['genres']),
      summary: json['summary'] as String?,
      mediumCoverImage: json['medium_cover_image'] as String?,
      largeCoverImage: json['large_cover_image'] as String?,
      backgroundImage: json['background_image'] as String?,
    );
  }

  /// Parses the `movies` array out of a `data` object.
  ///
  /// ⚠️ On a search with no matches YTS drops the `movies` key altogether —
  /// `data` comes back as `{movie_count: 0, limit, page_number}`. So this is
  /// null, not empty, and `as List` without the guard crashes the first time
  /// someone searches for something that does not exist.
  static List<MovieModel> listFrom(Map<String, dynamic> data) {
    return JsonRead.objects(data['movies']).map(MovieModel.fromJson).toList();
  }

  /// Drops the API's field names at the boundary. Nothing above the data layer
  /// knows YTS calls a poster `medium_cover_image`.
  Movie toEntity() {
    return Movie(
      // YTS always sends an id; 0 keeps a malformed row from crashing the
      // list, and it renders as a placeholder card.
      id: id ?? 0,
      title: title ?? 'Untitled',
      imdbCode: imdbCode,
      year: year,
      rating: rating,
      genres: genres ?? const [],
      posterUrl: mediumCoverImage,
      largePosterUrl: largeCoverImage,
      backgroundUrl: backgroundImage,
      summary: summary,
    );
  }
}
