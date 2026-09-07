import 'movie.dart';

/// A titled row of movies — one genre strip on Home.
///
/// Named for the row rather than the genre so it stays useful if a section is
/// ever "Top rated" or "New this week" instead of a genre.
///
/// Not to be confused with the `GenreSection` *widget* that draws one.
class MovieSection {
  const MovieSection({required this.title, required this.movies});

  final String title;
  final List<Movie> movies;
}
