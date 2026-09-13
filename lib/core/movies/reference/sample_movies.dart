import '../domain/entities/cast_member.dart';
import '../domain/entities/movie.dart';
import '../domain/entities/movie_details.dart';

/// Placeholder catalogue so the Phase 2 screens can be built and reviewed
/// before the YTS layer exists.
///
/// ⚠️ TEMPORARY — delete this file when `MovieRepository` lands.
///
/// The first three carry a local `assets/images/sample/` path so the Home
/// carousel can be eyeballed with real artwork. Those files are git-ignored,
/// so on any other machine the cards quietly fall back to a generated tile —
/// nothing here depends on them existing. Everything else has no poster at
/// all, which is what the API will fill in.
class SampleMovies {
  const SampleMovies._();

  static const String _sample = 'assets/images/sample';

  static const List<Movie> featured = [
    Movie(
      id: 1,
      title: 'The Long Road',
      year: 2019,
      rating: 8.2,
      genres: ['Action', 'Drama'],
      posterUrl: '$_sample/sample_1.jpg',
      backgroundUrl: '$_sample/sample_1.jpg',
    ),
    Movie(
      id: 2,
      title: 'Northern Lights',
      year: 2021,
      rating: 7.7,
      genres: ['Adventure'],
      posterUrl: '$_sample/sample_2.jpg',
      backgroundUrl: '$_sample/sample_2.jpg',
    ),
    Movie(
      id: 3,
      title: 'Quiet Harbour',
      year: 2018,
      rating: 6.9,
      genres: ['Drama'],
      posterUrl: '$_sample/sample_3.png',
      backgroundUrl: '$_sample/sample_3.png',
    ),
    Movie(
      id: 4,
      title: 'Paper Cities',
      year: 2022,
      rating: 7.1,
      genres: ['Sci-Fi', 'Action'],
    ),
    Movie(
      id: 5,
      title: 'The Second Hour',
      year: 2020,
      rating: 8.6,
      genres: ['Thriller', 'Action'],
    ),
  ];

  // Every entry carries two genres so each Browse chip has something to show —
  // the real catalogue has hundreds of movies per genre.
  static const List<Movie> more = [
    Movie(
      id: 6,
      title: 'Salt Flats',
      year: 2017,
      rating: 7.4,
      genres: ['Action', 'Adventure'],
    ),
    Movie(
      id: 7,
      title: 'Winter Ledger',
      year: 2023,
      rating: 6.5,
      genres: ['Biography', 'Drama'],
    ),
    Movie(
      id: 8,
      title: 'Glass Orchard',
      year: 2016,
      rating: 8.0,
      genres: ['Animation', 'Adventure'],
    ),
    Movie(
      id: 9,
      title: 'Under the Wire',
      year: 2024,
      rating: 7.9,
      genres: ['Thriller', 'Action'],
    ),
    Movie(
      id: 10,
      title: 'Blue Corridor',
      year: 2015,
      rating: 6.2,
      genres: ['Sci-Fi', 'Thriller'],
    ),
    Movie(
      id: 11,
      title: 'Halfway Home',
      year: 2022,
      rating: 7.6,
      genres: ['Biography', 'Animation'],
    ),
  ];

  static List<Movie> get all => [...featured, ...more];

  /// Stands in for a `movie_details` + `movie_suggestions` pair.
  ///
  /// The copy is invented, like the titles — the point is to exercise the
  /// layout, not to ship anyone's synopsis. Deliberately leaves the cast
  /// photos and screenshots empty so the widgets are built against the case
  /// the API often returns: a record with fields missing.
  static MovieDetails detailsFor(Movie movie) => MovieDetails(
    movie: movie,
    descriptionFull:
        'A quiet story that turns loud. ${movie.title} follows a handful of '
        'people whose paths keep crossing over one long season, until the '
        'thing each of them was avoiding finally arrives. Shot on location '
        'and paced to let the silences land, it is less about the ending '
        'than about who is still standing near it.',
    runtimeMinutes: 90 + (movie.id * 7) % 60,
    mpaRating: movie.id.isEven ? 'PG-13' : '15',
    cast: const [
      CastMember(name: 'Hayley Atwell', characterName: 'Captain Carter'),
      CastMember(name: 'Elizabeth Olsen', characterName: 'Wanda Maximoff'),
      CastMember(name: 'Rachel McAdams', characterName: 'Dr. Christine Palmer'),
      CastMember(name: 'Charlize Theron', characterName: 'Clea'),
    ],
    // Stands in for `medium_screenshot_image1..3`. Points at the same local
    // files as the posters, so the section renders with something real rather
    // than three empty boxes. They are git-ignored, so on another machine the
    // strip falls back to its placeholder tile.
    screenshots: const [
      '$_sample/sample_1.jpg',
      '$_sample/sample_2.jpg',
      '$_sample/sample_3.png',
    ],
    // The design shows a 2x2 grid; movie_suggestions returns up to four.
    similar: similarTo(movie),
  );

  /// Four suggestions for [movie], excluding the movie itself.
  static List<Movie> similarTo(Movie movie) =>
      all.where((other) => other.id != movie.id).take(4).toList();

  /// Genres the Browse tab shows. Phase 2 derives this from the real catalogue
  /// by folding every movie's genres into a Set, per the brief.
  static const List<String> genres = [
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Drama',
    'Sci-Fi',
    'Thriller',
  ];
}
